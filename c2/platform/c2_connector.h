#include "dart_api_dl.h"  // Dart SDK header

typedef struct {
    Dart_Port_DL dart_port;  // Flutter callback port
    char* message_type;
    char* sender;
    char* data;
} C2Message;

void set_flutter_port(Dart_Port_DL port);  // Set Dart port for notifications
void send_notification(const char* type, const char* sender, const char* data);