#define LUA_LIB

#include "CCAABB.h"

#ifdef __cplusplus
extern "C" {
#endif

#include <lua.h>
#include <lauxlib.h>

struct aabb_aux {
	AABB *aabb;
};

static int
laabb_new(lua_State *L) {
	if (lua_gettop(L) == 1) {
		// AABB *aabb = (AABB *)lua_touserdata(L, 1);
		lua_error(L);
		return 0;
	} else {
		struct vector3 *min = (struct vector3 *)lua_touserdata(L, 1);
		struct vector3 *max = (struct vector3 *)lua_touserdata(L, 2);
		struct aabb_aux *aux = (struct aabb_aux *)lua_newuserdata(L, sizeof(*aux));
		AABB *aabb = new AABB(*min, *max);
		aux->aabb = aabb;
		lua_pushvalue(L, lua_upvalueindex(1));
		lua_setmetatable(L, -2);
		return 1;	
	}
}

static int 
laabb_release(lua_State *L) {
	struct aabb_aux *aux = (struct aabb_aux *)lua_touserdata(L, 1);
	AABB *aabb = aux->aabb;
	delete aabb;
	return 0;
}

static int 
laabb_getCenter(lua_State *L) {
	struct aabb_aux *aux = (struct aabb_aux *)lua_touserdata(L, 1);
	AABB *aabb = (AABB *)aux->aabb;
	struct vector3 *res = (struct vector3 *)lua_touserdata(L, 2);
	struct vector3 center = aabb->getCenter();
	*res = center;
	return 0;
}

static int 
laabb_getCorners(lua_State *L) {
	struct aabb_aux *aux = (struct aabb_aux *)lua_touserdata(L, 1);
	AABB *aabb = (AABB *)aux->aabb;
	luaL_checktype(L, 2, LUA_TTABLE);
	lua_len(L, 2);
	if (luaL_checkinteger(L, -1) != 8) {
		lua_error(L);
	}
	lua_pop(L, 1);
	struct vector3 dst[8];
	aabb->getCorners(dst);

	int idx = 0;
	lua_pushnil(L);
	while (lua_next(L, -2) != 0) {
		struct vector3 *v = (struct vector3 *)lua_touserdata(L, -1);
		v->x = dst[idx].x;
		v->y = dst[idx].y;
		v->z = dst[idx].z;
		lua_pop(L, 1);
		idx++;
	}
	return 0;
}

static int
laabb_intersects(lua_State *L) {
	struct aabb_aux *aux = (struct aabb_aux *)lua_touserdata(L, 1);
	AABB *aabb = (AABB *)aux->aabb;
	struct aabb_aux *other_aux = (struct aabb_aux *)lua_touserdata(L, 2);
	AABB *other = (AABB *)other_aux->aabb;
	bool b = aabb->intersects(*other);
	if (b) {
		lua_pushboolean(L, 1);	
		return 1;
	} else {
		lua_pushboolean(L, 0);
		return 1;
	}
}

static int 
laabb_containPoint(lua_State *L) {
	struct aabb_aux *aux = (struct aabb_aux *)lua_touserdata(L, 1);
	AABB *aabb = (AABB *)aux->aabb;
	struct vector3 *point = (struct vector3 *)lua_touserdata(L, 2);
	bool b = aabb->containPoint(*point);
	if (b) {
		lua_pushboolean(L, 1);	
		return 1;
	} else {
		lua_pushboolean(L, 0);
		return 1;
	}
}

static int
laabb_merge(lua_State *L) {
	struct aabb_aux *aux = (struct aabb_aux *)lua_touserdata(L, 1);
	AABB *aabb = (AABB *)aux->aabb;
	struct aabb_aux *other_aux = (struct aabb_aux *)lua_touserdata(L, 2);
	AABB *other = (AABB *)other_aux->aabb;
	aabb->merge(*other);
	return 0;
}

static int 
laabb_set(lua_State *L) {
	struct aabb_aux *aux = (struct aabb_aux *)lua_touserdata(L, 1);
	AABB *aabb = (AABB *)aux->aabb;
	struct vector3 *min = (struct vector3 *)lua_touserdata(L, 2);
	struct vector3 *max = (struct vector3 *)lua_touserdata(L, 3);
	aabb->set(*min, *max);
	return 0;
}

static int 
laabb_reset(lua_State *L) {
	struct aabb_aux *aux = (struct aabb_aux *)lua_touserdata(L, 1);
	AABB *aabb = (AABB *)aux->aabb;
	aabb->reset();
	return 0;
}

static int 
laabb_isEmpty(lua_State *L) {
	struct aabb_aux *aux = (struct aabb_aux *)lua_touserdata(L, 1);
	AABB *aabb = (AABB *)aux->aabb;
	bool b = aabb->isEmpty();
	if (b) {
		lua_pushboolean(L, 1);	
		return 1;
	} else {
		lua_pushboolean(L, 0);
		return 1;
	}
}

static int 
laabb_updateMinMax(lua_State *L) {
	struct aabb_aux *aux = (struct aabb_aux *)lua_touserdata(L, 1);
	AABB *aabb = (AABB *)aux->aabb;
	luaL_checktype(L, 2, LUA_TTABLE);
	lua_len(L, 2);
	lua_Integer len = lua_tointeger(L, -1);
	lua_pop(L, 1);
	/*struct vector3 point[len];
	int idx = 0;
	while (lua_next(L, 2) != 0) {
		struct vector3 *v = (struct vector3 *)lua_touserdata(L, -1);
		point[idx].x = v->x;
		point[idx].y = v->y;
		point[idx].z = v->z;
		lua_pop(L, 1);
		idx++;
	}
	aabb->updateMinMax(point, len);*/
	return 0;
}

static int 
laabb_transform(lua_State *L) {
	struct aabb_aux *aux = (struct aabb_aux *)lua_touserdata(L, 1);
	AABB *aabb = (AABB *)aux->aabb;
	union matrix44 *mat = (union matrix44 *)lua_touserdata(L, 2);
	aabb->transform(*mat);
	return 0;
}

LUAMOD_API int 
luaopen_math3d_aabb(lua_State *L) {
	luaL_Reg l[] = {
		{ "getCenter", laabb_getCenter },
		{ "getCorners", laabb_getCorners },
		{ "intersects", laabb_intersects },
		{ "containPoint", laabb_containPoint },
		{ "merge", laabb_merge },
		{ "set", laabb_set },
		{ "reset", laabb_reset },
		{ "isEmpty", laabb_isEmpty },
		{ "updateMinMax", laabb_updateMinMax },
		{ "transform", laabb_transform },
		{ NULL, NULL },
	};
	// create metatable
	int n = 0;
	while (l[n].name)
		++n;
	lua_newtable(L);
	lua_createtable(L, 0, n);
	int i = 0;
	for (; i < n; ++i) {
		lua_pushcfunction(L, l[i].func);
		lua_setfield(L, -2, l[i].name);
	}
	lua_setfield(L, -2, "__index");
	lua_pushstring(L, "aabb");
	lua_setfield(L, -2, "__metatable");
	lua_pushcfunction(L, laabb_release);
	lua_setfield(L, -2, "__gc");

	lua_pushcclosure(L, laabb_new, 1);

	return 1;
}

#ifdef __cplusplus
}
#endif


