#include "RoomContext.h"

#ifdef __cplusplus
extern "C" {
#endif

#include "skynet.h"
#include "skynet_malloc.h"

#include "room.h"
#include "service_room.h"

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <time.h>
#include <assert.h>

struct room * room_alloc() {
	struct room *inst = (struct room *)skynet_malloc(sizeof(*inst));
	inst->room = new RoomContext();
	return inst;
}

void room_free(struct room *r) {
	skynet_free(r);
}

void room_send(struct room *r, uint32_t dst, int type, int session) {
	uint32_t handle = skynet_current_handle();
	// skynet_send(r->ctx, handle, dst, )
}

// static void
// _ctrl() {
// }

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
	return inst;
}

void
room_release(struct room *inst) {
	room_free(inst);
}

int
room_init(struct room *inst, struct skynet_context *ctx, const char *parm) {
	// skynet_command(ctx, "TIMEOUT", )
	skynet_callback(ctx, inst, _cb);
	return 0;
}

#ifdef __cplusplus
}
#endif
