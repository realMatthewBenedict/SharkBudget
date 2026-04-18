#include <stdio.h>

#include "BackendController.h"
#include "C2TransactionListRequestHandler.h"
#include "StringHandler.h"

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
}
