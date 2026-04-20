#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "C2CashFlowRequestHandler.h"
#include "C2Request.h"
#include "C2TransactionCRUDRequestHandler.h"
#include "C2TransactionReportRequestHandler.h"
#include "C2UserLoginController.h"

static char *gDatabasePath = NULL;

#ifdef DART_WEB
void send_request(char *name, char *data) {
  Message m = {.name = name, .data = data};
  process_request(m);
}
#endif

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
  } else if (strcmp(kRequestName, "kBalanceReportRequest") == 0) {
    process_balance_report_request(gDatabasePath, data);
  } else if (strcmp(kRequestName, "kNewTransactionRequest") == 0) {
    process_new_transaction_request(gDatabasePath, data);
  } else if (strcmp(kRequestName, "kTransactionListRequest") == 0) {
    process_transaction_list_request(gDatabasePath, data);
  } else if (strcmp(kRequestName, "kTransactionEditRequest") == 0) {
    process_transaction_edit_request(gDatabasePath, data);
  } else if (strcmp(kRequestName, "kTransactionDeleteRequest") == 0) {
    process_transaction_delete_request(gDatabasePath, data);
  } else {
    fprintf(stderr, "Unknown request: %s", kRequestName);
  }
}
