#ifndef BATTLE_MESSAGE_H
#define BATTLE_MESSAGE_H

struct battle_message {
	int    sz;
	char   cmd[16];
};

struct battle_start_message {
	int    sz;
	char   cmd[16];
};

struct battle_close_message {
	int    sz;
	char   cmd[16];
};

struct battle_kill_message {
	int    sz;
	char   cmd[16];	
};

struct battle_join_message {
	int    sz;
	char   cmd[16];		
};

struct battle_leave_message {
	int    sz;
	char   cmd[16];	
};

struct battle_opcode_message {
	int    sz;
	char   cmd[16];	
};

struct battle_update_message {
	int    sz;
	char   cmd[16];
	float  delta;	
};


#define size(x) (((struct battle_message *)(x))->sz)
#define cmd(x) (const char *)(((struct battle_message*)(x))->cmd)

#endif
