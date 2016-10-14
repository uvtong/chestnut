AOI_SRC_PATH ?= ../../3rd/aoi

LUA_CLIB_PATH ?= luaclib
CLIB_SRC_PATH ?= lualib-src

LUA_INC = /usr/local/include
SHARED := -fPIC --shared
CFLAGS = -g -O2 -Wall

$(LUA_CLIB_PATH):
	mkdir $(LUA_CLIB_PATH)

$(LUA_CLIB_PATH)/test.so: $(CLIB_SRC_PATH)/test.cpp $(CLIB_SRC_PATH)/Actor.cpp | $(LUA_CLIB_PATH)
	g++ -std=c++11 $(CFLAGS) $(SHARED) -I$(LUA_INC) $^ -o $@

$(LUA_CLIB_PATH)/aoiaux.so: $(CLIB_SRC_PATH)/aoi_aux.c $(AOI_SRC_PATH)/aoi.c | $(LUA_CLIB_PATH)
	gcc $(CFLAGS) $(SHARED) -I$(AOI_SRC_PATH) -I$(LUA_INC) $^ -o $@

$(LUA_CLIB_PATH)/float.so: $(CLIB_SRC_PATH)/float.c | $(LUA_CLIB_PATH)
	gcc $(CFLAGS) $(SHARED) -I$(LUA_INC) $^ -o $@

.PHONY: all clean

all: $(LUA_CLIB_PATH)/aoiaux.so $(LUA_CLIB_PATH)/float.so

clean:
	rm -rf $(LUA_CLIB_PATH)/test.so $(LUA_CLIB_PATH)/aoiaux.so