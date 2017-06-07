include platform.mk

# lua
LUA_INC ?= ./3rd/skynet/3rd/lua

#skynet
SKYNET_INC      := ./3rd/skynet/skynet-src
SKYNET_PATH     := ./3rd/skynet

LUA_CLIB_PATH ?= luaclib
CLIB_SRC_PATH ?= lualib-src
CSERVICE_PATH ?= cservice
SERVICE_SRC_PATH ?= service-src

# CFLAGS    = -std=c99 -g -O2 -Wall $(MYCFLAGS)
CFLAGS    = -g -O2 -Wall $(MYCFLAGS)
CPPFLAGES = -std=c++11 -g -o2 -Wall -fpermissive $(MYCFLAGS)

.PHONY: update3rd

$(LUA_CLIB_PATH):
	mkdir $(LUA_CLIB_PATH)

$(CSERVICE_PATH):
	mkdir $(CSERVICE_PATH)

update3rd:
	git submodule update --init

# crab
CRAB_PATH ?= ./3rd/crab
$(CRAB_PATH)/Makefile:
	git submodule update --init && git submodule sync && git submodule update	
$(CRAB_PATH)/crab.so: $(CRAB_PATH)/Makefile
	cd $(CRAB_PATH) && $(MAKE)

#lsocket
LSOCKET_PATH ?= ./3rd/lsocket
$(LSOCKET_PATH)/Makefile:
	git submodule update --init && git submodule sync && git submodule update
$(LSOCKET_PATH)/lsocket.so: $(LSOCKET_PATH)/Makefile
	cd $(LSOCKET_PATH) && $(MAKE)

#lua-cjson
LUA_CJSON_PATH ?= ./3rd/lua-cjson
$(LUA_CJSON_PATH)/Makefile:
	git submodule update --init
$(LUA_CJSON_PATH)/cjson.so: $(LUA_CJSON_PATH)/Makefile
	cd $(LUA_CJSON_PATH) && $(MAKE)
$(LUA_CLIB_PATH)/cjson.so: $(LUA_CJSON_PATH)/cjson.so | $(LUA_CLIB_PATH)
	cp $(LUA_CJSON_PATH)/cjson.so $(LUA_CLIB_PATH)
clean_cjson:
	cd $(LUA_CJSON_PATH) && $(MAKE) clean

#lua-snapshot
LUA_SNAPSHOT_PATH ?= ./3rd/lua-snapshot
$(LUA_SNAPSHOT_PATH)/Makefile:
	git submodule update --init && git submodule sync && git submodule update
$(LUA_SNAPSHOT_PATH)/snapshot.so: $(LUA_SNAPSHOT_PATH)/Makefile
	cd $(LUA_SNAPSHOT_PATH) && $(MAKE)
$(LUA_CLIB_PATH)/snapshot.so: $(LUA_SNAPSHOT_PATH)/snapshot.so
	cp $(LUA_SNAPSHOT_PATH)/snapshot.so $(LUA_CLIB_PATH)

#lua-zset
LUA_ZSET_PATH ?= ./3rd/lua-zset
$(LUA_ZSET_PATH)/Makefile:
	git submodule update --init
$(LUA_ZSET_PATH)/skiplist.so: $(LUA_ZSET_PATH)/Makefile
	cd $(LUA_ZSET_PATH) && $(MAKE)
$(LUA_CLIB_PATH)/skiplist.so: $(LUA_ZSET_PATH)/skiplist.so | $(LUA_CLIB_PATH)
	mv $(LUA_ZSET_PATH)/skiplist.so $(LUA_CLIB_PATH)

# lualib
$(LUA_CLIB_PATH)/log.so: $(CLIB_SRC_PATH)/lua-log.c | $(LUA_CLIB_PATH)
	$(CC) $(CFLAGS) $(SHARED) -I$(LUA_INC) $^ -o $@ -lrt

$(LUA_CLIB_PATH)/queue.so: $(CLIB_SRC_PATH)/lua-queue.c | $(LUA_CLIB_PATH)
	$(CC) $(CFLAGS) $(SHARED) -I$(LUA_INC) $^ -o $@

$(LUA_CLIB_PATH)/math3d.so: $(CLIB_SRC_PATH)/libmath.c $(CLIB_SRC_PATH)/libaabb.c $(CLIB_SRC_PATH)/CCAABB.cpp | $(LUA_CLIB_PATH)
	g++ $(CPPFLAGES) $(SHARED) -I$(LUA_INC) $^ -o $@

