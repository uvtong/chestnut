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


LUA_CLIB = aoiaux cjson crab \
	   float math3d queue \
	   rudp skiplist config \
	   udpgate snapshot ssock \
	   \

# lualib
$(LUA_CLIB_PATH)/aoiaux.so: $(CLIB_SRC_PATH)/aoi.c $(CLIB_SRC_PATH)/aoi_aux.c | $(LUA_CLIB_PATH)
	$(CC) $(CFLAGS) $(SHARED) -I$(LUA_INC) -I$(CLIB_SRC_PATH) -o $@ $^

$(LUA_CLIB_PATH)/cjson.so: $(CLIB_SRC_PATH)/cjson/lua_cjson.c $(CLIB_SRC_PATH)/cjson/strbuf.c $(CLIB_SRC_PATH)/cjson/fpconv.c | $(LUA_CLIB_PATH)
	$(CC) $(CFLAGS) $(SHARED) -pedantic -DNDEBUG -I$(LUA_INC) -I$(CLIB_SRC_PATH)/cjson $^ -o $@

$(LUA_CLIB_PATH)/crab.so: $(wildcard $(CLIB_SRC_PATH)/crab/*.c) | $(LUA_CLIB_PATH)
	$(CC) $(CFLAGS) $(SHARED) -I$(LUA_INC) -I$(CLIB_SRC_PATH)/crab $^ -o $@

$(LUA_CLIB_PATH)/float.so: $(CLIB_SRC_PATH)/float.c | $(LUA_CLIB_PATH)
	$(CC) $(CFLAGS) $(SHARED) -I$(LUA_INC) -o $@ $^

$(LUA_CLIB_PATH)/math3d.so: $(CLIB_SRC_PATH)/libmath.cc $(CLIB_SRC_PATH)/libaabb.cc $(CLIB_SRC_PATH)/CCAABB.cc | $(LUA_CLIB_PATH)
	g++ $(CPPFLAGES) $(SHARED) -I$(LUA_INC) $^ -o $@

$(LUA_CLIB_PATH)/queue.so: $(CLIB_SRC_PATH)/lua-queue.c | $(LUA_CLIB_PATH)
	$(CC) $(CFLAGS) $(SHARED) -I$(LUA_INC) $^ -o $@

$(LUA_CLIB_PATH)/rudp.so: $(CLIB_SRC_PATH)/rudp.c $(CLIB_SRC_PATH)/librudp.c | $(LUA_CLIB_PATH)
	$(CC) $(CFLAGS) $(SHARED) -I$(LUA_INC) -I$(LUA_CLIB_PATH) $^ -o $@

$(LUA_CLIB_PATH)/skiplist.so: $(CLIB_SRC_PATH)/skiplist.c $(CLIB_SRC_PATH)/lua-skiplist.c | $(LUA_CLIB_PATH)
	$(CC) $(CFLAGS) $(SHARED) -I$(LUA_INC) $^ -o $@

$(LUA_CLIB_PATH)/config.so: $(wildcard $(CLIB_SRC_PATH)/config/*.cpp) | $(LUA_CLIB_PATH)
	g++ $(CPPFLAGES) $(SHARED) -I$(LUA_INC) -o $@ $^

$(LUA_CLIB_PATH)/udpgate.so: $(SERVICE_SRC_PATH)/lua-udpgate.c | $(LUA_CLIB_PATH)
	$(CC) $(CFLAGS) $(SHARED) -I$(LUA_INC) -o $@ $^

$(LUA_CLIB_PATH)/snapshot.so: $(CLIB_SRC_PATH)/snapshot.c
	$(CC) $(CFLAGS) $(SHARED) -I$(LUA_INC) -o $@ $^

$(LUA_CLIB_PATH)/snowflake.so: $(CLIB_SRC_PATH)/lua-snowflake.c | $(LUA_CLIB_PATH)
	$(CC) $(CFLAGS) $(SHARED) -I$(LUA_INC) -I$(SKYNET_INC) -o $@ $^

$(LUA_CLIB_PATH)/ssock.so: $(wildcard $(CLIB_SRC_PATH)/ssock/*.c)
	$(CC) $(CFLAGS) $(SHARED) -I$(LUA_INC) -I3rd/skynet_ssl -Iinclude -Wl,--whole-archive ./clib/*.a -Wl,--no-whole-archive -o $@ $^ -lrt ./clib/libcrypto.a ./clib/libssl.a  ./clib/libidn.a ./clib/libz.a

#skynet
$(SKYNET_PATH)/Makefile: $(update3rd)
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


all: \
	$(foreach v, $(LUA_CLIB), $(LUA_CLIB_PATH)/$(v).so)

clean: $(LUA_CLIB_PATH)/*.so
