import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'package:ffi/ffi.dart';

import 'package:c2/cash_flow_line_chart.dart';
import 'package:c2/c2_message.dart';
import 'package:c2/expenses_pie_chart.dart';

List<int> stringToIntArray(String s) {
  return s.split(',').map((e) => int.parse(e.trim())).toList();
}

// Native function signature
typedef ProcessNotificationNative = Void Function(Message);
typedef ProcessNotification = void Function(Message);
typedef NotificationCallbackPointer = Pointer<NativeFunction<ProcessNotificationNative>>;

// Global callback holder
late final SendPort sendPort;
bool _initialized = false;

void processCashFlowNotification(List<int> data) {
  List<int> netCashFlow = data.sublist(0, data.length - 2);
  List<int> avgCashFlowList = data.sublist(data.length - 2);
  double avgCashFlow = avgCashFlowList[0] / avgCashFlowList[1];
  stderr.write('🔍 chartKey.currentState: ${CashFlowLineChart.chartKey.currentState}');
  stderr.write('🔍 chartKey.currentContext: ${CashFlowLineChart.chartKey.currentContext}');

  final state = CashFlowLineChart.chartKey.currentState;
  if (state == null) {
    stderr.write('❌ Chart state NULL - widget not ready');
    return;
  }

  state.updateData(netCashFlow, avgCashFlow);
}

void processExpenseReportNotification(List<int> data) {
  ExpenseReport report = ExpenseReport(data[0], data[1], data[2], data[3], data[4]);
}

void processNotification(String notificationName, String notificationData) {
  if (notificationName == "kCashFlowNotification") {
    processCashFlowNotification(stringToIntArray(notificationData));
  } else if (notificationName == "kExpenseReportNotification") {
    processExpenseReportNotification(stringToIntArray(notificationData));
  } else {
    stderr.write("Unrecognized notification: $notificationName\n");
    return;
  }
  stderr.write("Processed notification: $notificationName\n");
}

typedef InitDartApiNative = IntPtr Function(Pointer<Void> data);
typedef InitDartApiDart = int Function(Pointer<Void> data);

// Initialize callback system
void initNotificationCallback(DynamicLibrary lib) {
  if (_initialized) {
    return;
  }

  final initDartApiDL = lib.lookupFunction<InitDartApiNative, InitDartApiDart>('InitDartApiDL');

  final result = initDartApiDL(NativeApi.initializeApiDLData);
  if (result != 0) {
    throw Exception('Dart API initialization failed');
  }
  _initialized = true;

  // Create isolate port for C->Dart communication
  final receivePort = ReceivePort();
  sendPort = receivePort.sendPort;

  // Register callback with C (pass function pointer + isolate port ID)
  final registerCallback = lib.lookupFunction<
      Void Function(Int64),
      void Function(int)
  >('register_notification_port');

  registerCallback(sendPort.nativePort);

  // Listen for messages from C
  receivePort.listen((message) {
    if (message is List && message.length == 2) {
      final notificationName = message[0] as String;
      final notificationData = message[1] as String;
      stderr.writeln('✅ Received message: $notificationName with data: $notificationData');

      processNotification(notificationName, notificationData);
    } else {
      stderr.writeln('📨 Unknown message: $message (${message.runtimeType})');
    }
  }, onError: (error) {
    stderr.writeln('❌ ReceivePort error: $error');
  });
}
