#include "test.h"

#include "skynet.h"
#include "skynet_handle.h"

#include <lua.h>
#include <lauxlib.h>

#include <stdbool.h>
#include <string.h>
#include <assert.h>

static int 
pack_test_message(lua_State *L) {
	struct test_message *msg = skynet_malloc(sizeof(*msg));
	int sz = sizeof(*msg);
	memset(msg, 0, sz);
	msg->cmd[0] = 'T';
	msg->cmd[1] = '\0';
	msg->dummy = 3;
	lua_pushlightuserdata(L, msg);
	lua_pushinteger(L, sz);
	return 2;
}

static int 
unpack_test_message(lua_State *L) {
	struct test_message *msg = (struct test_message *)lua_touserdata(L, 1);
	int sz = luaL_checkinteger(L, 2);
	assert(sizeof(*msg) == sz);

	uint32_t handle = skynet_current_handle();
	struct skynet_context *ctx = skynet_handle_grab(handle);
	skynet_error(ctx, "lua_sevice cmd: %s, dummy: %d", (char *)msg->cmd, msg->dummy);

	char buf[128];
	memcpy(buf, msg->cmd, 16);
	int dummy = msg->dummy;

	lua_pushstring(L, buf);
	lua_pushinteger(L, dummy);
	skynet_free(msg);
	return 2;
}

static int
lpack(lua_State *L) {
	return pack_test_message(L);
}

static int
lunpack(lua_State *L) {
	return unpack_test_message(L);
}

static int
ldispatch(lua_State *L) {
	printf("%s\n", "test");
	// int source = luaL_checkinteger(L, 2);
	const char *cmd = luaL_checkstring(L, 3);
	int dummy = luaL_checkinteger(L, 4);
	if (strcmp(cmd, "T") == 0) {
		// skynet_error("hello;");
		uint32_t handle = skynet_current_handle();
		struct skynet_context *ctx = skynet_handle_grab(handle);
		skynet_error(ctx, "lua_sevice %d", dummy);

	}
	return 0;
}

int
luaopen_test(lua_State *L) {
	luaL_checkversion(L);
	luaL_Reg l[] = {
		{ "pack", lpack },
		{ "unpack", lunpack },
		{ "dispatch", ldispatch },
		{ NULL, NULL },
	};
	luaL_newlib(L,l);
	return 1;
}