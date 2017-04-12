#include <lua.h>
#include <lauxlib.h>

static int
ldebug(struct lua_Debug *ar) {
	return 0;
}

int
luaopen_debug(lua_State *L) {
	luaL_checkversion(L);
	luaL_Reg l[] = {
		{ "debug", ldebug },
		{ NULL, NULL },
	};
	luaL_newlib(L,l);
	return 1;
}