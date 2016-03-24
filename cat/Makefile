include platform.mk

LUA_CLIB_PATH ?= luaclib
CSERVICE_PATH ?= cservice
SERVICE_SRC_PATH ?= service-src
TABLEPOINTER_PATH ?= ../tablepointer

SKYNET_BUILD_PATH ?= .

CFLAGS = -g -O2 -Wall -I$(LUA_INC) $(MYCFLAGS)

# lua

LUA_STATICLIB := ../skynet/3rd/lua/liblua.a
LUA_LIB ?= $(LUA_STATICLIB)
LUA_INC ?= ../skynet/3rd/lua

$(LUA_STATICLIB):
	cd ../3rd/lua && $(MAKE) CC='$(CC) -std=gnu99' $(PLAT)

JEMALLOC_STATICLIB := ../skynet/3rd/jemalloc/lib/libjemalloc_pic.a
JEMALLOC_INC := ../skynet/3rd/jemalloc/include/jemalloc

all: jemalloc
	
.PHONY: jemalloc update3rd

MALLOC_STATICLIB := $(JEMALLOC_STATICLIB)

$(JEMALLOC_STATICLIB): ../skynet/3rd/jemalloc/Makefile
	cd 3rd/jemalloc && $(MAKE) CC=$(CC) 

../skynet/3rd/jemalloc/autogen.sh:
	git submodule update --init

../skynet/3rd/jemalloc/Makefile: | ./../skynet/3rd/jemalloc/autogen.sh
	cd ../skynet/3rd/jemalloc && ./autogen.sh --with-jemalloc-prefix=je_ --disable-valgrind

jemalloc: $(MALLOC_STATICLIB)

update3rd:
	rm -rf ./../skynet/3rd/jemalloc && git submodule update --init

# cat
CSERVICE = catlogger
LUA_CLIB = tablepointer

TEST_SRC = test.c

all: \
	$(LUA_CLIB_PATH)/test \
	$(foreach v, $(CSERVICE), $(CSERVICE_PATH)/$(v).so) \
	$(foreach v, $(LUA_CLIB), $(LUA_CLIB_PATH)/$(v).so)


$(LUA_CLIB_PATH):
	mkdir $(LUA_CLIB_PATH)

$(CSERVICE_PATH):
	mkdir $(CSERVICE_PATH)

$(LUA_CLIB_PATH)/test: $(foreach v, $(TEST_SRC), lualib-src/$(v))
	$(CC) -std=c99 $(CFLAGS) -o $@ $^ -Ilualib-src

define CSERVICE_TEMP
  $$(CSERVICE_PATH)/$(1).so : service-src/service_$(1).c | $$(CSERVICE_PATH)
	$$(CC) $$(CFLAGS) $$(SHARED) $$< -o $$@ -I../skynet/skynet-src
endef

$(foreach v, $(CSERVICE), $(eval $(call CSERVICE_TEMP,$(v))))

$(LUA_CLIB_PATH)/tablepointer.so: $(TABLEPOINTER_PATH)/tablepointer.c | $(LUA_CLIB_PATH)
	$(CC) $(CFLAGS) $(SHARED) $^ -o $@ -I$(LUA_INC) -L$(LUA_INC) -llua


clean:
	rm -f $(CSERVICE_PATH)/*.so $(LUA_CLIB_PATH)/*.so $(LUA_CLIB_PATH)

cleanall: clean
ifneq (, $(wildcard ../skynet/3rd/jemalloc/Makefile))
	cd ../skynet/3rd/jemalloc && $(MAKE) clean
endif
	cd ../skynet/3rd/lua && $(MAKE) clean
	rm -f $(LUA_STATICLIB)
