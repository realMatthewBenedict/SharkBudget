#include <sqlite3.h>
#include <stdlib.h>

typedef struct {
  sqlite3 *globalDB;
  const char *username;
} BackendController;

typedef struct {
  int64_t bills;
  int64_t food;
  int64_t housing;
  int64_t transport;
  int64_t other;
} ExpenseReport;

typedef struct {
  int64_t income;
  int64_t expense;
} BalanceReport;

BackendController *createBackend(const char *databasePath,
                                 const char *username);
void freeBackend(BackendController *b);

int64_t *getNetCashFlowArray(BackendController *b, int64_t timestamps[static 2],
                             int num_timestamps);
int64_t *avgCashFlow(int64_t timestamps[static 2], int64_t cash_flow[static 1],
                     int num_timestamps);
ExpenseReport *expenseBreakdown(BackendController *b, int64_t start_timestamp,
                                int64_t end_timestamp);
BalanceReport *balanceBreakdown(BackendController *b, int64_t start_timestamp,
                                int64_t end_timestamp);
