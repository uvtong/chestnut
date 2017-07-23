#define LUA_LIB

#include <lua.h>
#include <lauxlib.h>

#include <stdint.h>
#include <time.h>
#ifdef _MSC_VER
#include <Windows.h>
#else
#include <sys/time.h>
#endif // _MSC_VER
#include <spinlock.h>


#define MAX_INDEX_VAL       0x0fff
#define MAX_WORKID_VAL      0x03ff
#define MAX_TIMESTAMP_VAL   0x01ffffffffff

#define __atomic_read(var)        __sync_fetch_and_add(&(var), 0)
#define __atomic_set(var, val)    __sync_lock_test_and_set(&(var), (val))

typedef struct ctx {
    int64_t last_timestamp;
    int16_t work_id;
    int16_t index;
	volatile int inited;
	struct spinlock lock;
} ctx_t;

static ctx_t *TI = NULL;


static int64_t
get_timestamp() {
#ifdef _MSC_VER
	SYSTEMTIME st;
	GetLocalTime(&st);
	return st.wMilliseconds;
#else
	struct timeval tv;
	gettimeofday(&tv, 0);
	return tv.tv_sec * 1000 + tv.tv_usec / 1000;
#endif // _MSC_VER
}

static void
wait_next_msec() {
    int64_t current_timestamp = 0;
    do {
        current_timestamp = get_timestamp();
    } while (TI->last_timestamp >= current_timestamp);
	TI->last_timestamp = current_timestamp;
	TI->index = 0;
}

static uint64_t
next_id() {
	SPIN_LOCK(TI);
	if (TI->inited != 1) {
		return -1;
	}
    int64_t current_timestamp = get_timestamp();
    if (current_timestamp == TI->last_timestamp) {
        if (TI->index < MAX_INDEX_VAL) {
            ++TI->index;
        } else {
            wait_next_msec();
        }
    } else {
		TI->last_timestamp = current_timestamp;
		TI->index = 0;
    }
    int64_t nextid = (int64_t)(
        ((TI->last_timestamp & MAX_TIMESTAMP_VAL) << 22) | 
        ((TI->work_id & MAX_WORKID_VAL) << 12) | 
        (TI->index & MAX_INDEX_VAL)
    );
	SPIN_UNLOCK(TI);
    return nextid;
}

static int
init(uint16_t work_id) {
	SPIN_INIT(TI);
	TI->last_timestamp = get_timestamp();
	TI->work_id = work_id;
	TI->index = 0;
	TI->inited = 1;
    return 0;
}

static int
linit(lua_State* l) {
    int16_t work_id = 0;
    if (lua_gettop(l) > 0) {
        lua_Integer id = luaL_checkinteger(l, 1);
        if (id < 0 || id > MAX_WORKID_VAL) {
            return luaL_error(l, "Work id is in range of 0 - 1023.");
        }
        work_id = (int16_t)id;
    }
    if (init(work_id)) {
        return luaL_error(l, "Init instance error, not enough memory.");
    }
    lua_pushboolean(l, 1);
    return 1;
}

static int
lnextid(lua_State* L) {
    int64_t id = next_id();
    lua_pushinteger(L, (lua_Integer)id);
    return 1;
}

LUAMOD_API int
luaopen_snowflake(lua_State* l) {
    luaL_checkversion(l);
    luaL_Reg lib[] = {
        { "init", linit },
        { "next_id", lnextid },
        { NULL, NULL }
    };
    luaL_newlib(l, lib);
    return 1;
}