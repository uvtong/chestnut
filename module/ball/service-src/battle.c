#include "battle_message.h"

#include "skynet.h"

#include <lua.h>
#include <lauxlib.h>

struct battle {
	lua_State *L;
	int dummy;
};

static int 
lalloc(lua_State *L) {
	struct battle *inst = lua_newuserdata(L, sizeof(*inst));
	if (inst == NULL) {
		luaL_error(L, "alloc failture.");
		return 0;
	} else {
		lua_pushvalue(L, lua_upvalueindex(1));
		lua_setmetatable(L, -2);
		inst->L = L;
		return 1;
	}
}

static int 
lfree(lua_State *L) {
	 return 0;
}

static int
lstart(lua_State *L) {
	return 0;
}

static int
lclose(lua_State *L) {
	return 0;
}

static int 
lkill(lua_State *L) {
	return 0;
}

static int
ljoin(lua_State *L) {
	return 0;
}

static int
lleave(lua_State *L) {
	return 0;
}

static int
lopcode(lua_State *L) {
	return 0;
}

static int
lupdate(lua_State *L) {
	return 0;
}

LUAMOD_API int
luaopen_room(lua_State *L) {
	luaL_checkversion(L);
	lua_newtable(L); // met
	luaL_Reg l[] = {
		{ "start", lstart },
		{ "close", lclose },
		{ "kill", lkill },
		{ "join", ljoin },
		{ "leave", lleave },
		{ "opcode", lopcode },
		{ "update", lupdate },
		{ NULL, NULL },
	};
	luaL_newlib(L,l);
	lua_setfield(L, -2, "__index");
	lua_pushcclosure(L, lfree, 0);
	lua_setfield(L, -2, "__gc");
	lua_pushcclosure(L, lalloc, 1);
	return 1;
}