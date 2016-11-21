#include "RoomContext.h"

#ifdef __cplusplus
extern "C" {
#endif

#include "skynet.h"
#include "skynet_env.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <time.h>

struct room {
	struct skynet_context *ctx;
	RoomContext room;
};

static void
update() {

}

static int
_cb(struct skynet_context *context, void *ud, int type, int session, uint32_t source, const *msg, size_t sz) {
	if (type == PTYPE_TEXT) {
		/* code */

	}
}

struct room *
room_create(void) {
	struct room *inst = skynet_malloc(sizeof(inst));
	inst->ctx = NULL;
	return inst;
}

void
room_release(struct room *inst) {
	if (inst) {
		/* code */
	}
}

int
room_init(struct room *inst, struct skynet_context *ctx, const char *parm) {
	inst->ctx = ctx;
	skynet_command(ctx, "TIMEOUT", )
}

#ifdef __cplusplus
}
#endif