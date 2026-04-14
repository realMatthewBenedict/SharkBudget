#include <stdlib.h>

#include "BackendController.h"
#include "C2Notification.h"
#include "C2CashFlowRequestHandler.h"
#include "string_handler.h"
#include "timestamps.h"

void process_cash_flow_request() {
    BackendController* b = malloc(sizeof(BackendController));
    int num_timestamps = 13;

    int64_t* timestamps = construct_timestamps(num_timestamps);
    int64_t* net_cash_flow = getNetCashFlowArray(b, timestamps, num_timestamps);
    int64_t* avg_cash_flow = avgCashFlow(timestamps, net_cash_flow, num_timestamps);

    String net = intArrToString(net_cash_flow, num_timestamps - 1);
    String avg = intArrToString(avg_cash_flow, 2);
    String result = mergeArrayStrings(net, avg);

    send_notification("kCashFlowNotification", result);
}