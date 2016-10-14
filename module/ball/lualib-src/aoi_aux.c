

#include "aoi.h"

#include <lua.h>
#include <lauxlib.h>
#include <stdlib.h>

struct alloc_cookie {
	int count;
	int max;
	int current;
};

struct aoi_aux
{
	struct lua_State *L;
	struct aoi_space *space;
	struct alloc_cookie cookie;
};

static void	
message(void *ud, uint32_t watcher, uint32_t marker) {
	struct aoi_aux *aux = (struct aoi_aux *)(ud);
	struct lua_State *L = aux->L;
	lua_rawgetp(L, LUA_RIDX_GLOBALS, aux);
	lua_getfield(L, -1, "aoi_Callback");
	lua_pushinteger(L, watcher);
	lua_pushinteger(L, marker);
	lua_pcall(L, 2, 0, 0);
	return;
}

static void *
my_alloc(void * ud, void *ptr, size_t sz) {
	struct aoi_aux *aux = ud;
	struct alloc_cookie * cookie = &aux->cookie;
	if (ptr == NULL) {
		void *p = malloc(sz);
		++ cookie->count;
		cookie->current += sz;
		if (cookie->max < cookie->current) {
			cookie->max = cookie->current;
		}
//		printf("%p + %u\n",p, sz);
		return p;
	}
	-- cookie->count;
	cookie->current -= sz;
//	printf("%p - %u \n",ptr, sz);
	free(ptr);
	return NULL;
}

static int 
lnew(lua_State *L)
{
	luaL_checktype(L, 1, LUA_TFUNCTION);

	struct aoi_aux *aux = (struct aoi_aux *)malloc(sizeof(struct aoi_aux));
	aux->L = L;
	lua_newtable(L);
	lua_pushvalue(L, -1);
	lua_rawsetp(L, LUA_RIDX_GLOBALS, aux);
	lua_pushvalue(L, 1);
	lua_setfield(L, -2, "aoi_Callback");

	struct alloc_cookie cookie = {0, 0, 0};
	aux->cookie = cookie;
	struct aoi_space *space = aoi_create(my_alloc, &aux->cookie);
	aux->space = space;
	aoi_message(space, message, NULL);
	lua_pushlightuserdata(L, aux);
	return 1;
}

static int
lrelease(lua_State *L)
{
	if (lua_gettop(L) >= 1)
	{
		/* code */
		struct aoi_aux *aux = (struct aoi_aux *)lua_touserdata(L, 1);
		struct aoi_space *space = aux->space;
		aoi_release(space);
		free(aux);
		return 0;
	} else {
		luaL_error(L, "must be.");
		return 0;
	}
}

static int 
lupdate(lua_State *L) {
	struct aoi_aux *aux = (struct aoi_aux *)lua_touserdata(L, 1);
	struct aoi_space *space = aux->space;
	lua_Integer id = luaL_checkinteger(L, 2);
	const char *m = luaL_checkstring(L, 3);
	lua_Number x = luaL_checknumber(L, 4);
	lua_Number y = luaL_checknumber(L, 5);
	lua_Number z = luaL_checknumber(L, 6);
	float pos[3] = {x, y, z};
	aoi_update(space, id, m, pos);
	return 0;
}

static int 
lmessage(lua_State *L) {
	struct aoi_aux *aux = (struct aoi_aux *)lua_touserdata(L, 1);
	// struct aoi_space *space = aux->space;
	luaL_checktype(L, 2, LUA_TFUNCTION);
	lua_rawgetp(L, LUA_RIDX_GLOBALS, aux);
	lua_pushvalue(L, 2);
	lua_setfield(L, -2, "aoi_Callback");
	return 0;
}

int
luaopen_aoiaux(lua_State *L) {
	luaL_checkversion(L);
	luaL_Reg l[] = {
		{ "new", lnew },
		{ "release", lrelease },
		{ "update", lupdate },
		{ "message", lmessage },
		{ NULL, NULL },
	};
	luaL_newlib(L,l);
	return 1;
}