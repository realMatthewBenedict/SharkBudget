#include <string.h>

#include "C2Request.h"
#include "C2CashFlowRequestHandler.h"
#include "C2ExpenseReportRequestHandler.h"

void process_request(Message request) {
    char* kRequestName = request.name;
    if (strcmp(kRequestName, "kCashFlowRequest") == 0) {
        process_cash_flow_request();
    }
    if (strcmp(kRequestName, "kExpenseReportRequest") == 0) {
        process_expense_report_request();
    }
}
