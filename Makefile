include platform.mk

LUA_CLIB_PATH ?= luaclib
CSERVICE_PATH ?= cservice
SERVICE_SRC_PATH ?= service-src
CLIB_SRC_PATH ?= lualib-src

CRAB_PATH ?= ./3rd/crab
LSOCKET_PATH ?= ./3rd/lsocket
LUA_PATH ?= ./3rd/lua
LUA_CJSON_PATH ?= ./3rd/lua-cjson
LUA_SNAPSHOT_PATH ?= ./3rd/lua-snapshot
LUA_SOCKET_PATH ?= ./3rd/lua-socket
LUA_ZSET_PATH ?= ./3rd/lua-zset
REDIS_PATH ?= ./3rd/redis
SKYNET_PATH ?= ./3rd/skynet

CFLAGS = -g -O2 -Wall -I$(LUA_INC) $(MYCFLAGS)

# lua

LUA_STATICLIB := $(LUA_PATH)/liblua.a
LUA_LIB ?= $(LUA_STATICLIB)
LUA_INC ?= $(LUA_PATH)

$(LUA_STATICLIB):
	cd ./3rd/lua && $(MAKE) CC='$(CC) -std=gnu99' $(PLAT)

# crab
CRAB := $(CRAB_PATH)/crab.so
$(CRAB):
	cd $(CRAB_PATH) && $(MAKE)

#lsocket
LSOCKET := $(LSOCKET_PATH)/lsocket.so
$(LSOCKET):
	cd $(LSOCKET_PATH) && $(MAKE)

#lua-cjson
LUA_CJSON := $(LUA_CJSON_PATH)/cjson.so
$(LUA_CJSON):
	cd $(LUA_CJSON_PATH) && $(MAKE)

#lua-snapshot
LUA_SNAPSHOT := $(LUA_SNAPSHOT)/snapshot.so
$(LUA_SNAPSHOT):
	cd $(LUA_SNAPSHOT_PATH) && $(MAKE)

#lua-socket
LUA_SOCKET := $(LUA_SOCKET_PATH)/packagesocket.so
$(LUA_SOCKET):
	cd $(LUA_SOCKET_PATH) && $(MAKE)

#lua-zset
LUA_ZSET := $(LUA_ZSET_PATH)/skiplist.so
$(LUA_ZSET):
	cd $(LUA_ZSET_PATH) && $(MAKE)

SKYNET := $(SKYNET_PATH)/skynet
$(SKYNET):
	cd $(SKYNET_PATH) && $(MAKE) $(PLAT)	

$(LUA_CLIB_PATH):
	mkdir $(LUA_CLIB_PATH)

$(CSERVICE_PATH):
	mkdir $(CSERVICE_PATH)

LOG = $(LUA_CLIB_PATH)/log.so
$(LOG): lualib-src/lua-log.c | $(LUA_CLIB_PATH)
	$(CC) $(CFLAGS) $(SHARED) $^ -o $@ 

CATLOGGER = $(CSERVICE_PATH)/catlogger.so
$(CATLOGGER): service-src/service_catlogger.c | $(CSERVICE_PATH)
	$(CC) $(CFLAGS) $(SHARED) $< -o $@ -I./3rd/skynet/skynet-src

LUA_QUEUE := $(LUA_CLIB_PATH)/queue.so
$(LUA_QUEUE): $(CLIB_SRC_PATH)/lua-queue.c
	$(CC) $(CFLAGS) $(SHARED) -I$(LUA_PATH) $^ -o $@

all: $(LUA_STATICLIB) $(CRAB) $(LSOCKET) $(LUA_CJSON) $(LUA_SNAPSHOT) $(LUA_SOCKET) $(LUA_ZSET) $(LOG) $(CATLOGGER)

.PHONY: update3rd clean cleanall

update3rd:
	git submodule update --init

clean:


cleanall:
	rm -rf $(LUA_STATICLIB) $(CRAB) $(LSOCKET) $(LUA_CJSON) $(LUA_SNAPSHOT) $(LUA_SOCKET) $(LUA_ZSET) $(SKYNET)

