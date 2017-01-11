#ifndef BATTLE_MESSAGE_H
#define BATTLE_MESSAGE_H

#include "text_message.h"

struct battle_start_message {
	char   cmd[16];
};

struct battle_close_message {
	char   cmd[16];
};

struct battle_kill_message {
	char   cmd[16];	
}

struct battle_update_message {
	char   cmd[16];
	float  delta;	
}

#endif