#include "BackendController.h"
#include "C2Notification.h"
#include "StringHandler.h"
#include "TimeHandler.h"

void process_transaction_list_request() {
  int num_timestamps = 13;

  int64_t *timestamps = construct_timestamps(num_timestamps);
  BackendController *b = createBackend();
  TransactionVector r =
      c2dao_queryTrans(b->globalDB, timestamps[0], timestamps[12]);
  String serial = transactionVectorToString(r);
  send_notification("kTransactionListNotification", serial);
}
