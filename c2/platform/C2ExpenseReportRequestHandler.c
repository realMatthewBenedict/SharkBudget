#include <stdlib.h>

#include "BackendController.h"
#include "C2Notification.h"
#include "StringHandler.h"
#include "TimeHandler.h"

void process_expense_report_request() {
  BackendController *b = createBackend();
  int64_t *timestamps = construct_timestamps(2);
  ExpenseReport *report = expenseBreakdown(b, timestamps[0], timestamps[1]);

  int64_t r[5] = {report->bills, report->food, report->housing,
                  report->transport, report->other};
  String result = intArrToString(r, 5);
  send_notification("kExpenseReportNotification", result);
  freeBackend(b);
}
