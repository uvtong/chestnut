#include "Actor.h"

#ifdef __cplusplus
extern "C" {
#endif

#include <lua.h>
#include <lauxlib.h>

struct test {
	Actor *actor;
};

static int 
ltest_alloc(lua_State *L) {
	return 0;
}

static int 
ltest_free(lua_State *L) {
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

#ifdef __cplusplus
}
#endif