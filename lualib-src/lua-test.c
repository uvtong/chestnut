
#include <lua.h>
#include <lauxlib.h>
#include <stdbool.h>

static int
ldispatch(lua_State *L) {
	return 0;
}

int
luaopen_test(lua_State *L) {
	luaL_checkversion(L);
	luaL_Reg l[] = {
		{ "dispatch", ldispatch },
		{ NULL, NULL },
	};
	luaL_newlib(L,l);
	return 1;
}