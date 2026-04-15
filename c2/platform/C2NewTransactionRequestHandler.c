#include <stdio.h>

#include "BackendController.h"
#include "C2TransactionListRequestHandler.h"
#include "StringHandler.h"

void process_new_transaction_request(char *data) {
  String lit = NULL;
  cstring_assign(lit, data, strlen(data));
  StringVector transaction = NULL;
  cstring_split(lit, -1, ",", 1, transaction);

  Transaction t = {.id = 0,
                   .unix_time = strtoll(transaction[0], NULL, 10),
                   .type = transaction[1],
                   .category = transaction[2],
                   .source = transaction[3],
                   .note = transaction[4],
                   .amount_cents = strtoll(transaction[5], NULL, 10)};
  BackendController *b = createBackend();
  c2dao_insertTrans(b->globalDB, &t);
  freeBackend(b);
  process_transaction_list_request();
}
