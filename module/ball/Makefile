include ./../../platform.mk

PLAY_SRC_PATH := ../../3rd/Maria/Plugins/play


LUA_INC    := ../../3rd/skynet/3rd/lua
SKYNET_INC := ../../3rd/skynet/skynet-src
LIBCO_INC  := ../../3rd/libco
LIBCO_LIB  := ../../bin

CSERVICE_PATH    := cservice
SERVICE_SRC_PATH := service-src
LUA_CLIB_PATH    := luaclib
CLIB_SRC_PATH    := lualib-src

CFLAGS    := -g -O2 -Wall
CPPFLAGES := -std=c++11 -fpermissive -Wnarrowing $(CFLAGS)

.PHONY: clean

$(LUA_CLIB_PATH):
	mkdir $(LUA_CLIB_PATH)

$(CSERVICE_PATH):
	mkdir $(CSERVICE_PATH)


# lualib
$(LUA_CLIB_PATH)/battle.so: $(SERVICE_SRC_PATH)/lua-battle.c | $(LUA_CLIB_PATH)
	$(CC) $(CFLAGS) $(SHARED) -I$(LUA_INC) -I$(SERVICE_SRC_PATH) -I$(SKYNET_INC) $^ -o $@

$(CSERVICE_PATH)/battle.so: $(SERVICE_SRC_PATH)/service_battle.c | $(CSERVICE_PATH)
	$(CC) $(CFLAGS) $(SHARED) -I$(SKYNET_INC) -o $@ $^

all: $(LUA_CLIB_PATH)/battle.so \
	$(CSERVICE_PATH)/battle.so

clean:
	rm -rf $(LUA_CLIB_PATH)/battle.so \
	 $(CSERVICE_PATH)/battle.so