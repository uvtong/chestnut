#include "room.h"

extern void send(uint32_t handle, const char *cmd);

#include <lua.h>
#include <lauxlib.h>

struct room {
	Actor *actor;
};

static int 
lroom_alloc(lua_State *L) {
	return 0;
}

static int 
lroom_free(lua_State *L) {
	 return 0;
}

int
luaopen_test(lua_State *L) {
	luaL_checkversion(L);
	luaL_Reg l[] = {
		{ "alloc", ltest_alloc },
		{ "free", ltest_free },
		{ NULL, NULL },
	};
	luaL_newlib(L,l);
	return 1;
}