#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dart_api_dl.h>

#include "C2Notification.h"

// Callback types matching Dart
typedef void (*ProcessNotificationCallback)(void*);

DART_EXPORT intptr_t InitDartApiDL(void* data) {
    intptr_t result = Dart_InitializeApiDL(data);
    fprintf(stderr, "Dart_InitializeApiDL result: %ld\n", result);
    return result;
}

// Global state
static Dart_Port g_port = 0;

// Register Dart callback from Dart side
void register_notification_port(Dart_Port port) {
    g_port = port;
}

// Send notification to Dart
void send_notification(char* kNotificationName, char* message) {
    if (g_port == 0) {
        fprintf(stderr, "No Dart port registered\n");
        abort();
    }

    // Name as simple string
    Dart_CObject name_obj = {0};
    name_obj.type = Dart_CObject_kString;
    name_obj.value.as_string = strdup(kNotificationName);

    // Data as simple string
    Dart_CObject data_obj = {0};
    data_obj.type = Dart_CObject_kString;
    data_obj.value.as_string = strdup(message);

    // Array [name, data]
    Dart_CObject* arr[] = {&name_obj, &data_obj};
    Dart_CObject obj = {0};
    obj.type = Dart_CObject_kArray;
    obj.value.as_array.length = 2;
    obj.value.as_array.values = arr;

    bool success = Dart_PostCObject_DL(g_port, &obj);
    if (!success) {
        fprintf(stderr, "Failed to send notification: %s\n", kNotificationName);
        abort();
    }
    fprintf(stderr, "Sent notification: %s\n", kNotificationName);
}
