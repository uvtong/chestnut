#include "rudp.h"
#include <lua.h>
#include <lauxlib.h>

struct rudp_aux {
	lua_State *L;
	struct rudp *u;
	int session;
	char buffer[MAX_PACKAGE];
};

static int
lsend(lua_State *L) {
	struct rudp_aux *aux = (struct rudp_aux *)lua_touserdata(L, 1);
	size_t sz = 0;
	const char *buffer = luaL_checklstring(L, 2, &sz);
	rudp_send(aux->u, buffer, sz);
	return 0;
}

static int
lupdate(lua_State *L) {
	struct rudp_aux *aux = (struct rudp_aux *)lua_touserdata(L, 1);
	size_t sz = 0;
	const char *buffer = luaL_checklstring(L, 2, &sz);
	int tick = lua_tointeger(L, 3);
	
	lua_geti(L, LUA_REGISTRYINDEX, LUA_RIDX_GLOBALS);
	lua_rawgetp(L, -1, aux);
	lua_getfield(L, -1, "send");
	lua_getfield(L, -2, "recv");


	struct rudp_package *res = rudp_update(aux->u, buffer, sz, tick);
	while (res) {
		lua_pushvalue(L, -2);
		lua_pushlstring(L, res->buffer, res->sz);
		lua_pcall(L, 1, 0, 0);		
		res = res->next;
	}
	int n;
	while ((n = rudp_recv(aux->u, aux->buffer))) {
		if (n < 0) {
			break;
		}
		lua_pushvalue(L, -1);
		lua_pushlstring(L, aux->buffer, n);
		lua_pcall(L, 1, 0, 0);
	}
	return 0;
}

static int
lset_session(lua_State *L) {
	struct rudp_aux *aux = (struct rudp_aux *)lua_touserdata(L, 1);
	aux->session = lua_tointeger(L, 2);
	return 0;
}

static int
lget_session(lua_State *L) {
	struct rudp_aux *aux = (struct rudp_aux *)lua_touserdata(L, 1);
	lua_pushinteger(L, aux->session);
	return 1;
}

static int
ldelete(lua_State *L) {
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
lnew(lua_State *L) {
	struct rudp_aux *aux = (struct rudp_aux *)lua_newuserdata(L, sizeof(*aux));
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
		memset(aux->buffer, 0, MAX_PACKAGE);
		return 1;
	}
}

int
luaopen_rudpaux(lua_State *L) {
	luaL_checkversion(L);
	lua_newtable(L); // met
	luaL_Reg l[] = {
		{ "send", lsend },
		{ "update", lupdate },
		{ "set_session", lset_session },
		{ "get_session", lget_session },
		{ NULL, NULL },
	};
	luaL_newlib(L,l);
	lua_setfield(L, -2, "__index");
	lua_pushcclosure(L, ldelete, 0);
	lua_setfield(L, -2, "__gc");
	lua_pushcclosure(L, lnew, 1);
	return 1;
}