$(LUA_CLIB_PATH)/rudp.so: ./3rd/rudp/rudp.c $(CLIB_SRC_PATH)/librudp.c 
	$(CC) $(CFLAGS) $(SHARED) -I$(LUA_INC) -I./3rd/rudp/ $^ -o $@

$(LUA_CLIB_PATH)/aoiaux.so: ./3rd/aoi/aoi.c $(CLIB_SRC_PATH)/aoi_aux.c | $(LUA_CLIB_PATH)
	$(CC) $(CFLAGS) $(SHARED) -I$(LUA_INC) -I./3rd/aoi -o $@ $^

$(LUA_CLIB_PATH)/float.so: $(CLIB_SRC_PATH)/float.c | $(LUA_CLIB_PATH)
	$(CC) $(CFLAGS) $(SHARED) -I$(LUA_INC) -o $@ $^

$(LUA_CLIB_PATH)/config.so: $(CLIB_SRC_PATH)/config/config.cpp $(CLIB_SRC_PATH)/config/csv.cpp $(CLIB_SRC_PATH)/config/strhtable.cpp $(CLIB_SRC_PATH)/config/value_t.cpp | $(LUA_CLIB_PATH)
	g++ $(CPPFLAGES) $(SHARED) -I$(LUA_INC) -o $@ $^

$(LUA_CLIB_PATH)/udpgate.so: $(SERVICE_SRC_PATH)/lua-udpgate.c | $(LUA_CLIB_PATH)
	$(CC) $(CFLAGS) $(SHARED) -I$(LUA_INC) -o $@ $^

$(LUA_CLIB_PATH)/snowflake.so: $(CLIB_SRC_PATH)/lua-snowflake.c | $(LUA_CLIB_PATH)
	$(CC) $(CFLAGS) $(SHARED) -I$(LUA_INC) -I$(SKYNET_INC) -o $@ $^

$(LUA_CLIB_PATH)/ssldriver.so: $(wildcard ./3rd/skynet_ssl/*.c)
	$(CC) $(CFLAGS) $(SHARED) -I$(LUA_INC) -I./3rd/skynet_ssl -o $@ $^

#skynet
$(SKYNET_PATH)/Makefile:
	git submodule update --init && git submodule sync && git submodule update
$(SKYNET_PATH)/skynet: $(SKYNET_PATH)/Makefile
	cd $(SKYNET_PATH) && $(MAKE) $(PLAT)
clean_skynet:
	cd $(SKYNET_PATH) && $(MAKE) clean

# service
service_defines   :=
service_hpaths    := $(SKYNET_SRC_PATH)
service_lpaths    := 
service_libraries :=

$(CSERVICE_PATH)/catlogger.so: $(SERVICE_SRC_PATH)/service_catlogger.c | $(CSERVICE_PATH)
	$(CC) $(CFLAGS) $(SHARED) -I$(SKYNET_INC) $^ -o $@ 

$(CSERVICE_PATH)/udpgate.so: $(SERVICE_SRC_PATH)/service_udpgate.c $(SERVICE_SRC_PATH)/rbtree.c | $(CSERVICE_PATH)
	$(CC) $(CFLAGS) $(SHARED) -I$(SKYNET_INC) $^ -o $@


all: $(LUA_CLIB_PATH)/cjson.so \
	$(LUA_CLIB_PATH)/skiplist.so \
	$(LUA_CLIB_PATH)/log.so \
	$(LUA_CLIB_PATH)/math3d.so \
	$(LUA_CLIB_PATH)/queue.so \
	$(LUA_CLIB_PATH)/rudp.so \
	$(LUA_CLIB_PATH)/udpgate.so \
	$(LUA_CLIB_PATH)/aoiaux.so \
	$(LUA_CLIB_PATH)/float.so \
	$(LUA_CLIB_PATH)/config.so \
	$(LUA_CLIB_PATH)/snowflake.so \
	$(LUA_CLIB_PATH)/ssldriver.so

clean: clean_cjson \
	rm -rf $(LUA_CLIB_PATH)/log.so \
		$(LUA_CLIB_PATH)/math3d.so \
		$(LUA_CLIB_PATH)/queue.so \
		$(LUA_CLIB_PATH)/rudp.so \
		$(LUA_CLIB_PATH)/udpgate.so \
		$(LUA_CLIB_PATH)/aoiaux.so \
		$(LUA_CLIB_PATH)/float.so \
		$(LUA_CLIB_PATH)/config.so \
		$(LUA_CLIB_PATH)/snowflake.so \ 
		$(LUA_CLIB_PATH)/ssldriver.so
