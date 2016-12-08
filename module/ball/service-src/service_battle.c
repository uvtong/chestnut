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

struct player {
	uint32_t uid;
	uint32_t sid;
	uint32_t session;
};

static void *
routine(void *arg) {
	struct task_t *ctx = (struct task_t *)arg;
	for (;;)
	{
		if (ctx->func != NULL)
		{
			ctx->res = ctx->func(ctx->arg);
		}
		co_yield(ctx->co);
	}
}

void task_init(struct task_t *self) {
	co_create(&self->co, NULL, routine, self);
	self->func = NULL;
	self->arg  = NULL;
	self->res  = NULL;
}

void task_exit(struct task_t *self) {
	co_release(self->co);
}

struct battle *
battle_alloc() {
	struct battle *inst = (struct battle *)skynet_malloc(sizeof(*inst));
	inst->size = 0;
	inst->cap  = 256;
	inst->free = 255;
	struct task_t *slots = (struct task_t *)skynet_malloc(sizeof(*slots) * inst->cap);
	for (int i = 0; i < inst->cap; ++i)
	{
		struct task_t *ta = &slots[i];
		task_init(ta);
	}
	inst->slots = slots;
	return inst;
}

void 
battle_free(struct battle *self) {
	for (int i = 0; i < self->cap; ++i)
	{
		struct task_t *ta = &self->slots[i];
		task_exit(ta);
	}
	skynet_free(self->slots);
	skynet_free(self);
}

struct task_t *
battle_create_task(struct battle *self) {
	if (self->size == self->cap)
	{
		// extand
		assert(false);
		return NULL;
	} else {
		if (self->free < 0) 
			self->free = self->cap - 1;
		struct task_t *ta = self->slots[self->free];
		self->free--;
		self->size++;
		return ta;
	}
}

void 
battle_release_task(struct battle *self, struct task_t *ta) {
	self->size--;
}

static void *
cmd_start(void *arg) {
	struct battle_message *message = (struct battle_message *)arg;
}

static void
_ctrl(struct skynet_context *ctx, void *ud, int session, uint32_t source, const void *msg, size_t sz) {
	struct battle *inst = (struct battle *)ud;
	struct text_message *message = (struct text_message *)msg;
	struct battle_message *ud = NULL;
	if (strcmp(text_message_unpack(message, ud), "START") == 0) {
		struct task_t * ta = battle_create_task(inst);
		ta->func = cmd_start;
		ta->arg  = battle_message;
		co_resume(ta->co);
		if (ta->res != NULL) {
			struct text_message *rsp = (struct text_message *)skynet_malloc(sizeof(*rsp));
			memcpy(rsp->cmd, "START", 5);
			rsp->cmd[5] = '\0';
			rsp->ud = skynet_malloc(sizeof(struct battle_rsp_message));
			skynet_send(ctx, 0, source, PTYPE_RESPONSE, session, rsp, sizeof(*rsp));
		}
	} else if (strcmp(text_message_unpack(message, ud), "CLOSE") == 0) {
	} else if (strcmp(text_message_unpack(message, ud), "KILL") == 0) {
	} else if (strcmp(text_message_unpack(message, ud), "JOIN") == 0) {
	} else if (strcmp(text_message_unpack(message, ud), "LEAVE") == 0) {
	} else if (strcmp(text_message_unpack(message, ud), "OPCODE") == 0) {
		
	}
	skynet_free(message);
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
