#pragma once

typedef struct {
  char *name;
  char *data;
} Message;

void process_request(Message request);
