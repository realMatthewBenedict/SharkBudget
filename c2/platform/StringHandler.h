#include "third_party/cstring.h"

typedef cstring_string_type(char) String;

char* toLower(char* s);
char* intToString(int64_t num);
String intArrToString(int64_t num[static 1], int len);
String mergeArrayStrings(String a, String b);
