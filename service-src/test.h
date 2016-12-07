#include <stdbool.h>

struct test_message {
	char cmd[16];
	int  dummy;
};

void *
pack(const char *cmd, void *ud, int *sz);

bool
unpack(void *msg, int sz, void *ud);

void
dispatch();