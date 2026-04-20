import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:c2/c2_message.dart';
import 'package:c2/c2_notification.dart';

typedef ProcessRequestNative = Void Function(Message request);
typedef ProcessRequest = void Function(Message request);

void sendRequest(String name, String data) {
  final dylib = getDylib();
  initNotificationCallback(dylib);

  final processRequest = dylib
      .lookupFunction<ProcessRequestNative, ProcessRequest>('process_request');
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
