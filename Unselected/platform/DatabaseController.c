#include "DatabaseController.h"

void log_transaction(const Transaction *t, const char *action) {
  fprintf(stderr,
          "%s with username %s at unix time %lld, type %s, "
          "category %s, source %s, note %s, amount %lld cents\n",
          action, t->username, t->unix_time, t->type, t->category, t->source,
          t->note, t->amount_cents);
}

static bool tableExists(sqlite3 *db, const char *tableName) {
  sqlite3_stmt *stmt;
  const char *sql =
      "SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = ?";

  int rc = sqlite3_prepare_v2(db, sql, -1, &stmt, NULL);
  if (rc != SQLITE_OK)
    return 0;

  sqlite3_bind_text(stmt, 1, tableName, -1, SQLITE_STATIC);

  rc = sqlite3_step(stmt);
  sqlite3_finalize(stmt);

  return rc == SQLITE_ROW;
}

static void executeUnboundSQL(sqlite3 *db, const char *sql_literal,
                              const char *success, const char *fail) {
  char *errMsg = NULL;
  int retCode = sqlite3_exec(db, sql_literal, NULL, NULL, &errMsg);
  if (retCode == SQLITE_OK) {
    fprintf(stderr, "%s\n", success);
  } else {
    fprintf(stderr, "%s: %s\n", fail, errMsg);
    sqlite3_free(errMsg);
    sqlite3_close(db);
    abort();
  }
}

