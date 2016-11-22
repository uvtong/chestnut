include platform.mk

LUA_CLIB_PATH ?= luaclib
CLIB_SRC_PATH ?= lualib-src
CSERVICE_PATH ?= cservice
SERVICE_SRC_PATH ?= service-src

CFLAGS = -g -O2 -Wall $(MYCFLAGS)

.PHONY: update3rd

update3rd:
	git submodule update --init

# lua
LUA_PATH ?= ./3rd/lua
LUA_STATICLIB ?= $(LUA_PATH)/src/liblua.a
LUA_LIB ?= $(LUA_STATICLIB)
LUA_INC ?= $(LUA_PATH)/src

$(LUA_PATH)/src/lua: $(LUA_PATH)/Makefile
	cd ./3rd/lua && $(MAKE) CC='$(CC) -std=gnu99' $(PLAT)

$(LUA_STATICLIB): $(LUA_PATH)/Makefile
	cd ./3rd/lua && $(MAKE) CC='$(CC) -std=gnu99' $(PLAT)

$(LUA_PATH)/Makefile: update3rd

# 3rd lua-lib

# crab
CRAB_PATH ?= ./3rd/crab
$(CRAB_PATH)/Makefile: update3rd
$(CRAB_PATH)/crab.so: $(CRAB_PATH)/Makefile
	cd $(CRAB_PATH) && $(MAKE)

#lsocket
LSOCKET_PATH ?= ./3rd/lsocket
$(LSOCKET_PATH)/Makefile: update3rd
$(LSOCKET_PATH)/lsocket.so: $(LSOCKET_PATH)/Makefile
	cd $(LSOCKET_PATH) && $(MAKE)

#lua-cjson
LUA_CJSON_PATH ?= ./3rd/lua-cjson
$(LUA_CJSON_PATH)/Makefile: update3rd
$(LUA_CJSON_PATH)/cjson.so: $(LUA_CJSON_PATH)/Makefile
	cd $(LUA_CJSON_PATH) && $(MAKE)
clean_cjson:
	cd $(LUA_CJSON_PATH) && $(MAKE) clean

#lua-snapshot
LUA_SNAPSHOT_PATH ?= ./3rd/lua-snapshot
$(LUA_SNAPSHOT_PATH)/Makefile: update3rd
$(LUA_SNAPSHOT_PATH)/snapshot.so: $(LUA_SNAPSHOT_PATH)/Makefile
	cd $(LUA_SNAPSHOT_PATH) && $(MAKE)

#lua-socket
LUA_SOCKET_PATH ?= ./3rd/lua-socket
$(LUA_SNAPSHOT_PATH)/Makefile: update3rd
$(LUA_SOCKET_PATH)/packagesocket.so: $(LUA_SOCKET_PATH)/Makefile
	cd $(LUA_SOCKET_PATH) && $(MAKE)

#lua-zset
LUA_ZSET_PATH ?= ./3rd/lua-zset
$(LUA_ZSET_PATH)/Makefile: update3rd
$(LUA_ZSET_PATH)/skiplist.so: $(LUA_ZSET_PATH)/Makefile
	cd $(LUA_ZSET_PATH) && $(MAKE)

#redis
REDIS_PATH ?= ./3rd/redis
$(REDIS_PATH)/Makefile: update3rd
$(REDIS_PATH)/redis: $(REDIS_PATH)/Makefile
	cd $(REDIS_PATH) && $(MAKE)
clean_redis:
	cd $(REDIS_PATH) && $(MAKE) clean

#skynet
SKYNET_PATH ?= ./3rd/skynet
SKYNET_SRC_PATH := ./3rd/skynet/skynet-src

$(SKYNET_PATH)/Makefile: update3rd
$(SKYNET_PATH)/skynet: $(SKYNET_PATH)/Makefile
	cd $(SKYNET_PATH) && $(MAKE) $(PLAT)
clean_skynet:
	cd $(SKYNET_PATH) && $(MAKE) clean

$(LUA_CLIB_PATH):
	mkdir $(LUA_CLIB_PATH)

$(CSERVICE_PATH):
	mkdir $(CSERVICE_PATH)

# lualib
$(LUA_CLIB_PATH)/log.so: $(CLIB_SRC_PATH)/lua-log.c | $(LUA_CLIB_PATH)
	$(CC) $(CFLAGS) $(SHARED) -I$(LUA_INC) $^ -o $@ 

$(LUA_CLIB_PATH)/queue.so: $(CLIB_SRC_PATH)/lua-queue.c | $(LUA_CLIB_PATH)
	$(CC) $(CFLAGS) $(SHARED) -I$(LUA_PATH) $^ -o $@

$(LUA_CLIB_PATH)/math3d.so: $(CLIB_SRC_PATH)/libmath.c $(CLIB_SRC_PATH)/libaabb.c $(CLIB_SRC_PATH)/CCAABB.cpp | $(LUA_CLIB_PATH)
	g++ -fpermissive -std=c++11 $(CFLAGS) $(SHARED) -I$(LUA_PATH) $^ -o $@	

$(LUA_CLIB_PATH)/rudp.so: ./3rd/rudp/rudp.c $(CLIB_SRC_PATH)/librudp.c 
	$(CC) $^ $(CFLAGS) $(SHARED) -I$(LUA_PATH) -I./3rd/rudp/ -o $@

# service
$(CSERVICE_PATH)/catlogger.so: $(SERVICE_SRC_PATH)/service_catlogger.c | $(CSERVICE_PATH)
	$(CC) $(CFLAGS) $(SHARED) -I$(SKYNET_SRC_PATH) $^ -o $@ 

all: $(SKYNET_PATH)/skynet \
	$(LUA_CJSON_PATH)/cjson.so \
	$(REDIS_PATH)/redis \
	$(LUA_CLIB_PATH)/log.so \
	$(LUA_CLIB_PATH)/math3d.so \
	$(LUA_CLIB_PATH)/queue.so \
	$(LUA_CLIB_PATH)/rudp.so \
	$(CSERVICE_PATH)/catlogger.so 

clean: clean_skynet clean_cjson clean_redis
	rm -rf $(LUA_CLIB_PATH)/log.so \
		$(LUA_CLIB_PATH)/math3d.so \
		$(LUA_CLIB_PATH)/queue.so \
		$(LUA_CLIB_PATH)/rudp.so \
		$(LUA_CLIB_PATH)/catlogger.so
