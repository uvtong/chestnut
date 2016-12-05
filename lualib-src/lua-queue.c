#include <lua.h>
#include <lauxlib.h>
#include <stdbool.h>

struct item {
	struct item *next;
};

struct queue {
	int size;
	struct item *head;
	struct item *tail;
	struct item *freelist;
};

static struct item *
new_item(lua_State *L, struct queue *q) {
	struct item *i = NULL;
	if (q->freelist != NULL) {
		i = q->freelist;
		q->freelist = q->freelist->next;
	} else {
		lua_getuservalue(L, 1); // user table
		i = (struct item *)lua_newuserdata(L, sizeof(*i));
		i->next = NULL;
		lua_rawsetp(L, -2, i);
		lua_pop(L, 1);
	}
	return i;
}

static void
del_item(lua_State *L, struct queue *q, struct item *i) {
	if (q == NULL && i == NULL) {
		luaL_error(L, "not null");
	} else {
		i->next = q->freelist;
		q->freelist = i;
	}
}

static int 
lenqueue(lua_State *L) {
	if (lua_gettop(L) < 2) {
		lua_error(L);
	}

	struct queue *q = (struct queue*)lua_touserdata(L, 1);
	struct item *i = new_item(L, q);

	lua_getuservalue(L, 1);
	lua_rawgetp(L, -1, i);
	lua_pushvalue(L, 2);
	lua_setuservalue(L, -2);

	if (q->size > 0) {
		q->tail->next = i;
		q->tail = i;	
		q->size++;
	} else {
		if (q->size == 0) {
			q->head = i;
			q->tail = i;
			q->size++;	 
		} else {
			lua_error(L);
		}
	}
	return 0;
}

static int 
ldequeue(lua_State *L) {
	struct queue *q = (struct queue*)lua_touserdata(L, 1);
	if (q->size > 1) {
		struct item *i = q->head;
		q->head = i->next;
		q->size--;
		del_item(L, q, i);

		lua_getuservalue(L, 1);
		lua_rawgetp(L, -1, i); // ud
		lua_getuservalue(L, -1);
		return 1; 
	} else if (q->size == 1 ){
		struct item *i = q->head;
		q->head = i->next;
		q->tail = i->next;
		q->size--;
		del_item(L, q, i);

		lua_getuservalue(L, 1);
		lua_rawgetp(L, -1, i);
		lua_getuservalue(L, -1);
		return 1;
	} else if (q->size == 0) {
		return 0;
	} else {
		lua_error(L);
		return 0;
	}
	return 0;
}

static bool 
check_eq(lua_State *L) {
	int t1 = lua_type(L, -1);
	int t2 = lua_type(L, -2);
	if (t1 == t2 && t1 != LUA_TNIL) {
		if (t1 == LUA_TNUMBER) {
			if (lua_isinteger(L, -1)) {
				if (luaL_checkinteger(L, -1) == luaL_checkinteger(L, -2)) {
					return true;
				} else {
					return false;
				}
			} else if (lua_isnumber(L, -1)) {
				if (luaL_checknumber(L, -1) == luaL_checknumber(L, -2)) {
					return true;
				} else {
					return false;
				}
			} else {
				lua_error(L);
			}
		} else if (t1 == LUA_TSTRING) {
			const char *s1 = luaL_checkstring(L, -1);
			const char *s2 = luaL_checkstring(L, -2);
			if (strcmp(s1, s2) == 0) {
				return true;
			} else {
				return false;
			}
		} else if (t1 == LUA_TTABLE) {
			if (lua_topointer(L, -1) == lua_topointer(L, -2)) {
				return true;
			} else {
				return false;
			}
		} else if (t1 == LUA_TUSERDATA) {
			if (lua_topointer(L, -1) == lua_topointer(L, -2)) {
				return true;
			} else {
				return false;
			}
		} else {
			lua_error(L);
		}
	} else {
		return false;
	}
	return false;
}

