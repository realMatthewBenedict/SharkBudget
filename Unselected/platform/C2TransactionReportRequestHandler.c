#include <stdlib.h>

#include "BackendController.h"
#include "C2Notification.h"
#include "StringHandler.h"
#include "TimeHandler.h"

void process_expense_report_request(const char *databasePath,
                                    const char *username) {
  BackendController *b = createBackend(databasePath, username);
  int64_t *timestamps = construct_timestamps(2);
  ExpenseReport *report = expenseBreakdown(b, timestamps[0], timestamps[1]);

  int64_t r[5] = {report->bills, report->food, report->housing,
                  report->transport, report->other};
  String result = intArrToString(r, 5);
  send_notification("kExpenseReportNotification", result);
  freeBackend(b);
}

void process_balance_report_request(const char *databasePath,
                                    const char *username) {
  BackendController *b = createBackend(databasePath, username);
  int64_t *timestamps = construct_timestamps(3);
  BalanceReport *lastReport = balanceBreakdown(b, timestamps[0], timestamps[1]);
  BalanceReport *thisReport = balanceBreakdown(b, timestamps[1], timestamps[2]);

  int64_t r[4] = {lastReport->income, lastReport->expense, thisReport->income,
                  thisReport->expense};
  String result = intArrToString(r, 4);
  send_notification("kBalanceReportNotification", result);
  freeBackend(b);
}
