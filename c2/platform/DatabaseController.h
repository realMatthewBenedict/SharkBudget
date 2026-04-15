#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sqlite3.h>

#include "third_party/cvector.h"

#include <ctype.h>

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

void c2dao_insertTrans(sqlite3* db, const Transaction* t);

TransactionVector c2dao_queryTrans(sqlite3* db, int64_t unix_start, int64_t unix_end);

void c2dao_closeDB(sqlite3* db);
