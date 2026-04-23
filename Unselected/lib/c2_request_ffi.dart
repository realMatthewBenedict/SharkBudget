import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'package:c2/c2_request_abstract.dart' as request_base;
import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as path;

import 'c2_notification.dart';

typedef ProcessRequestNative = Void Function(Message request);
typedef ProcessRequest = void Function(Message request);
typedef InitDartApiNative = IntPtr Function(Pointer<Void> data);
typedef InitDartApiDart = int Function(Pointer<Void> data);

final class Message extends Struct {
  external Pointer<Utf8> name;
  external Pointer<Utf8> data;
}

class C2Request extends request_base.C2RequestAbstract {
  DynamicLibrary dylib;
  late final SendPort sendPort;
  bool _initialized = false;

  C2Request() : dylib = _getDylib() {
    _initNotificationCallback(dylib);
  }

  @override
  void sendRequest(String name, String data) {
    final processRequest = dylib
        .lookupFunction<ProcessRequestNative, ProcessRequest>(
          'process_request',
        );
    final kRequestName = name.toNativeUtf8();
    final requestData = data.toNativeUtf8();

    final messagePtr = calloc<Message>();
    messagePtr.ref.name = kRequestName;
    messagePtr.ref.data = requestData;
    stderr.write("Sent request: $name\n");
    processRequest(messagePtr.ref);

    malloc.free(messagePtr.ref.name.cast());
    malloc.free(messagePtr.ref.data.cast());
    malloc.free(messagePtr);
  }

  static DynamicLibrary _getDylib() {
    // Open the dynamic library
    var libraryPath = 'libbackend.so';
    if (Platform.isMacOS) {
      libraryPath = path.join(
        path.dirname(Platform.resolvedExecutable),
        '..',
        'Frameworks',
        'libbackend.dylib',
      );
    }
    if (Platform.isWindows) {
      final exeDir = Directory(Platform.resolvedExecutable).parent.path;
      Directory(exeDir).listSync().forEach((f) => print(f.path));
      libraryPath = 'libbackend.dll';
    }
    return DynamicLibrary.open(libraryPath);
  }

  void _initNotificationCallback(DynamicLibrary lib) {
    if (_initialized) {
      return;
    }

    final initDartApiDL = lib
        .lookupFunction<InitDartApiNative, InitDartApiDart>('InitDartApiDL');

    final result = initDartApiDL(NativeApi.initializeApiDLData);
    if (result != 0) {
      throw Exception('Dart API initialization failed');
    }
    _initialized = true;

    // Create isolate port for C->Dart communication
    final receivePort = ReceivePort();
    sendPort = receivePort.sendPort;

    // Register callback with C (pass function pointer + isolate port ID)
    final registerCallback = lib
        .lookupFunction<Void Function(Int64), void Function(int)>(
          'register_notification_port',
        );

    registerCallback(sendPort.nativePort);

    // Listen for messages from C
    receivePort.listen(
      (message) {
        if (message is List && message.length == 2) {
          final notificationName = message[0] as String;
          final notificationData = message[1] as String;
          stderr.writeln(
            "Received message: $notificationName with data: '$notificationData'",
          );
          C2Notification.process(notificationName, notificationData);
        } else {
          stderr.writeln("Unknown message: $message (${message.runtimeType})");
        }
      },
      onError: (error) {
        stderr.writeln("Message receipt error: $error");
      },
    );
  }
}
