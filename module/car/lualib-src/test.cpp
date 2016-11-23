#include "Actor.h"

#ifdef __cplusplus
extern "C" {
#endif

#include <lua.h>
#include <lauxlib.h>

static int 
lnew_actor(lua_State *L)
{
	Actor *actor = new Actor();
	lua_pushlightuserdata(L, actor);
	return 1;
}

static int 
ltest(lua_State *L) {
	 Actor *actor = (Actor *)lua_touserdata(L, 1);
	 actor->test();
	 return 0;
}

int
luaopen_test(lua_State *L) {
	luaL_checkversion(L);
	luaL_Reg l[] = {
		{ "new_actor", lnew_actor },
		{ "test", ltest },
		{ NULL, NULL },
	};
	luaL_newlib(L,l);
	return 1;
}

#ifdef __cplusplus
}
#endif