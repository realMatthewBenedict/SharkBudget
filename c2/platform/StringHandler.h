#include "DatabaseController.h"
#include "third_party/cstring.h"

typedef cstring_string_type(char) String;
typedef cstring_array_type(char) StringVector;

char *toLower(char *s);
char *intToString(int64_t num);
String transactionToString(const Transaction *t);
String transactionVectorToString(TransactionVector t);
String intArrToString(int64_t num[static 1], int len);
String mergeArrayStrings(String a, String b);
