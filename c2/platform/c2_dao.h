#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sqlite3.h>

#include "third_party/cvector.h"

#include <ctype.h>

char* toLower(char* s) {
    char* r = strdup(s);
    for (char *p=r; *p; p++) {
        *p = tolower(*p);
    }
    return r;
}

typedef struct {
    int64_t id;           // INTEGER PRIMARY KEY
    int64_t unix_time;    // INTEGER
    char *type;             // TEXT
    char *category;         // TEXT
    char *source;           // TEXT
    char *note;             // TEXT
    int64_t amount_cents; // INTEGER
} Transaction;
typedef cvector_vector_type(Transaction*) TransactionVector;

sqlite3* c2dao_initDB();

void c2dao_insertDB(sqlite3* db, Transaction* t);

TransactionVector c2dao_queryDB(sqlite3* db, int64_t unix_start, int64_t unix_end);
