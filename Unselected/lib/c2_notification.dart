import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:c2/balance_card.dart';
import 'package:c2/cash_flow_line_chart.dart';
import 'package:c2/expenses_pie_chart.dart';
import 'package:c2/transaction_cell.dart';

typedef InitDartApiNative = IntPtr Function(Pointer<Void> data);
typedef InitDartApiDart = int Function(Pointer<Void> data);
typedef LoginCallback = void Function(bool success);

class C2Notification {
  // Global callback holder
  static late final SendPort sendPort;
  static bool _initialized = false;

  // Initialize callback system
  static void initNotificationCallback(DynamicLibrary lib) {
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
            "✅ Received message: $notificationName with data: '$notificationData'",
          );
          C2NotificationProcessor.process(notificationName, notificationData);
        } else {
          stderr.writeln(
            "📨 Unknown message: $message (${message.runtimeType})",
          );
        }
      },
      onError: (error) {
        stderr.writeln("❌ Message receipt error: $error");
      },
    );
  }
}

class C2NotificationProcessor {
  // Populated by _LoginScreenState
  static late LoginCallback gOnSignupResult;
  static late LoginCallback gOnLoginResult;

  static void process(String notificationName, String notificationData) {
    if (notificationName == "kUserSignupNotification") {
      processUserSignupNotification();
    } else if (notificationName == "kUserLoginNotification") {
      processUserLoginNotification(notificationData == "1");
    } else if (notificationName == "kCashFlowNotification") {
      processCashFlowNotification(stringToIntArray(notificationData));
    } else if (notificationName == "kExpenseReportNotification") {
      processExpenseReportNotification(stringToIntArray(notificationData));
    } else if (notificationName == "kBalanceReportNotification") {
      processBalanceReportNotification(stringToIntArray(notificationData));
    } else if (notificationName == "kTransactionListNotification") {
      processTransactionListNotification(parseTransactions(notificationData));
    } else {
      stderr.write("Unrecognized notification: $notificationName\n");
      return;
    }
    stderr.write("Processed notification: $notificationName\n");
  }

  static void processUserSignupNotification() {
    gOnSignupResult.call(true);
  }

  static void processUserLoginNotification(bool result) {
    gOnLoginResult.call(result);
  }

  static List<int> stringToIntArray(String s) {
    return s.split(',').map((e) => int.parse(e.trim())).toList();
  }

  static void processCashFlowNotification(List<int> data) {
    List<int> netCashFlow = data.sublist(0, data.length - 2);
    List<int> avgCashFlowList = data.sublist(data.length - 2);
    double avgCashFlow = avgCashFlowList[0] / avgCashFlowList[1];

    CashFlowLineChartState.cashFlowNotifier.value = CashFlowChartData(
      netCashFlow,
      avgCashFlow,
    );
  }

  static void processExpenseReportNotification(List<int> data) {
    ExpensesPieChartState.expensesNotifier.value = ExpenseReport(
      data[0],
      data[1],
      data[2],
      data[3],
      data[4],
    ).toPercentages();
  }

  static void processBalanceReportNotification(List<int> data) {
    final lastIncome = data[0];
    final lastExpense = data[1];
    final lastNet = lastIncome - lastExpense;
    final thisIncome = data[2];
    final thisExpense = data[3];
    final thisNet = thisIncome - thisExpense;
    BalanceCard.balanceNotifier.value = Balance(
      incomeCents: thisIncome,
      incomePercentDiff: thisIncome / lastIncome,
      expensesCents: thisExpense,
      expensePercentDiff: thisExpense / lastExpense,
      netCents: thisNet,
      netPercentDiff: thisNet / lastNet,
    );
  }

  static List<Transaction> parseTransactions(String s) {
    final data = s.split(',');

    // Each transaction has 8 fields, starting at indices 0, 8, ...
    final transactions = <Transaction>[];

    for (int i = 0; i < data.length; i += 8) {
      if (i + 7 >= data.length) {
        break; // Not enough fields for complete transaction
      }

      final transaction = Transaction(
        int.parse(data[i]), // id
        data[i + 1], // username
        int.parse(data[i + 2]), // unix timestamp
        data[i + 3], // type
        data[i + 4], // category
        data[i + 5], // source/merchant
        data[i + 6], // note
        int.parse(data[i + 7]), // amount in cents
      );

      transactions.add(transaction);
    }

    return transactions;
  }

  static void processTransactionListNotification(List<Transaction> data) {
    TransactionListSection.transactionsNotifier.value = [
      TransactionString.header(),
      ...data.map((t) => t.toTransString()),
    ];
  }
}
