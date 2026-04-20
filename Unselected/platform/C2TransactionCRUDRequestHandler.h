#pragma once

void process_new_transaction_request(const char *databasePath, char *data);
void process_transaction_edit_request(const char *databasePath, char *data);
void process_transaction_delete_request(const char *databasePath, char *data);
void process_transaction_list_request(const char *databasePath,
                                      const char *username);
