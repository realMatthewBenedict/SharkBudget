#include "c2_dao.h"

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
                "unix_time INTEGER,"
                "type TEXT,"
                "category TEXT,"
                "source TEXT,"
                "note TEXT,"
                "amount_cents INTEGER);";
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

TransactionVector c2dao_queryDB(sqlite3* db, long long unix_start, long long unix_end) {
    sqlite3_stmt *stmt;
    const char *sql = "SELECT * FROM transactions "
                      "WHERE unix_time >= ? AND unix_time < ? "
                      "ORDER BY unix_time ASC";

    int rc = sqlite3_prepare_v2(db, sql, -1, &stmt, NULL);
    if (rc != SQLITE_OK) {
        fprintf(stderr, "Prepare failed: %s\n", sqlite3_errmsg(db));
        sqlite3_close(db);
        abort();
    }

    sqlite3_bind_int64(stmt, 1, unix_start);
    sqlite3_bind_int64(stmt, 2, unix_end);

    // Results
    TransactionVector results = NULL;
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        Transaction t = {
                .id = sqlite3_column_int64(stmt, 0),
                .unix_time = sqlite3_column_int64(stmt, 1),
                .type = strdup(sqlite3_column_bytes(stmt, 2)),
                .category = strdup(sqlite3_column_bytes(stmt, 3)),
                .source = strdup(sqlite3_column_bytes(stmt, 4)),
                .note = strdup(sqlite3_column_bytes(stmt, 5)),
                .amount_cents = sqlite3_column_int64(stmt, 6)
        };
        cvector_push_back(results, t);
    }

    sqlite3_finalize(stmt);
    return results;
}

void c2dao_closeDB(sqlite3* db) {
    sqlite3_close(db);
}
