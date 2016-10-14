#include <lua.h>
#include <lauxlib.h>

struct queue_data {
	int cap;
	int size;
	int head;
	int tail;
};

static
int lenqueue(lua_State *L)
{
	struct queue_data *qd = (struct queue_data*)lua_touserdata(L, 1);
	if (qd->size)
	{
		
	}
	if (lua_isnumber(L, 2)) {
		
	} else {

	}
}

/* 
    当传入一个非 nil 的 lua 对象时，这个对象将进入队列。返回 true 表示成功，否则队列满
    当不传参数时，把队首元素出队列并返回出去；返回空表示队列空
 */
static 
int ldequeue(lua_State *L)
{
	
	if (g_api->lua_gettop(L)==0) {
		// queue leave
		if (qd->head==qd->tail) {
			return 0;
		}
		g_api->lua_pushvalue(L,lua_upvalueindex(qd->head));
		g_api->lua_pushnil(L);
		g_api->lua_replace(L,lua_upvalueindex(qd->head));
		++qd->head;
		if (qd->head > qd->size) {
			qd->head=2;
		}
		return 1;
	}
	else {
		// queue enter
		int tail=qd->tail+1;
		if (tail>qd->size) {
			tail=2;
		}
		if (tail==qd->head) {
			// queue overflow
			return 0;
		}
		g_api->lua_settop(L,1);
		g_api->lua_replace(L,lua_upvalueindex(qd->tail));
		qd->tail=tail;
		g_api->lua_pushboolean(L,true);
		return 1;
	}
}
 
/* 创建一个尺寸为 size 的队列对象并返回，size 收到 upvalue 数量限制，这里最大可以为 253 */
static
int lnew(lua_State *L)
{
	int size = lua_tointeger(L, 1);
	struct queue_data *qd;
	g_api->lua_settop(L,0);
	qd=(struct queue_data*)g_api->lua_newuserdata(L,sizeof(struct queue_data));
	qd->size=size;
	qd->head=qd->tail=2;
	g_api->lua_settop(L,size);
	g_api->lua_pushcclosure(L,queue,size);
	g_api->lua_pushvalue(L,-1);
	g_confirm_closure=g_api->lua_ref(L);
	return 1;
}

static
int ldel(lua_State *L) {
	struct queue_data *qd = (queue_data *)lua_touserdata(L, 1)
	free(qd)
	qd = NULL;
	return 0;
}

int
luaopen_queue(lua_State *L) {
	luaL_checkversion(L);
	luaL_Reg l[] = {
		{ "new", lnew },
		{ "enqueue", lenqueue },
		{ "dequeue", ldequeue },
		{ "del", ldel },
		{ NULL, NULL },
	};
	luaL_newlib(L,l);
	return 1;
}