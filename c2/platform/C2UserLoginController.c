#include "BackendController.h"
#include "C2Notification.h"
#include "StringHandler.h"

void process_user_signup_request(const char *databasePath, char *data) {
  String lit = NULL;
  cstring_assign(lit, data, strlen(data));
  StringVector credentials = NULL;
  cstring_split(lit, -1, ",", 1, credentials);
  const char *username = credentials[0];
  const char *password_hash = credentials[1];

  BackendController *b = createBackend(databasePath, username);
  c2dao_insertUser(b->globalDB, username, password_hash);
  freeBackend(b);
  send_notification("kUserSignupNotification", "");
}

void process_user_login_request(const char *databasePath, char *data) {
  String lit = NULL;
  cstring_assign(lit, data, strlen(data));
  StringVector credentials = NULL;
  cstring_split(lit, -1, ",", 1, credentials);
  const char *username = credentials[0];
  const char *password_hash = credentials[1];

  BackendController *b = createBackend(databasePath, username);
  bool result = c2dao_queryUser(b->globalDB, username, password_hash);
  freeBackend(b);
  send_notification("kUserLoginNotification", result ? "1" : "0");
}
