import 'dart:js_interop';
import 'package:c2/c2_request_abstract.dart' as request_base;
import 'package:c2/c2_notification.dart';

@JS('dartHandleNotification')
external set dartHandleNotification(JSFunction value);

@JS('jsSendRequest')
external void jsSendRequest(JSString name, JSString data);

typedef NotificationCallback = void Function(String name, String data);

class C2Request extends request_base.C2RequestAbstract {
  C2Request() {
    _initNotificationCallback();
  }

  void _initNotificationCallback() {
    dartHandleNotification = ((JSString name, JSString data) {
      final n = name.toDart;
      final d = data.toDart;
      C2Notification.process(n, d);
    }).toJS;
  }

  @override
  void sendRequest(String name, String data) {
    jsSendRequest(name.toJS, data.toJS);
  }
}
