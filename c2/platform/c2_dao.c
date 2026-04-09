#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sqlite3.h>

#include "cvector.h"

struct Transaction {
    char* date;
    char* type;
    char* category;
    char* source;
    char* note;
    char* amount;
};
typedef cvector_vector_type(Transaction*) TransactionVector;

sqlite3* c2dao_initDB() {
    // Creation
    sqlite3* db;
    int retCode = sqlite3_open("shark_transactions.db", &db);
    if (retCode) {
        fprintf(stderr, "Can't open database: %s\n", sqlite3_errmsg(db));
        abort();
    } else {
        printf("Opened database successfully\n");
    }

    char *sql = "CREATE TABLE IF NOT EXISTS transactions("
                "ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
                "date TEXT,"
                "type TEXT,"
                "category TEXT,"
                "source TEXT,"
                "note TEXT,"
                "amount TEXT);";
    char *errMsg = NULL;

    retCode = sqlite3_exec(db, sql, NULL, NULL, &errMsg);
    if (retCode == SQLITE_OK) {
        printf("Database initialized\n");
    } else {
        fprintf(stderr, "SQL error when creating table: %s\n", errMsg);
        sqlite3_free(errMsg);
        sqlite3_close(db);
        abort();
    }
    return db;
}

void c2dao_insertDB(sqlite3* db, Transaction* t) {
    const char *sql = "INSERT INTO transactions (ID, date, type, category, source, note, amount) "  \
         "VALUES (?, ?, ?, ?, ?, ?, ?)";
    rc = sqlite3_prepare_v2(db, sql, -1, &stmt, NULL);
    if (rc != SQLITE_OK) {
        sqlite3_close(db);
        abort();
    }

    sqlite3_bind_text(stmt, 1, t->date, strlen(t->date), SQLITE_TRANSIENT);
    sqlite3_bind_text(stmt, 2, t->type, strlen(t->type), SQLITE_TRANSIENT);
    sqlite3_bind_text(stmt, 3, t->category, strlen(t->category), SQLITE_TRANSIENT);
    sqlite3_bind_text(stmt, 4, t->source, strlen(t->source), SQLITE_TRANSIENT);
    sqlite3_bind_text(stmt, 5, t->note, strlen(t->note), SQLITE_TRANSIENT);
    sqlite3_bind_text(stmt, 6, t->amount, strlen(t->amount), SQLITE_TRANSIENT);
    rc = sqlite3_step(stmt);
    if (rc != SQLITE_DONE) {
        sqlite3_close(db);
        abort();
    }

    sqlite3_finalize(stmt);
}

TransactionVector c2dao_queryDB(sqlite3* db) {
    const char *sql = "SELECT * FROM transactions";
    rc = sqlite3_prepare_v2(db, sql, -1, &stmt, NULL);
    if (rc != SQLITE_OK) {
        fprintf(stderr, "Prepare failed: %s\n", sqlite3_errmsg(db));
        sqlite3_close(db);
        abort();
    }

    // Results
    TransactionVector results = NULL;
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        const char *date = (const char*)sqlite3_column_text(stmt, 0);
        const char *type = (const char*)sqlite3_column_text(stmt, 1);
        const char *category = (const char*)sqlite3_column_text(stmt, 2);
        const char *source = (const char*)sqlite3_column_text(stmt, 3);
        const char *note = (const char*)sqlite3_column_text(stmt, 4);
        const char *amount = (const char*)sqlite3_column_text(stmt, 5);

        Transaction *t = {.date = date, .type = type, .category = category, .source = source, .note = note, .amount = amount};

        cvector_push_back(results, t);
    }

    sqlite3_finalize(stmt);
    return results;
}

/*
// Example usage
int main(int argc, const char **argv) {
    // Initialization
    sqlite3 *db = c2dao_initDB();

    // c2dao_insertDB calls here, etc.

    //Cleanup
    printf("Closing the database\n");
    sqlite3_close(db);
    db = NULL;

    return EXIT_SUCCESS;
}
 */