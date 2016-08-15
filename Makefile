include platform.mk

LUA_CLIB_PATH ?= luaclib
CSERVICE_PATH ?= cservice
SERVICE_SRC_PATH ?= service-src
CLIB_SRC_PATH ?= lualib-src


CFLAGS = -g -O2 -Wall -I$(LUA_INC) $(MYCFLAGS)


# lua
LUA_PATH ?= ./3rd/lua
LUA_STATICLIB := $(LUA_PATH)/src/liblua.a
LUA_LIB ?= $(LUA_STATICLIB)
LUA_INC ?= $(LUA_PATH)/src

$(LUA_STATICLIB): $(LUA_PATH)/Makefile
	cd ./3rd/lua && $(MAKE) CC='$(CC) -std=gnu99' $(PLAT)

$(LUA_PATH)/Makefile: update3rd


# lua-lib

# crab
CRAB_PATH ?= ./3rd/crab
CRAB := $(CRAB_PATH)/crab.so
$(CRAB): $(CRAB_PATH)/Makefile
	cd $(CRAB_PATH) && $(MAKE)

$(CRAB_PATH)/Makefile: update3rd

#lsocket
LSOCKET := $(LSOCKET_PATH)/lsocket.so
$(LSOCKET): $(LSOCKET)/Makefile
	cd $(LSOCKET_PATH) && $(MAKE)

$(LSOCKET)/Makefile: update3rd

#lua-cjson
LUA_CJSON_PATH ?= ./3rd/lua-cjson
LUA_CJSON := $(LUA_CJSON_PATH)/cjson.so
$(LUA_CJSON): $(LUA_CJSON_PATH)/Makefile
	cd $(LUA_CJSON_PATH) && $(MAKE)

$(LUA_CJSON_PATH)/Makefile: update3rd

#lua-snapshot
LUA_SNAPSHOT_PATH ?= ./3rd/lua-snapshot
LUA_SNAPSHOT := $(LUA_SNAPSHOT)/snapshot.so
$(LUA_SNAPSHOT): $(LUA_SNAPSHOT_PATH)/Makefile
	cd $(LUA_SNAPSHOT_PATH) && $(MAKE)

$(LUA_SNAPSHOT_PATH)/Makefile: update3rd

#lua-socket
LUA_SOCKET_PATH ?= ./3rd/lua-socket
LUA_SOCKET := $(LUA_SOCKET_PATH)/packagesocket.so
$(LUA_SOCKET): $(LUA_SOCKET_PATH)/Makefile
	cd $(LUA_SOCKET_PATH) && $(MAKE)

$(LUA_SNAPSHOT_PATH)/Makefile: update3rd

#lua-zset
LUA_ZSET_PATH ?= ./3rd/lua-zset
LUA_ZSET := $(LUA_ZSET_PATH)/skiplist.so
$(LUA_ZSET): $(LUA_ZSET_PATH)/Makefile
	cd $(LUA_ZSET_PATH) && $(MAKE)

$(LUA_ZSET_PATH)/Makefile: update3rd

#redis
REDIS_PATH ?= ./3rd/redis
$(REDIS_PATH)/redis: $(REDIS_PATH)/Makefile
	cd $(REDIS_PATH) && $(MAKE)

$(REDIS_PATH)/Makefile: update3rd

#skynet
SKYNET_PATH ?= ./3rd/skynet
SKYNET_SRC_PATH := ./3rd/skynet/skynet-src
SKYNET := $(SKYNET_PATH)/skynet
$(SKYNET): $(SKYNET_PATH)/Makefile
	cd $(SKYNET_PATH) && $(MAKE) $(PLAT)	

$(SKYNET_PATH)/Makefile: update3rd

$(LUA_CLIB_PATH):
	mkdir $(LUA_CLIB_PATH)

$(CSERVICE_PATH):
	mkdir $(CSERVICE_PATH)

LOG = $(LUA_CLIB_PATH)/log.so
$(LOG): lualib-src/lua-log.c | $(LUA_CLIB_PATH)
	$(CC) $(CFLAGS) $(SHARED) -I$(LUA_INC) $^ -o $@ 

CATLOGGER = $(CSERVICE_PATH)/catlogger.so
$(CATLOGGER): service-src/service_catlogger.c | $(CSERVICE_PATH)
	$(CC) $(CFLAGS) $(SHARED) $< -o $@ -I$(SKYNET_SRC_PATH)

LUA_QUEUE := $(LUA_CLIB_PATH)/queue.so
$(LUA_QUEUE): $(CLIB_SRC_PATH)/lua-queue.c
	$(CC) $(CFLAGS) $(SHARED) -I$(LUA_PATH) $^ -o $@

all: $(LUA_STATICLIB) $(LUA_CJSON) $(LOG) $(CATLOGGER) $(SKYNET)

.PHONY: update3rd clean cleanall

update3rd:
	git submodule update --init

clean:


cleanall:
	rm -rf $(LUA_STATICLIB) $(CRAB) $(LSOCKET) $(LUA_CJSON) $(LUA_SNAPSHOT) $(LUA_SOCKET) $(LUA_ZSET) $(SKYNET)