sqlite3 *c2dao_initDB(const char *databasePath) {
  // Creation
  sqlite3 *db;
  int retCode = sqlite3_open(databasePath, &db);
  if (retCode) {
    fprintf(stderr, "Can't open database at %s: %s\n", databasePath,
            sqlite3_errmsg(db));
    abort();
  } else {
    printf("Opened database successfully\n");
  }
  char *errMsg = NULL;
  /*
  executeUnboundSQL(db, "DROP TABLE users;", "Users dropped",
                    "SQL error when dropping users");
  executeUnboundSQL(db, "DROP TABLE transactions;", "Transactions dropped",
                    "SQL error when dropping transactions");
  */

  if (!tableExists(db, "users")) {
    char *user_sql = "CREATE TABLE users("
                     "username TEXT PRIMARY KEY NOT NULL,"
                     "password_hash TEXT);";
    executeUnboundSQL(db, user_sql, "Users table created",
                      "SQL error when creating users table");
  }

  if (!tableExists(db, "transactions")) {
    char *trans_sql = "CREATE TABLE transactions("
                      "ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
                      "username TEXT NOT NULL,"
                      "unix_time INTEGER,"
                      "type TEXT,"
                      "category TEXT,"
                      "source TEXT,"
                      "note TEXT,"
                      "amount_cents INTEGER,"
                      "FOREIGN KEY (username) REFERENCES users (username));";
    executeUnboundSQL(db, trans_sql, "Transactions table created",
                      "SQL error when creating transactions table");
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

void c2dao_insertUser(sqlite3 *db, const char *username,
                      const char *password_hash) {
  sqlite3_stmt *stmt;
  const char *sql = "INSERT INTO users (username, password_hash) "
                    "VALUES (?, ?)";
  int rc = sqlite3_prepare_v2(db, sql, -1, &stmt, NULL);
  if (rc != SQLITE_OK) {
    fprintf(stderr, "Insert user prepare failed: %s\n", sqlite3_errmsg(db));
    abort();
  }
  // Bind correctly by schema order
  bind_text_or_null(stmt, 1, username);
  bind_text_or_null(stmt, 2, password_hash);
  rc = sqlite3_step(stmt);
  if (rc != SQLITE_DONE) {
    fprintf(stderr, "Insert user step failed: %s\n", sqlite3_errmsg(db));
    sqlite3_finalize(stmt);
    abort();
  }

  sqlite3_finalize(stmt);
}

void c2dao_insertTrans(sqlite3 *db, const Transaction *t) {
  sqlite3_stmt *stmt;
  const char *sql =
      "INSERT INTO transactions (username, unix_time, type, category, "
      "source, note, amount_cents) "
      "VALUES (?, ?, ?, ?, ?, ?, ?)";

  int rc = sqlite3_prepare_v2(db, sql, -1, &stmt, NULL);
  if (rc != SQLITE_OK) {
    fprintf(stderr, "Insert transaction prepare failed: %s\n",
            sqlite3_errmsg(db));
    abort();
  }

  // Bind correctly by schema order (skip ID - autoincrement)
  bind_text_or_null(stmt, 1, t->username);
  sqlite3_bind_int64(stmt, 2, t->unix_time);
  bind_text_or_null(stmt, 3, t->type);
  bind_text_or_null(stmt, 4, t->category);
  bind_text_or_null(stmt, 5, t->source);
  bind_text_or_null(stmt, 6, t->note);
  sqlite3_bind_int64(stmt, 7, t->amount_cents);

  log_transaction(t, "Attempt to insert transaction");

  rc = sqlite3_step(stmt);
  if (rc != SQLITE_DONE) {
    fprintf(stderr, "Insert transaction step failed: %s\n", sqlite3_errmsg(db));
    sqlite3_finalize(stmt);
    abort();
  }

  sqlite3_finalize(stmt);
}

void c2dao_editTrans(sqlite3 *db, const char *username, int64_t id,
                     const char *note, int64_t amount_cents) {
  sqlite3_stmt *stmt;
  const char *sql = "UPDATE transactions "
                    "SET note = ?, amount_cents = ? "
                    "WHERE id = ? AND username = ?";

  int rc = sqlite3_prepare_v2(db, sql, -1, &stmt, NULL);
  if (rc != SQLITE_OK) {
    fprintf(stderr, "c2dao_editTrans prepare failed: %s\n", sqlite3_errmsg(db));
    abort();
  }

  bind_text_or_null(stmt, 1, note);
  sqlite3_bind_int64(stmt, 2, amount_cents);
  sqlite3_bind_int64(stmt, 3, id);
  bind_text_or_null(stmt, 4, username);

  rc = sqlite3_step(stmt);
  if (rc != SQLITE_DONE) {
    fprintf(stderr, "c2dao_editTrans step failed: %s\n", sqlite3_errmsg(db));
    abort();
  }
  sqlite3_finalize(stmt);
}

void c2dao_deleteTrans(sqlite3 *db, const char *username, int64_t id) {
  sqlite3_stmt *stmt;
  const char *sql = "DELETE FROM transactions WHERE id = ? AND username = ?";

  int rc = sqlite3_prepare_v2(db, sql, -1, &stmt, NULL);
  if (rc != SQLITE_OK) {
    fprintf(stderr, "Transaction delete prepare failed: %s\n",
            sqlite3_errmsg(db));
    abort();
  }

  sqlite3_bind_int64(stmt, 1, id);
  bind_text_or_null(stmt, 2, username);

  // Run the query
  rc = sqlite3_step(stmt);
  if (rc != SQLITE_DONE) {
    fprintf(stderr, "Transaction delete step failed: %s\n", sqlite3_errmsg(db));
    abort();
  }
  sqlite3_finalize(stmt);
}

bool c2dao_queryUser(sqlite3 *db, const char *username,
                     const char *password_hash) {
  sqlite3_stmt *stmt;
  const char *sql =
      "SELECT * FROM users WHERE username = ? AND password_hash = ?";

  int rc = sqlite3_prepare_v2(db, sql, -1, &stmt, NULL);
  if (rc != SQLITE_OK) {
    fprintf(stderr, "User login check prepare failed: %s\n",
            sqlite3_errmsg(db));
    return false;
  }

  bind_text_or_null(stmt, 1, username);
  bind_text_or_null(stmt, 2, password_hash);

  // Run the query
  rc = sqlite3_step(stmt);
  sqlite3_finalize(stmt);

  return rc == SQLITE_ROW;
}

TransactionVector c2dao_queryTrans(sqlite3 *db, const char *username,
                                   long long unix_start, long long unix_end) {
  sqlite3_stmt *stmt;
  const char *sql = "SELECT * FROM transactions "
                    "WHERE username = ? AND unix_time >= ? AND unix_time < ? "
                    "ORDER BY unix_time ASC";

  int rc = sqlite3_prepare_v2(db, sql, -1, &stmt, NULL);
  if (rc != SQLITE_OK) {
    fprintf(stderr, "Query prepare failed: %s\n", sqlite3_errmsg(db));
    sqlite3_close(db);
    abort();
  }

  bind_text_or_null(stmt, 1, username);
  sqlite3_bind_int64(stmt, 2, unix_start);
  sqlite3_bind_int64(stmt, 3, unix_end);

  TransactionVector results = NULL;
  while (sqlite3_step(stmt) == SQLITE_ROW) {
    Transaction *t = malloc(sizeof(Transaction));

    t->id = sqlite3_column_int64(stmt, 0);
    t->unix_time = sqlite3_column_int64(stmt, 2);
    t->amount_cents = sqlite3_column_int64(stmt, 7);

    // Copy TEXT columns correctly
    const char *text;
    int len;

    text = (const char *)sqlite3_column_text(stmt, 1);
    len = sqlite3_column_bytes(stmt, 1);
    t->username = text && len > 0 ? strdup(text) : NULL;

    text = (const char *)sqlite3_column_text(stmt, 3);
    len = sqlite3_column_bytes(stmt, 3);
    t->type = text && len > 0 ? strdup(text) : NULL;

    text = (const char *)sqlite3_column_text(stmt, 4);
    len = sqlite3_column_bytes(stmt, 4);
    t->category = text && len > 0 ? strdup(text) : NULL;

    text = (const char *)sqlite3_column_text(stmt, 5);
    len = sqlite3_column_bytes(stmt, 5);
    t->source = text && len > 0 ? strdup(text) : NULL;

    text = (const char *)sqlite3_column_text(stmt, 6);
    len = sqlite3_column_bytes(stmt, 6);
    t->note = text && len > 0 ? strdup(text) : NULL;

    cvector_push_back(results, t);
  }

  sqlite3_finalize(stmt);
  return results;
}

void c2dao_closeDB(sqlite3 *db) { sqlite3_close(db); }
