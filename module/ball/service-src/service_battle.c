#ifdef __cplusplus
extern "C" {
#endif

#include "skynet.h"
#include "skynet_malloc.h"

#include "service_battle.h"

#include "battle.h"
#include "text_message.h"


#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <time.h>
#include <assert.h>

struct battle *
battle_alloc() {
	struct battle *inst = (struct battle *)skynet_malloc(sizeof(*inst));
	return inst;
}

void 
battle_free(struct battle *self) {
	skynet_free(self);
}

static void
_ctrl(struct skynet_context *context, void *ud, int session, uint32_t source, const void *msg, size_t sz) {
	struct battle *inst = (struct battle *)ud;
	struct text_message *message = (struct text_message *)msg;
	struct battle_message *ud = NULL;
	if (strcmp(text_message_unpack(message, ud), "JOIN") == 0) {
		inst->
	} else if (strcmp(text_message_unpack(message, ud), "JOIN") == 0) {

	}
}

static int
_cb(struct skynet_context *context, void *ud, int type, int session, uint32_t source, const void *msg, size_t sz) {
	struct room *r = (struct room *)ud;
	if (type == PTYPE_TEXT) {
		assert(sz == 4);
		struct room_msg *message = (struct room_msg*)(msg);
		if (strcmp(message->cmd, "start") == 0) {
		}
	} else if (type == PTYPE_RESPONSE) {
	}
	return 0;
}

struct room *
room_create(void) {
	struct room *inst = room_alloc();
	memset(inst, 0, sizeof(*inst));
	return inst;
}

void
room_release(struct room *inst) {
	room_free(inst);
}

int
room_init(struct room *inst, struct skynet_context *ctx, const char *parm) {
	skynet_callback(ctx, inst, _cb);
	skynet_command(ctx, "TIMEOUT", )
	// skynet_command(ctx, "REG", ".ROOM");
	return 0;
}

#ifdef __cplusplus
}
#endif
