#include <ctype.h>
#include <math.h>
#include <stdlib.h>
#include <stdio.h>
#include "StringHandler.h"

char* toLower(char* s) {
    char* r = strdup(s);
    for (char *p=r; *p; p++) {
        *p = tolower(*p);
    }
    return r;
}

char* intToString(int64_t num) {
    char* str = malloc(32 * sizeof(char));
    if (!str) abort();
    sprintf(str, "%lld", num);
    str = realloc(str, strlen(str) + 1);
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
    String str = NULL;
    cstring_append(str, a, cstring_length(a));
    cstring_push_back(str, ',');
    cstring_append(str, b, cstring_length(b));
    return str;
}
