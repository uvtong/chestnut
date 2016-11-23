AOI_SRC_PATH ?= ../../3rd/aoi
PLAY_SRC_PATH ?= ../../3rd/Maria/Plugins/play
PHYSX_INC ?= ../../3rd/PhysX-3.3/PhysXSDK/Include
PHYSX_LIB ?= ../../3rd/PhysX-3.3/PhysXSDK/Lib/linux32
PHYSX_BIN ?= ../../3rd/PhysX-3.3/PhysXSDK/Bin/linux32

SKYNET_INC ?= ../../3rd/skynet/skynet-src

CSERVICE_PATH ?= cservice
SERVICE_SRC_PATH ?= service-src
LUA_CLIB_PATH ?= luaclib
CLIB_SRC_PATH ?= lualib-src

LUA_INC ?= /usr/local/include
SHARED := -fPIC --shared
CFLAGS := -g -O2 -Wall

SampleBase_debug_lpaths    := 
SampleBase_debug_lpaths    += ./../../SampleFramework/framework/lib/linux32
SampleBase_debug_lpaths    += ./../../SampleFramework/platform/lib/linux32
SampleBase_debug_lpaths    += ./../../SampleFramework/renderer/lib/linux32

# debug_hpaths 

# custom_cflags 

debug_defines   := PHYSX_PROFILE_SDK
debug_defines   += _DEBUG
debug_defines   += PX_DEBUG
debug_defines   += PX_CHECKED
debug_defines   += PX_SUPPORT_VISUAL_DEBUGGER


# debug_common_cflags	 := $(custom_cflags)
debug_common_cflags  := -MMD
debug_common_cflags  += $(addprefix -D, $(debug_defines))
# debug_common_cflags    += $(addprefix -I, $(SampleBase_debug_hpaths))
debug_common_cflags  += -m32
debug_common_cflags  += -Werror -m32 -fPIC -msse2 -mfpmath=sse -malign-double -ffast-math -fno-exceptions -fno-rtti -fvisibility=hidden -fvisibility-inlines-hidden
debug_common_cflags  += -Wall -Wextra -Wstrict-aliasing=2 -fdiagnostics-show-option
debug_common_cflags  += -Wno-long-long
debug_common_cflags  += -Wno-unknown-pragmas -Wno-char-subscripts -Wno-unused-variable -Wno-reorder -Wno-sign-compare
debug_common_cflags  += -Wno-unused-parameter
debug_common_cflags  += -g3 -gdwarf-2

debug_cflags	:= $(debug_common_cflags)
debug_cppflags	:= $(debug_common_cflags)

.PHONY: all clean default

default:
	$(MAKE) all

$(LUA_CLIB_PATH):
	mkdir $(LUA_CLIB_PATH)

$(CSERVICE_PATH):
	mkdir $(CSERVICE_PATH)

$(LUA_CLIB_PATH)/test.so: $(CLIB_SRC_PATH)/test.cpp $(CLIB_SRC_PATH)/Actor.cpp | $(LUA_CLIB_PATH)
	g++ -std=c++11 $(CFLAGS) $(SHARED) -I$(LUA_INC) $^ -o $@

$(LUA_CLIB_PATH)/aoiaux.so: $(CLIB_SRC_PATH)/aoi_aux.c $(AOI_SRC_PATH)/aoi.c | $(LUA_CLIB_PATH)
	gcc $(CFLAGS) $(SHARED) -I$(AOI_SRC_PATH) -I$(LUA_INC) $^ -o $@

$(LUA_CLIB_PATH)/float.so: $(CLIB_SRC_PATH)/float.c | $(LUA_CLIB_PATH)
	gcc $(CFLAGS) $(SHARED) -I$(LUA_INC) $^ -o $@

$(LUA_CLIB_PATH)/room.so: $(SERVICE_SRC_PATH)/room.c | $(LUA_CLIB_PATH)
	gcc $(CFLAGS) $(SHARED) -I$(LUA_INC) $^ -o $@

$(CSERVICE_PATH)/room.so: $(SERVICE_SRC_PATH)/service_room.c \
	$(SERVICE_SRC_PATH)/RoomContext.cpp \
	$(PLAY_SRC_PATH)/App.cpp \
	$(PLAY_SRC_PATH)/stdafx.cpp | $(CSERVICE_PATH) 
	g++ -std=c++11 $(CFLAGS) $(SHARED) -I$(PHYSX_INC) -I$(PLAY_SRC_PATH) -I$(SKYNET_INC) $^ -o $@ $(debug_cppflags)
	#g++ -std=c++11 $(CFLAGS) $(SHARED) -I$(PLAY_SRC_PATH) -I$(PHYSX_INC) -l$(PHYSX_LIB)/libPhysX3ExtensionsDEBUG.a -l$(PHYSX_BIN)/libPhysXProfileSDKDEBUG.a -l$(PHYSX_BIN)/libPhysX3CommonDEBUG_x86.so -l$(PHYSX_BIN)/libPhysX3CookingDEBUG_x86.so -l$(PHYSX_BIN)/libPhysX3DEBUG_x86.so $^ -o $@

all: $(LUA_CLIB_PATH)/test.so \
	$(LUA_CLIB_PATH)/aoiaux.so \
	$(LUA_CLIB_PATH)/float.so \
	$(CSERVICE_PATH)/room.so

clean:
	rm -rf $(LUA_CLIB_PATH)/test.so \
	 $(LUA_CLIB_PATH)/aoiaux.so \
	 $(LUA_CLIB_PATH)/float.so \
	 $(CSERVICE_PATH)/room.so