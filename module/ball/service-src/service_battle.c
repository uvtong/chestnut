#ifdef __cplusplus
extern "C" {
#endif
#include "skynet.h"
#include "skynet_malloc.h"
#ifdef __cplusplus
}
#endif

#include "battle.h"
#include "text_message.h"
#include "rbtree.h"
#include "battled.h"

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <time.h>
#include <assert.h>

struct battle {
	battled *d;
};

static void
_ctrl(struct skynet_context *ctx, void *ud, int session, uint32_t source, const void *msg, size_t sz) {
	struct battle *inst = (struct battle *)ud;
	struct text_message *message = (struct text_message *)msg;
	void * res = inst->d->exec(message)

	struct battle_message *body = NULL;
	if (strcmp(text_message_unpack(message, (void**)&body), "START") == 0) {
		struct task_t * ta = battle_create_task(inst);
		ta->func = cmd_start;
		ta->arg  = body;
		co_resume(ta->co);
		if (ta->res != NULL) {
			struct text_message *rsp = (struct text_message *)skynet_malloc(sizeof(*rsp));
			memcpy(rsp->cmd, "START", 5);
			rsp->cmd[5] = '\0';
			rsp->ud = skynet_malloc(sizeof(struct battle_rsp_message));
			skynet_send(ctx, 0, source, PTYPE_RESPONSE, session, rsp, sizeof(*rsp));
		}
	} else if (strcmp(text_message_unpack(message, (void**)&body), "CLOSE") == 0) {
	} else if (strcmp(text_message_unpack(message, (void**)&body), "KILL") == 0) {
	} else if (strcmp(text_message_unpack(message, (void**)&body), "JOIN") == 0) {
	} else if (strcmp(text_message_unpack(message, (void**)&body), "LEAVE") == 0) {
	} else if (strcmp(text_message_unpack(message, (void**)&body), "OPCODE") == 0) {	
	}
	skynet_free(message);
}

static int
_cb(struct skynet_context *ctx, void *ud, int type, int session, uint32_t source, const void *msg, size_t sz) {
	if (type == PTYPE_TEXT) {
		_ctrl(ctx, ud, session, source, msg, sz);
	} else if (type == PTYPE_RESPONSE) {
	}
	return 0;
}


#ifdef __cplusplus
extern "C" {
#endif

struct battle *
battle_create(void) {
	struct battle *inst = skynet_malloc(sizeof(*inst));
	memset(inst, 0, sizeof(*inst));
	inst->d = new battled();
	return inst;
}

void
battle_release(struct battle *inst) {
	if (inst->d != NULL)
	{
		delete inst->d;
	}
	battle_free(inst);
}

int
battle_init(struct battle *inst, struct skynet_context *ctx, const char *parm) {
	skynet_callback(ctx, inst, _cb);
	// skynet_command(ctx, "TIMEOUT", )
	// skynet_command(ctx, "REG", ".ROOM");
	return 0;
}

#ifdef __cplusplus
}
#endif
