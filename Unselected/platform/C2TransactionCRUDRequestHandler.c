#include <stdio.h>

#include "BackendController.h"
#include "C2CashFlowRequestHandler.h"
#include "C2Notification.h"
#include "C2TransactionCRUDRequestHandler.h"
#include "C2TransactionReportRequestHandler.h"
#include "StringHandler.h"
#include "TimeHandler.h"

void process_new_transaction_request(const char *databasePath, char *data) {
  String lit = NULL;
  cstring_assign(lit, data, strlen(data));
  StringVector transaction = NULL;
  cstring_split(lit, -1, ",", 1, transaction);

  Transaction t = {.id = 0,
                   .username = transaction[0],
                   .unix_time = strtoll(transaction[1], NULL, 10),
                   .type = transaction[2],
                   .category = transaction[3],
                   .source = transaction[4],
                   .note = transaction[5],
                   .amount_cents = strtoll(transaction[6], NULL, 10)};
  log_transaction(&t, "Recovered transaction");
  BackendController *b = createBackend(databasePath, t.username);
  c2dao_insertTrans(b->globalDB, &t);
  freeBackend(b);
  process_transaction_list_request(databasePath, t.username);
  process_cash_flow_request(databasePath, t.username);
  if (strcmp(t.type, "Expense") == 0) {
    process_expense_report_request(databasePath, t.username);
  }
}

void process_transaction_edit_request(const char *databasePath, char *data) {
  String lit = NULL;
  cstring_assign(lit, data, strlen(data));
  StringVector transaction = NULL;
  cstring_split(lit, -1, ",", 1, transaction);

  int64_t transID = strtoll(transaction[0], NULL, 10);
  char *username = transaction[1];
  char *note = transaction[2];
  int64_t cents = strtoll(transaction[3], NULL, 10);

  BackendController *b = createBackend(databasePath, username);
  c2dao_editTrans(b->globalDB, b->username, transID, note, cents);
  freeBackend(b);
  process_transaction_list_request(databasePath, username);
  process_cash_flow_request(databasePath, username);
  // This could be sped up if we knew whether the transaction was an expense
  process_expense_report_request(databasePath, username);
}

void process_transaction_delete_request(const char *databasePath, char *data) {
  String lit = NULL;
  cstring_assign(lit, data, strlen(data));
  StringVector transaction = NULL;
  cstring_split(lit, -1, ",", 1, transaction);

  int64_t transID = strtoll(transaction[0], NULL, 10);
  char *username = transaction[1];

  BackendController *b = createBackend(databasePath, username);
  c2dao_deleteTrans(b->globalDB, b->username, transID);
  freeBackend(b);
  process_transaction_list_request(databasePath, username);
  // This could be sped up if we knew whether the transaction was an expense
  process_expense_report_request(databasePath, username);
}

void process_transaction_list_request(const char *databasePath,
                                      const char *username) {
  int num_timestamps = 13;

  int64_t *timestamps = construct_timestamps(num_timestamps);
  BackendController *b = createBackend(databasePath, username);
  TransactionVector r =
      c2dao_queryTrans(b->globalDB, b->username, timestamps[0], timestamps[12]);
  fprintf(stderr, "Received %ld transactions for %s from %s to %s\n",
          cvector_size(r), username, intToString(timestamps[0]),
          intToString(timestamps[12]));
  String serial = transactionVectorToString(r);
  send_notification("kTransactionListNotification", serial);
}
