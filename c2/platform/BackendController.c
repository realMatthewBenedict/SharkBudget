#include "BackendController.h"
#include "StringHandler.h"

BackendController *createBackend(const char *databasePath,
                                 const char *username) {
  BackendController *b = malloc(sizeof(BackendController));
  b->globalDB = c2dao_initDB(databasePath);
  b->username = strdup(username);
  return b;
}

void freeBackend(BackendController *b) {
  c2dao_closeDB(b->globalDB);
  b->globalDB = NULL;
}

static int64_t getNetCashFlow(BackendController *b, int64_t start_timestamp,
                              int64_t end_timestamp) {
  TransactionVector v = c2dao_queryTrans(b->globalDB, b->username,
                                         start_timestamp, end_timestamp);
  int result_cents = 0; // income - expense
  for (int i = 0; i < cvector_size(v); ++i) {
    Transaction *t = v[i];
    if (strcmp(t->type, "Expense") == 0) {
      result_cents -= t->amount_cents;
    } else if (strcmp(t->type, "Income") == 0) {
      result_cents += t->amount_cents;
    } else {
      printf("Unsupported transaction type: %s", t->type);
    }
  }
  return result_cents;
}

int64_t *getNetCashFlowArray(BackendController *b, int64_t timestamps[static 2],
                             int num_timestamps) {
  int64_t *result = malloc((num_timestamps - 1) * sizeof(int64_t));
  for (int i = 0; i < num_timestamps - 1; ++i) {
    result[i] = getNetCashFlow(b, timestamps[i], timestamps[i + 1]);
  }
  return result;
}

int64_t *avgCashFlow(int64_t timestamps[static 2], int64_t cash_flow[static 1],
                     int num_timestamps) {
  int64_t weighted_sum = 0;
  int64_t sum_weights = timestamps[num_timestamps - 1] - timestamps[0];

  for (int i = 0; i < num_timestamps - 1; ++i) {
    weighted_sum += (timestamps[i + 1] - timestamps[i]) * cash_flow[i];
  }

  int64_t *result = malloc(2 * sizeof(int64_t));
  result[0] = weighted_sum;
  result[1] = sum_weights;
  return result;
}

ExpenseReport *expenseBreakdown(BackendController *b, int64_t start_timestamp,
                                int64_t end_timestamp) {
  TransactionVector v = c2dao_queryTrans(b->globalDB, b->username,
                                         start_timestamp, end_timestamp);
  ExpenseReport *result = malloc(sizeof(ExpenseReport));
  for (int i = 0; i < cvector_size(v); ++i) {
    Transaction *t = v[i];
    if (strcmp(t->type, "Expense") != 0) {
      continue;
    }
    char *cat = toLower(t->category);
    if (strcmp(cat, "bills") == 0) {
      result->bills += t->amount_cents;
    } else if (strcmp(cat, "food") == 0) {
      result->food += t->amount_cents;
    } else if (strcmp(cat, "housing") == 0) {
      result->housing += t->amount_cents;
    } else if (strcmp(cat, "transport") == 0) {
      result->transport += t->amount_cents;
    } else {
      result->other += t->amount_cents;
    }
  }
  return result;
}
