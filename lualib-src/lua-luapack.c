#include "skynet.h"

#include <lua.h>
#include <lauxlib.h>

#include <stdint.h>

static int
lpack(lua_State *L) {
	size_t sz;
	const char *cmd = luaL_checklstring(L, 1, &sz);
	void *ud = lua_touserdata(L, 2);
	uint32_t data = (uint32_t)ud;
	char *msg = (char *)skynet_malloc(sz + 1 + 4);
	memcpy(msg, cmd, sz);
	msg[l] = '\0';
	for (int i = 0; i < 4; ++i) {
		msg[l+1 + i] = (data >> (i * 8) & 0xff);
	}
	lua_pushlightuserdata(L, msg);
	lua_pushinteger(L, sz + 1 + 4);
	return 2;
}

static int
lunpack(lua_State *L) {
	char *msg = lua_touserdata(L, 1);
	int sz = luaL_checkinteger(L, 2);
	int i = 0
	for (; i < sz; ++i) {
		if (msg[i] == '\0') {
			break;
		}
	}
	char cmd[i];
	memcpy(cmd, msg, i);
	uint32_t data = 0;
	for (int j = 0; j < 4; ++j) {
		data |= msg[i + 1 + j] << (j * 8);
	}
	lua_pushstring(L, cmd);
	lua_pushlightuserdata(L, (void *)data);
	return 2;
}


int
luaopen_luapack(lua_State *L) {
	luaL_checkversion(L);
	luaL_Reg l[] = {
		{ "pack", lpack },
		{ "unpack", lunpack },
		{ NULL, NULL },
	};
	luaL_newlib(L,l);
	return 1;
}