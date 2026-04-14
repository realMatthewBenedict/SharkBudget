#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <dart_api_dl.h>

#include "C2Notification.h"

// Callback types matching Dart
typedef void (*ProcessNotificationCallback)(Message*);

// Global state
static ProcessNotificationCallback g_callback = NULL;
static Dart_Port g_port = 0;

// Register Dart callback from Dart side
void register_notification_callback(ProcessNotificationCallback callback, Dart_Port port) {
    g_callback = callback;
    g_port = port;
}

// Send notification to Dart
void send_notification(char* kNotificationName, char* message) {
    if (!g_callback) {
        fprintf(stderr, "No Dart callback registered\n");
        return;
    }

    Message m = {kNotificationName, message};
    g_callback(&m);
}
