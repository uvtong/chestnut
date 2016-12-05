#include <lua.h>
#include <lauxlib.h>

static int
ldebug(struct lua_Debug *ar) {
	return 1
}

int
luaopen_debug(lua_State *L) {
	luaL_checkversion(L);
	luaL_Reg l[] = {
		{ "send", lsend },
		{ "update", lupdate },
		{ "set_id", lset_id },
		{ "get_id", lget_id },
		{ NULL, NULL },
	};
	luaL_newlib(L,l);
	return 1;
}