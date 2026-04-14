#include "DatabaseController.h"

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

static void bind_text_or_null(sqlite3_stmt *stmt, int index, const char *text) {
    if (text && text[0] != '\0') {
        sqlite3_bind_text(stmt, index, text, -1, SQLITE_TRANSIENT);
    } else {
        sqlite3_bind_null(stmt, index);
    }
}

void c2dao_insertDB(sqlite3* db, const Transaction* t) {
    sqlite3_stmt *stmt;
    const char *sql = "INSERT INTO transactions (unix_time, type, category, source, note, amount_cents) "
                      "VALUES (?, ?, ?, ?, ?, ?)";

    int rc = sqlite3_prepare_v2(db, sql, -1, &stmt, NULL);
    if (rc != SQLITE_OK) {
        fprintf(stderr, "Insert prepare failed: %s\n", sqlite3_errmsg(db));
        abort();
    }

    // Bind correctly by schema order (skip ID - autoincrement)
    sqlite3_bind_int64(stmt, 1, t->unix_time);

    bind_text_or_null(stmt, 2, t->type);
    bind_text_or_null(stmt, 3, t->category);
    bind_text_or_null(stmt, 4, t->source);
    bind_text_or_null(stmt, 5, t->note);

    sqlite3_bind_int64(stmt, 6, t->amount_cents);

    rc = sqlite3_step(stmt);
    if (rc != SQLITE_DONE) {
        fprintf(stderr, "Insert step failed: %s\n", sqlite3_errmsg(db));
        sqlite3_finalize(stmt);
        abort();
    }

    sqlite3_finalize(stmt);
}

TransactionVector c2dao_queryDB(sqlite3 *db, long long unix_start, long long unix_end) {
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

    TransactionVector results = NULL;
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        Transaction *t = malloc(sizeof(Transaction));

        t->id = sqlite3_column_int64(stmt, 0);
        t->unix_time = sqlite3_column_int64(stmt, 1);
        t->amount_cents = sqlite3_column_int64(stmt, 6);

        // Copy TEXT columns correctly
        const char *text;
        int len;

        text = (const char*)sqlite3_column_text(stmt, 2); len = sqlite3_column_bytes(stmt, 2);
        t->type = text && len > 0 ? strdup(text) : NULL;

        text = (const char*)sqlite3_column_text(stmt, 3); len = sqlite3_column_bytes(stmt, 3);
        t->category = text && len > 0 ? strdup(text) : NULL;

        text = (const char*)sqlite3_column_text(stmt, 4); len = sqlite3_column_bytes(stmt, 4);
        t->source = text && len > 0 ? strdup(text) : NULL;

        text = (const char*)sqlite3_column_text(stmt, 5); len = sqlite3_column_bytes(stmt, 5);
        t->note = text && len > 0 ? strdup(text) : NULL;

        cvector_push_back(results, t);
    }

    sqlite3_finalize(stmt);
    return results;
}

void c2dao_closeDB(sqlite3* db) {
    sqlite3_close(db);
}
