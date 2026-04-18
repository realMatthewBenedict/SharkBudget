#include "BackendController.h"
#include "C2Notification.h"
#include "StringHandler.h"
#include "TimeHandler.h"

void process_transaction_list_request(const char *databasePath,
                                      const char *username) {
  int num_timestamps = 13;

  int64_t *timestamps = construct_timestamps(num_timestamps);
  BackendController *b = createBackend(databasePath, username);
  TransactionVector r =
      c2dao_queryTrans(b->globalDB, b->username, timestamps[0], timestamps[12]);
  fprintf(stderr, "Received %ld transactions for %s from %lld to %lld\n",
          cvector_size(r), username, timestamps[0], timestamps[12]);
  String serial = transactionVectorToString(r);
  send_notification("kTransactionListNotification", serial);
}
