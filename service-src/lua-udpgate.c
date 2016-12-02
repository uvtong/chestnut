#include <lua.h>
#include <lauxlib.h>

#include "udpgate.h"

static int
lfree(lua_State *L) {
	if (lua_gettop(L) >= 1) {
		struct rudp_aux *aux = (struct rudp_aux *)lua_touserdata(L, 1);
		rudp_delete(aux->u);
		return 0;
	} else {
		luaL_error(L, "must be.");
		return 0;
	}
}

static int 
lalloc(lua_State *L) {
	struct rudp_aux *aux = (struct aoi_aux *)lua_newuserdata(L, sizeof(*aux));
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
		
		struct rudp *U = rudp_new(1, 5);
		aux->u = U;
		return 1;
	}
}

int
luaopen_rudpaux(lua_State *L) {
	luaL_checkversion(L);
	lua_newtable(L); // met
	luaL_Reg l[] = {
		{ "update", lupdate },
		{ "send", lsend },
		{ "recv", lrecv },
		{ NULL, NULL },
	};
	luaL_newlib(L,l);
	lua_setfield(L, -2, "__index");
	lua_pushcclosure(L, lfree, 0);
	lua_setfield(L, -2, "__gc");
	lua_pushcclosure(L, lnew, 1);
	return 1;
}