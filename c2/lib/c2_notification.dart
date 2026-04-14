import 'dart:ffi';
import 'dart:isolate';
import 'package:ffi/ffi.dart';
import 'package:c2/expenses_pie_chart.dart';

final class Message extends Struct {
  external Pointer<Utf8> name;
  external Pointer<Utf8> data;
}

List<int> stringToIntArray(String s) {
  return s.split(',').map((e) => int.parse(e.trim())).toList();
}

// Native function signature
typedef ProcessNotificationNative = Void Function(Message);
typedef ProcessNotification = void Function(Message);
typedef NotificationCallbackPointer = Pointer<NativeFunction<ProcessNotificationNative>>;

// Global callback holder
late final NotificationCallbackPointer dartCallback;
late final SendPort sendPort;

void processCashFlowNotification(List<int> data) {
  List<int> netCashFlow = data.sublist(0, data.length - 2);
  List<int> avgCashFlowList = data.sublist(data.length - 2);
  double avgCashFlow = avgCashFlowList[0] / avgCashFlowList[1];
}

void processExpenseReportNotification(List<int> data) {
  ExpenseReport report = ExpenseReport(data[0], data[1], data[2], data[3], data[4]);
}

void processNotification(Message message) {
  final notificationName = message.name.toDartString();
  final notificationData = message.data.toDartString();
  if (notificationName == "kCashFlowNotification") {
    processCashFlowNotification(stringToIntArray(notificationData));
  } else if (notificationName == "kExpenseReportNotification") {
    processExpenseReportNotification(stringToIntArray(notificationData));
  }
}

// Initialize callback system
void initNotificationCallback(DynamicLibrary lib) {
  // Create isolate port for C->Dart communication
  final receivePort = ReceivePort();
  sendPort = receivePort.sendPort;

  // Convert Dart function to native function pointer
  dartCallback = Pointer.fromFunction<ProcessNotificationNative>(
    processNotification
  );

  // Register callback with C (pass function pointer + isolate port ID)
  final registerCallback = lib.lookupFunction<
      Void Function(NotificationCallbackPointer, Int64),
      void Function(NotificationCallbackPointer, int)
  >('register_notification_callback');

  registerCallback(dartCallback, sendPort.nativePort);

  // Listen for messages from C
  receivePort.listen((message) {
    // Handle structured messages from C
    print('Message from C: $message');
  });
}
