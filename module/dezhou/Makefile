
CSERVICE_PATH ?= cservice
SERVICE_SRC_PATH ?= service-src
LUA_CLIB_PATH ?= luaclib
CLIB_SRC_PATH ?= lualib-src

LUA_INC ?= /usr/local/include
SHARED := -fPIC --shared
CFLAGS := -g -O2 -Wall
CXXFLAGS := -g -O2 -Wall

.PHONY: all clean default

default: all

$(LUA_CLIB_PATH):
	mkdir $(LUA_CLIB_PATH)

$(CSERVICE_PATH):
	mkdir $(CSERVICE_PATH)


$(LUA_CLIB_PATH)/config.so: $(foreach n,config.cpp csv.cpp strhtable.cpp value_t.cpp,lualib-src/$(n)) | $(LUA_CLIB_PATH)
	g++ -std=c++11 $(CXXFLAGS) $(SHARED) -I$(LUA_INC) -o $@ $^

all: $(LUA_CLIB_PATH)/config.so

clean:
	rm -f $(LUA_CLIB_PATH)/config.so