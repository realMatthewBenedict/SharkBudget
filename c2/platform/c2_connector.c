// c2_connector.c
static Dart_Port_DL flutter_port = 0;

void set_flutter_port(Dart_Port_DL port) {
    flutter_port = port;
}

void send_notification(const char* type, const char* sender, const char* data) {
    if (!flutter_port) return;

    Dart_CObject msg;
    msg.type = Dart_CObject_kString;
    msg.value.as_string = (char*)data;

    Dart_PostCObject_DL(flutter_port, &msg);
}