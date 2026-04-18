#include <ctype.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sqlite3.h>

#include "third_party/cvector.h"

typedef struct {
    int64_t id;           // INTEGER PRIMARY KEY
    char *username;       // TEXT
    int64_t unix_time;    // INTEGER
    char *type;           // TEXT
    char *category;       // TEXT
    char *source;         // TEXT
    char *note;           // TEXT
    int64_t amount_cents; // INTEGER
} Transaction;
typedef cvector_vector_type(Transaction*) TransactionVector;

void log_transaction(const Transaction* t, const char* action);

sqlite3* c2dao_initDB(const char* databasePath);

void c2dao_insertUser(sqlite3 *db, const char* username, const char* password_hash);
void c2dao_insertTrans(sqlite3* db, const Transaction* t);

bool c2dao_queryUser(sqlite3 *db, const char *username, const char *password_hash);
TransactionVector c2dao_queryTrans(sqlite3* db, const char* username, int64_t unix_start, int64_t unix_end);

void c2dao_closeDB(sqlite3* db);
