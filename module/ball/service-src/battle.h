#ifndef ROOM_H
#define ROOM_H

#include <stdint.h>

struct battle_message {
	int dummy;
};

struct battle_message *
battle_message_alloc();

void
battle_message_free(struct room_message *self);

#endif