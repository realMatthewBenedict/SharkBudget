#include <stdlib.h>
#include <stdio.h>
#include "string_handler.h"

char* intToString(int64_t num) {
    char* str = malloc((int)((ceil(log10(num))+1)*sizeof(char)));
    sprintf(str, "%lld", num);
    return str;
}

String intArrToString(int64_t num[static 1], int len) {
    if (len == 0) return "";
    String str = NULL;
    for (int i = 0; i < len; ++i) {
        char* s = intToString(num[i]);
        cstring_append(str, s, strlen(s));
        cstring_push_back(str, ',');
    }
    cstring_pop_back(str);
    return str;
}

String mergeArrayStrings(String a, String b) {
    cstring_string_type(type) str = NULL;
    cstring_append(str, a, cstring_length(a));
    cstring_push_back(str, ',');
    cstring_append(str, b, cstring_length(b));
    return str;
}