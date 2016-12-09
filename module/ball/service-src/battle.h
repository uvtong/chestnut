#ifndef BATTLE_H
#define BATTLE_H

#include <stdint.h>

struct battle_message {
	int dummy;
};

struct battle_rsp_message {
	int dummy;
};

struct battle_message *
battle_message_alloc();

void
battle_message_free(struct battle_message *self);

#endif