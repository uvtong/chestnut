#include "udpgate_message.h"

#include <lua.h>
#include <lauxlib.h>

struct udpgate {
	lua_State *L;
	int dummy;
};

static int
lfree(lua_State *L) {
	if (lua_gettop(L) >= 1) {
		struct udpgate *aux = (struct udpgate *)lua_touserdata(L, 1);
		return 0;
	} else {
		luaL_error(L, "must be.");
		return 0;
	}
}

static int 
lalloc(lua_State *L) {
	struct udpgate *aux = (struct udpgate *)lua_newuserdata(L, sizeof(*aux));
	if (aux == NULL) {
		printf("%s\n", "malloc failture.");
		return 0;
	} else {
		lua_pushvalue(L, lua_upvalueindex(1));
		lua_setmetatable(L, -2);

		aux->L = L;
		lua_geti(L, LUA_REGISTRYINDEX, LUA_RIDX_GLOBALS);
		lua_newtable(L);
		lua_rawsetp(L, -2, aux);
		lua_pop(L, 1);
		
		return 1;
	}
}

int
luaopen_udpgate(lua_State *L) {
	luaL_checkversion(L);
	lua_newtable(L); // met
	luaL_Reg l[] = {
		{ NULL, NULL },
	};
	luaL_newlib(L,l);
	lua_setfield(L, -2, "__index");
	lua_pushcclosure(L, lfree, 0);
	lua_setfield(L, -2, "__gc");
	lua_pushcclosure(L, lalloc, 1);
	return 1;
}
