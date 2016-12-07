#include "room.h"
// #include "skynet_malloc.h"

extern void send(uint32_t handle, const char *cmd);

#include <lua.h>
#include <lauxlib.h>

struct context {
	lua_State *L;
	int dummy;
};

static int 
lroom_alloc(lua_State *L) {
	struct context *inst = lua_newuserdata(L, sizeof(*inst));
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
lroom_free(lua_State *L) {
	 return 0;
}

static int
lroom_send(lua_State *L) {
}

static int
lroom_request(lua_State *L) {
}

static int 
lroom_response(lua_State *L) {
}

int
luaopen_room(lua_State *L) {
	luaL_checkversion(L);
	lua_newtable(L); // met
	luaL_Reg l[] = {
		{ "send", lroom_send },
		{ NULL, NULL },
	};
	luaL_newlib(L,l);
	lua_setfield(L, -2, "__index");
	lua_pushcclosure(L, lroom_free, 0);
	lua_setfield(L, -2, "__gc");
	lua_pushcclosure(L, lroom_alloc, 1)
	return 1;
}