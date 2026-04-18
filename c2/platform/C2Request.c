#include <stdio.h>
#include <string.h>

#include "C2CashFlowRequestHandler.h"
#include "C2ExpenseReportRequestHandler.h"
#include "C2NewTransactionRequestHandler.h"
#include "C2Request.h"
#include "C2TransactionListRequestHandler.h"
#include "C2UserLoginController.h"

static char *gDatabasePath = NULL;

void process_request(Message request) {
  char *kRequestName = request.name;
  char *data = request.data;
  fprintf(stderr, "Processed request: '%s' with data: '%s'\n", kRequestName,
          data);
  if (strcmp(kRequestName, "kSetDatabasePath") == 0) {
    gDatabasePath = strdup(data);
    fprintf(stderr, "Set database path to %s\n", gDatabasePath);
  } else if (strcmp(kRequestName, "kUserSignupRequest") == 0) {
    process_user_signup_request(gDatabasePath, data);
  } else if (strcmp(kRequestName, "kUserLoginRequest") == 0) {
    process_user_login_request(gDatabasePath, data);
  } else if (strcmp(kRequestName, "kCashFlowRequest") == 0) {
    process_cash_flow_request(gDatabasePath, data);
  } else if (strcmp(kRequestName, "kExpenseReportRequest") == 0) {
    process_expense_report_request(gDatabasePath, data);
  } else if (strcmp(kRequestName, "kNewTransactionRequest") == 0) {
    process_new_transaction_request(gDatabasePath, data);
  } else if (strcmp(kRequestName, "kTransactionListRequest") == 0) {
    process_transaction_list_request(gDatabasePath, data);
  } else {
    fprintf(stderr, "Unknown request: %s", kRequestName);
  }
}
