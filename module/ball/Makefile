include ./../../platform.mk

AOI_SRC_PATH  := ../../3rd/aoi
PLAY_SRC_PATH := ../../3rd/Maria/Plugins/play
PHYSX_INC     := ../../3rd/PhysX-3.4/PhysX_3.4/Include
PHYSX_INC     += ../../3rd/PhysX-3.4/PxShared/include
PHYSX_LIB     := ../../3rd/PhysX-3.4/PhysX_3.4/Lib/linux64
PHYSX_LIB     += ../../3rd/PhysX-3.4/PxShared/lib/linux64
PHYSX_BIN     := ../../3rd/PhysX-3.4/PhysX_3.4/Bin/linux64
PHYSX_BIN     += ../../3rd/PhysX-3.4/PxShared/bin/linux64

SKYNET_INC := ../../3rd/skynet/skynet-src
LIBCO_INC  := ../../3rd/libco
LIBCO_LIB  := ../../bin

CSERVICE_PATH    := cservice
SERVICE_SRC_PATH := service-src
LUA_CLIB_PATH    := luaclib
CLIB_SRC_PATH    := lualib-src

LUA_INC ?= /usr/local/include

CFLAGS    := -g -O2 -Wall
CPPFLAGES := -std=c++11 -fpermissive -Wnarrowing $(CFLAGS)

.PHONY: clean

$(LUA_CLIB_PATH):
	mkdir $(LUA_CLIB_PATH)

$(CSERVICE_PATH):
	mkdir $(CSERVICE_PATH)


# lualib
$(LUA_CLIB_PATH)/battle.so: $(SERVICE_SRC_PATH)/battle.c | $(LUA_CLIB_PATH)
	$(CC) $(CFLAGS) $(SHARED) -I$(LUA_INC) -I$(SERVICE_SRC_PATH) -I$(SKYNET_INC) $^ -o $@


# service battle
battle_cppfiles        :=
#battle_cppfiles        += $(wildcard $(PLAY_SRC_PATH)/*.cpp)
# battle_cppfiles        += $(PLAY_SRC_PATH)/App.cpp
# battle_cppfiles        += $(PLAY_SRC_PATH)/Context.cpp
# battle_cppfiles        += $(PLAY_SRC_PATH)/Map.cpp
# battle_cppfiles        += $(PLAY_SRC_PATH)/Player.cpp
# battle_cppfiles        += $(PLAY_SRC_PATH)/PlayerMgr.cpp
# battle_cppfiles        += $(PLAY_SRC_PATH)/Scene.cpp
# battle_cppfiles        += $(PLAY_SRC_PATH)/stdafx.cpp
# battle_cppfiles        += $(SERVICE_SRC_PATH)/battled.cpp
# battle_cppfiles        += $(SERVICE_SRC_PATH)/rbtree.c
# battle_cppfiles        += $(SERVICE_SRC_PATH)/service.cpp
battle_cppfiles        += $(SERVICE_SRC_PATH)/service_battle.c

battle_debug_defines   := PHYSX_PROFILE_SDK
battle_debug_defines   += _DEBUG
battle_debug_defines   += PX_DEBUG
battle_debug_defines   += PX_CHECKED
battle_debug_defines   += PX_SUPPORT_VISUAL_DEBUGGER

battle_debug_hpaths    := 
battle_debug_hpaths    += $(SKYNET_INC)
battle_debug_hpaths    += $(LIBCO_INC)
battle_debug_hpaths    += $(PLAY_SRC_PATH)
battle_debug_hpaths    += $(PHYSX_INC)
battle_debug_hpaths    += $(CLIB_SRC_PATH)

battle_debug_lpaths    := $(PHYSX_LIB)
battle_debug_lpaths    += $(PHYSX_BIN)
battle_debug_lpaths    += $(LIBCO_LIB)

battle_debug_libraries :=
battle_debug_libraries += PxFoundationDEBUG_x64
battle_debug_libraries += PxPvdSDKDEBUG_x64
battle_debug_libraries += PsFastXmlDEBUG
battle_debug_libraries += PxTaskDEBUG
battle_debug_libraries += PhysX3ExtensionsDEBUG
battle_debug_libraries += PhysX3CommonDEBUG_x64
battle_debug_libraries += PhysX3CookingDEBUG_x64
battle_debug_libraries += PhysX3DEBUG_x64

# battle_debug_libraries += X11
# battle_debug_libraries += Xxf86vm
# battle_debug_libraries += Cg
# battle_debug_libraries += CgGL
# battle_debug_libraries += rt
battle_debug_libraries += pthread
battle_debug_libraries += dl

# debug_common_cflags	 := $(custom_cflags)
battle_debug_common_cflags  := -MMD
battle_debug_common_cflags  += $(addprefix -D, $(battle_debug_defines))
battle_debug_common_cflags  += $(addprefix -I, $(battle_debug_hpaths))
battle_debug_common_cflags  += -m64
battle_debug_common_cflags  += -Werror -m64 -fPIC -msse2 -mfpmath=sse -ffast-math -fno-exceptions -fno-rtti -fvisibility=hidden -fvisibility-inlines-hidden
battle_debug_common_cflags  += -Wall -Wextra -Wstrict-aliasing=2 -fdiagnostics-show-option
battle_debug_common_cflags  += -Wno-long-long
battle_debug_common_cflags  += -Wno-unknown-pragmas -Wno-char-subscripts -Wno-unused-variable -Wno-reorder -Wno-sign-compare
battle_debug_common_cflags  += -Wno-unused-parameter
battle_debug_common_cflags  += -g3 -gdwarf-2
# battle_debug_common_cflags  += -fexceptions

# $(CSERVICE_PATH)/battle.so: $(battle_cppfiles) | $(CSERVICE_PATH) 
# 	g++ $(CPPFLAGES) $(SHARED) $(battle_debug_common_cflags) $^ -o $@ $(addprefix -L, $(battle_debug_lpaths)) -Wl,-Bdynamic $(addprefix -l, $(battle_debug_libraries))

$(CSERVICE_PATH)/battle.so: $(battle_cppfiles) | $(CSERVICE_PATH)
	g++ $(CPPFLAGES) $(SHARED) -o $@ $^ $(addprefix -I, $(battle_debug_hpaths))

all: $(LUA_CLIB_PATH)/battle.so \
	$(CSERVICE_PATH)/battle.so

clean:
	rm -rf $(LUA_CLIB_PATH)/battle.so \
	 $(CSERVICE_PATH)/battle.so