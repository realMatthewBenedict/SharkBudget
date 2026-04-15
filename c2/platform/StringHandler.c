#include "StringHandler.h"
#include <ctype.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>

char *toLower(char *s) {
  char *r = strdup(s);
  for (char *p = r; *p; p++) {
    *p = tolower(*p);
  }
  return r;
}

char *intToString(int64_t num) {
  char *str = malloc(32 * sizeof(char));
  if (!str)
    abort();
  sprintf(str, "%lld", num);
  str = realloc(str, strlen(str) + 1);
  return str;
}

String transactionToString(const Transaction *t) {
  StringVector v = NULL;
  char *id = intToString(t->id);
  char *unixTime = intToString(t->unix_time);
  char *amountCents = intToString(t->amount_cents);
  cstring_array_push_back(v, id, strlen(id));
  cstring_array_push_back(v, unixTime, strlen(unixTime));
  cstring_array_push_back(v, t->type, strlen(t->type));
  cstring_array_push_back(v, t->category, strlen(t->category));
  cstring_array_push_back(v, t->source, strlen(t->source));
  cstring_array_push_back(v, t->note, strlen(t->note));
  cstring_array_push_back(v, amountCents, strlen(amountCents));
  char *delimiter = ",";
  String str = NULL;
  cstring_array_join(v, delimiter, 1, str);
  return str;
}

String transactionVectorToString(TransactionVector v) {
  if (cvector_size(v) == 0)
    return "";
  StringVector r = NULL;
  for (int i = 0; i < cvector_size(v); ++i) {
    String j = transactionToString(v[i]);
    cstring_array_push_back(r, j, strlen(j));
  }
  char *delimiter = ",";
  String str = NULL;
  cstring_array_join(r, delimiter, 1, str);
  return str;
}

String intArrToString(int64_t num[static 1], int len) {
  if (len == 0)
    return "";
  StringVector v = NULL;
  for (int i = 0; i < len; ++i) {
    char *s = intToString(num[i]);
    cstring_array_push_back(v, s, strlen(s));
  }
  char *delimiter = ",";
  String str = NULL;
  cstring_array_join(v, delimiter, 1, str);
  return str;
}

String mergeArrayStrings(String a, String b) {
  String str = NULL;
  cstring_append(str, a, cstring_length(a));
  cstring_push_back(str, ',');
  cstring_append(str, b, cstring_length(b));
  return str;
}