static int 
ldel(lua_State *L) {
	if (lua_gettop(L) < 2) {
		lua_error(L);
	}
	struct queue *q = (struct queue*)lua_touserdata(L, 1);
	lua_getuservalue(L, 1);
	if (q->size > 0) {
		struct item *i = q->head;
		lua_rawgetp(L, -1, i);
		lua_getuservalue(L, -1);
		lua_pushvalue(L, 2);
		if (check_eq(L)) {
			if (q->size == 1) {
				q->head = i->next; // NULL
				q->tail = i->next; // NULL
				q->size--;
			} else if (q->size > 1) {
				q->head = i->next;
				q->size--;
			} else {
				lua_error(L);
			}
			del_item(L, q, i);
			lua_pushboolean(L, 1);
			return 1;
		}
		lua_pop(L, 3);
		while (i) {
			if (i->next) {
				struct item *cur = i->next;
				lua_rawgetp(L, -1, cur);
				lua_getuservalue(L, -1);
				lua_pushvalue(L, 2);
				if (check_eq(L)) {
					if (q->size > 1) {
						i->next = cur->next;
						q->size--;
					} else {
						lua_error(L);
					}
					del_item(L, q, cur);
					lua_pushboolean(L, 1);
					return 1;		
				}
				lua_pop(L, 3);
			} else {
				break;
			}
			i = i->next;
		}
		lua_pushboolean(L, 0);
		return 1;
	} else {
		lua_pushboolean(L, 0);
		return 1;
	}
}

static int 
lsize(lua_State *L) {
	struct queue *q = (struct queue*)lua_touserdata(L, 1);
	lua_pushinteger(L, q->size);
	return 1;
}

static int
ltest(lua_State *L) {
	struct queue *q = (struct queue*)lua_touserdata(L, 1);
	lua_getuservalue(L, 1);
	lua_pushnil(L);
	while (lua_next(L, -2) != 0) {
       /* uses 'key' (at index -2) and 'value' (at index -1) */
       printf("%s - %s\n",
              lua_typename(L, lua_type(L, -2)),
              lua_typename(L, lua_type(L, -1)));
       /* removes 'value'; keeps 'key' for next iteration */
       lua_getuservalue(L, -1);
       lua_getfield(L, -1, "name");
       const char *str = lua_tostring(L, -1);
       printf("%s\n", str);
       lua_pop(L, 3);
    }
    // lua_pop(L, 1);
    printf("%s\n", "test freelist");
    struct item *i = q->freelist;
    while (i) {
    	lua_rawgetp(L, -1, i);
    	lua_getuservalue(L, -1);
    	lua_getfield(L, -1, "name");
       	const char *str = lua_tostring(L, -1);
       	printf("%s\n", str);
       	lua_pop(L, 3);
       	i = i->next;
    }
    return 0;
}

static int
lfree(lua_State *L) {
	return 0;
}

static int 
lalloc(lua_State *L) {
	struct queue *q = (struct queue *)lua_newuserdata(L, sizeof(*q));
	if (q == NULL) {
		lua_error(L);
	}
	q->size = 0;
	q->head = NULL;
	q->tail = NULL;
	q->freelist = NULL;

	lua_newtable(L); // user table
	lua_newtable(L); // meta table
	lua_pushfstring(L, "k");
	lua_setfield(L, -2, "__mode");
	lua_setmetatable(L, -2);
	luaL_checktype(L, -2, LUA_TUSERDATA);
	lua_setuservalue(L, -2);

	lua_newtable(L); // ud meta table
	lua_pushvalue(L, lua_upvalueindex(1));
	lua_setfield(L, -2, "__index");
	lua_pushcclosure(L, lfree, 0);
	lua_setfield(L, -2, "__gc");
	lua_setmetatable(L, -2);
	return 1;
}

int
luaopen_queue(lua_State *L) {
	luaL_checkversion(L);
	luaL_Reg l[] = {
		{ "enqueue", lenqueue },
		{ "dequeue", ldequeue },
		{ "del", ldel },
		{ "size", lsize },
		{ "test", ltest },
		{ NULL, NULL },
	};
	luaL_newlib(L,l);
	lua_pushcclosure(L, lalloc, 1);
	return 1;
}