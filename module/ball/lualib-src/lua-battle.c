#include "battle.h"

#include "skynet.h"
#include "skynet_handle.h"

#include <lua.h>
#include <lauxlib.h>

#include <stdbool.h>
#include <string.h>
#include <assert.h>


static int
lbattle_alloc(lua_State *L) {
	return 0;
}

static int
lbattle_free(lua_State *L) {
	return 0;
}

static int
lbattle_update(lua_State *L) {
	return 0;
}

int
luaopen_battle(lua_State *L) {
	luaL_checkversion(L);
	lua_newtable(L); // met
	luaL_Reg l[] = {
		{ "update", lbattle_update },
		{ NULL, NULL },
	};
	luaL_newlib(L,l);
	lua_setfield(L, -2, "__index");
	lua_pushcclosure(L, lbattle_free, 0);
	lua_setfield(L, -2, "__gc");
	lua_pushcclosure(L, lbattle_alloc, 1);
	return 1;
}