/*
License: MIT
Author: bywayboy<bywayboy@gmail.com>
Date: 2014-11-21
*/
#include <stdio.h>
#include <stdlib.h>

#include "lua.h"
#include "lauxlib.h"
#include "lua-json.h"

int _lua_tpl_compile(lua_State * L);

void lua_lmu_createmetatable (lua_State *L) {
	lua_createtable(L, 0, 1);  /* table to be metatable for strings */
	lua_pushliteral(L, "");  /* dummy string */
	lua_pushvalue(L, -2);  /* copy table */
	lua_setmetatable(L, -2);  /* set table as metatable for strings */
	lua_pop(L, 1);  /* pop dummy string */
	lua_pushvalue(L, -2);  /* get string library */
	lua_setfield(L, -2, "__index");  /* metatable.__index = string */
	lua_pop(L, 1);  /* pop metatable */
}

int luaopen_lmu(lua_State * L)
{
	// luaL_checkversion(L);
	luaL_Reg l[] = {
		// lua tpl support.
		{"compile",_lua_tpl_compile},
		// lua json support.
		{"json_decode",lua_json_decode},
		{"json_encode",lua_json_encode},
		{NULL,NULL}
	};
	luaL_newlib(L, l);
	lua_lmu_createmetatable(L);
	return 1;
}


