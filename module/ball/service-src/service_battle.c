#include "skynet.h"

#include "battle_message.h"

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <time.h>
#include <assert.h>

struct battle {
	int dummy;
};

static void
_ctrl(struct skynet_context *ctx, void *ud, int session, uint32_t source, const void *msg, size_t sz) {
	struct battle *inst = (struct battle *)ud;

	if (strcmp(cmd(msg), "start") == 0) {
		/* code */
	} else if (strcmp(cmd(msg), "close") == 0) {
	} else if (strcmp(cmd(msg), "close") == 0) {
	} else if (strcmp(cmd(msg), "kill") == 0) {
	} else if (strcmp(cmd(msg), "")) {
	}
	// void * res = inst->d->exec(cmd(msg), (void *)msg);
	// if (res != NULL) {
	// 	skynet_send(ctx, 0, source, PTYPE_RESPONSE, session, res, size(res));
	// }
	// skynet_free((void *)msg);
}

static int
_cb(struct skynet_context *ctx, void *ud, int type, int session, uint32_t source, const void *msg, size_t sz) {
	if (type == PTYPE_TEXT) {
		_ctrl(ctx, ud, session, source, msg, sz);
	} else if (type == PTYPE_RESPONSE) {
	}
	return 0;
}

struct battle *
battle_create(void) {
	struct battle *inst = (struct battle *)skynet_malloc(sizeof(*inst));
	memset(inst, 0, sizeof(*inst));
	return inst;
}

void
battle_release(struct battle *inst) {
	skynet_free(inst);
}

int
battle_init(struct battle *inst, struct skynet_context *ctx, const char *parm) {
	skynet_callback(ctx, inst, _cb);
	skynet_command(ctx, "REG", ".battle");

	// skynet_command(ctx, "TIMEOUT", )
	
	return 0;
}
