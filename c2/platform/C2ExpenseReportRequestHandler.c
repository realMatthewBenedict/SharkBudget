#include <stdlib.h>

#include "C2Notification.h"
#include "string_handler.h"
#include "timestamps.h"

void process_expense_report_request() {
    BackendController* b = malloc(sizeof(BackendController));
    int64_t* timestamps = construct_timestamps(2);
    ExpenseReport* report = expenseBreakdown(b, timestamps[0], timestamps[1]);

    int64_t r[5] = {
            report.bills,
            report.food,
            report.housing,
            report.transport,
            report.other
    };
    String result = intArrToString(r, 5);
    send_notification("kCashFlowNotification", result);
}