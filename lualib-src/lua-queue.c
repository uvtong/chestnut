#include <lua.h>
#include <lauxlib.h>

#include <stdlib.h>
#include <stdbool.h>

static int
lsize(lua_Integer cap, lua_Integer head, lua_Integer tail) {
	if (tail == head) {
		return 0;
	} else if (tail > head) {
		return tail - head;
	} else {
		return tail + cap - head;
	}
}

static int
lcheck(lua_State *L) {
}

static int
lenqueue(lua_State *L) {
	luaL_checktype(L, 1, LUA_TTABLE);
	if (lua_gettop(L) != 2) {
		luaL_error(L, "elem");
	}
	lua_rawgeti(L, 1, 0);
	lua_Integer cap = luaL_checkinteger(L, -1);
	lua_rawgeti(L, 1, cap + 1);
	lua_Integer head = luaL_checkinteger(L, -1);
	lua_rawgeti(L, 1, cap + 2);
	lua_Integer tail = luaL_checkinteger(L, -1);
	lua_pop(L, 3);

	int size = lsize(cap, head, tail);
	if (size >= cap - 1) {
		cap *= 2;
		lua_pushinteger(L, cap);
		lua_rawseti(L, 1, 0);
		lua_pushinteger(L, head);
		lua_rawseti(L, 1, cap + 1);
		lua_pushinteger(L, tail);
		lua_rawseti(L, 1, cap + 2);
	}
	if (tail >= head) {
		lua_rawseti(L, 1, tail);
		tail = tail + 1 > cap ? tail + 1 % cap : tail + 1;
	} else {
		lua_rawseti(L, 1, tail);
		tail++;
	}
	lua_pushinteger(L, tail);
	lua_rawseti(L, 1, cap + 2);
	return 0;
}

static int
ldequeue(lua_State *L) {
	luaL_checktype(L, 1, LUA_TTABLE);
	lua_rawgeti(L, 1, 0);
	lua_Integer cap = luaL_checkinteger(L, -1);
	lua_rawgeti(L, 1, cap + 1);
	lua_Integer head = luaL_checkinteger(L, -1);
	lua_rawgeti(L, 1, cap + 2);
	lua_Integer tail = luaL_checkinteger(L, -1);
	lua_pop(L, 3);

	int size = lsize(cap, head, tail);

	if (size > 0) {
		lua_rawgeti(L, 1, head);
		head++;
		if (head > cap) {
			head = 1;
		}
		lua_pushinteger(L, head);
		lua_rawseti(L, 1, cap + 1);
		return 1;
	}
	return 0;
}

static int
lat(lua_State *L) {
	luaL_checktype(L, 1, LUA_TTABLE);
	lua_Integer i = luaL_checkinteger(L, 2);
	if (lua_gettop(L) != 2) {
		luaL_error(L, "elem");
	}
	lua_rawgeti(L, 1, 0);
	lua_Integer cap = luaL_checkinteger(L, -1);
	lua_rawgeti(L, 1, cap + 1);
	lua_Integer head = luaL_checkinteger(L, -1);
	lua_rawgeti(L, 1, cap + 2);
	lua_Integer tail = luaL_checkinteger(L, -1);
	lua_pop(L, 3);

	int size = lsize(cap, head, tail);
	if (i <= size) {
		int n = head + i - 1 % cap;  // 1, 2, 3
		lua_rawgeti(L, 1, n);
		return 1;
	} else {
		luaL_error(L, "more than size");
	}
	return 0;
}

static int
llen(lua_State *L) {
	luaL_checktype(L, 1, LUA_TTABLE);

	lua_rawgeti(L, 1, 0);
	int cap = luaL_checkinteger(L, -1);
	lua_rawgeti(L, 1, cap + 1);
	int head = luaL_checkinteger(L, -1);
	lua_rawgeti(L, 1, cap + 2);
	int tail = luaL_checkinteger(L, -1);
	lua_pop(L, 3);

	int size = lsize(cap, head, tail);
	lua_pushinteger(L, size);
	return 1;
}

static int
lindex(lua_State *L) {
	luaL_error(L, "not support.");
	return 0;
}

static int
lnewindex(lua_State *L) {
	luaL_error(L, "not support.");
	return 0;
}

static int
lnext(lua_State *L) {
	luaL_checktype(L, 1, LUA_TTABLE);
	int cap = lua_rawgeti(L, 1, 0);
	int head = lua_rawgeti(L, 1, cap + 1);
	int tail = lua_rawgeti(L, 1, cap + 2);
	int size = lsize(cap, head, tail);
	lua_Integer idx;
	if (lua_isnoneornil(L, 2)) {
		idx = 1;
	} else {
		idx = lua_tointeger(L, 2);
	}
	int i = head + idx - 1 > cap ? head + idx - 1 % cap : head + idx - 1;
	if (lua_rawgeti(L, 1, i) != LUA_TNIL) {
		lua_pushinteger(L, idx + 1);
		lua_pushvalue(L, -2);
		return 2;
	}
	return 0;
}

static int
lpairs(lua_State *L) {
	luaL_checktype(L, 1, LUA_TTABLE);
	lua_pushcfunction(L, lnext);
	lua_pushvalue(L, 1);
	lua_pushnil(L);
	return 3;
}

static int
lfree(lua_State *L) {
	return 0;
}

static int
lalloc(lua_State *L) {
	int n = lua_gettop(L);
	if (n < 10) {
		n = 10;
	}
	lua_createtable(L, n, 3);
	lua_pushvalue(L, lua_upvalueindex(1));
	lua_setmetatable(L, -2);

	luaL_Reg l[] = {
		{ "enqueue", lenqueue },
		{ "dequeue", ldequeue },
		{ "at", lat },
		{ NULL, NULL },
	};
	for (size_t i = 0; l[i].name != NULL; i++) {
		lua_pushcfunction(L, l[i].func);
		lua_setfield(L, -2, l[i].name);
	}
	lua_pushinteger(L, n);
	lua_rawseti(L, -2, 0);
	lua_pushinteger(L, 1);
	lua_rawseti(L, -2, n + 1);
	lua_pushinteger(L, 1);
	lua_rawseti(L, -2, n + 2);

	return 1;
}

LUAMOD_API int
luaopen_queue(lua_State *L) {
	luaL_checkversion(L);
	luaL_Reg l[] = {
		{ "__pairs", lpairs },
		{ "__len", llen },
		{ "__gc", lfree},
		{ NULL, NULL },
	};
	luaL_newlib(L, l);
	lua_pushcclosure(L, lalloc, 1);
	return 1;
}