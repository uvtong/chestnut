#include "rudp.h"

struct rudp_aux {
	lua_State *L;
	struct rudp *u;
	buffer[MAX_PACKAGE];
};

static int
lsend(lua_State *L) {
	struct rudp_aux *aux = (struct rudp_aux *)lua_touserdata(L, 1);
	size_t sz = 0
	const char *buffer = luaL_checklstring(L, 2, &sz);
	if (sz > 0) {
		rudp_send(aux->u, buffer, sz);
	}
}

static int
lupdate(lua_State *L) {
	struct rudp_aux *aux = (struct rudp_aux *)lua_touserdata(L, 1);
	luaL_checktype(L, 2, LUA_TTABLE);
	if (lua_isnoneornil(L, 3)) {
		lua_Integer tick = luaL_checkinteger(L, 4);
		struct rudp_package *pack = rudp_update(aux->u, NULL, 0, tick);
		while (pack != NULL) {
			lua_geti(L, LUA_REGISTRYINDEX, LUA_RIDX_GLOBALS);
			lua_rawgetp(L, -1, aux);
			lua_getfield(L, -1, "send");
			lua_pushvalue(L, 2);
			lua_pushlstring(L, pack->buffer, pack->sz);
			lua_pcall(L, 2, 0, 0);
			pack = pack->next;
		}
	} else {
		size_t sz = 0;
		const char * str = luaL_checklstring(L, 3, &sz);
		lua_Integer tick = luaL_checkinteger(L, 4);
		struct rudp_package *pack = rudp_update(aux->u, str, sz, tick);
		while (pack != NULL) {
			lua_geti(L, LUA_REGISTRYINDEX, LUA_RIDX_GLOBALS);
			lua_rawgetp(L, -1, aux);
			lua_getfield(L, -1, "send");
			lua_pushvalue(L, 2);
			lua_pushlstring(L, pack->buffer, pack->sz);
			lua_pcall(L, 2, 0, 0);
			pack = pack->next;
		}
		while (rudp_recv(aux->u, aux->buffer) > 0) {
			lua_geti(L, LUA_REGISTRYINDEX, LUA_RIDX_GLOBALS);
			lua_rawgetp(L, -1, aux);
			lua_getfield(L, -1, "recv");
			lua_pushvalue(L, 2);
			lua_pushlstring(L, pack->buffer, pack->sz);
			lua_pcall(L, 2, 0, 0);
		}
	}
	return 0;
}

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
		lua_pushvalue(L, 1);
		lua_setfield(L, -2, "send");
		lua_pushvalue(L, 2);
		lua_setfield(L, -2, "recv");
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
		{ NULL, NULL },
	};
	luaL_newlib(L,l);
	lua_setfield(L, -2, "__index");
	lua_pushcclosure(L, lrelease, 0);
	lua_setfield(L, -2, "__gc");
	lua_pushcclosure(L, lalloc, 1);
	return 1;
}