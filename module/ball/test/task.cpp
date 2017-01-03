#include "task.h"
#include "taskpool.h"

#include <co_routine.h>
#include <assert.h>
#include <stdio.h>
#include <stdbool.h>
#include <stdint.h>

static uint32_t id = 0;

static void *
routine(void *arg) {
	struct task_t *ctx = (struct task_t *)arg;
	for (;live(ctx);)
	{
		if (ctx->func != NULL)
		{
			ctx->res = ctx->func(ctx, ctx->arg);
		}
		struct taskpool_t *pool = ctx->pool;
		taskpool_wait(pool, ctx);
	}
	return NULL;
}

static bool
check(struct task_t *head, struct task_t *other) {
	struct task_t *node = head;
	while (node) {
		if (node == other) {
			return true;
		}
	}
	return false;
}

void task_init(struct task_t *self, struct taskpool_t *pool) {
	self->id = ++id;
	co_create(&self->co, NULL, routine, self);
	
	self->state = TASK_NORMAL;
	self->func = NULL;
	self->arg  = NULL;
	self->res  = NULL;

	self->next = NULL;
	self->pool = pool;
}

void task_exit(struct task_t *self) {
	assert(self->state == TASK_NORMAL || self->state == TASK_RETURN);
	co_release(self->co);
	self->id = -1;
	self->state = TASK_NONE;
	self->func = NULL;
	self->arg  = NULL;
	self->res  = NULL;

	self->next = NULL;
}

void task_resume(struct task_t *self, pfn_task_t func, void *arg, void *res) {
	if (self->state == TASK_SUSPEND) {
		self->state = TASK_RESUME;
		co_resume(self->co);		
	} else if (self->state == TASK_WAITING) {
		self->func = func;
		self->arg = arg;
		self->res = res;
		self->state = TASK_RESUME;
		co_resume(self->co);
	} else if (self->state == TASK_NORMAL) {
		self->func = func;
		self->arg = arg;
		self->res = res;
		self->state = TASK_RESUME;
		co_resume(self->co);
	} else {
		assert(false);
	}
}

void task_wait(struct task_t *self) {
	assert(self->state == TASK_RESUME);
	self->state = TASK_WAITING;
	co_yield(self->co);
}

void task_suspend(struct task_t *self) {
	assert(self->state == TASK_RESUME);
	self->state = TASK_SUSPEND;
	co_yield(self->co);
}

void task_return(struct task_t *self) {
	assert(self->state == TASK_WAITING);
	self->state = TASK_RETURN;
	co_resume(self->co);
}

void task_print(struct task_t *self) {
	if (self->state == TASK_NORMAL)
	{
		printf("%s\n", "normal");
	} else if (self->state == TASK_RESUME) {
		printf("%s\n", "resume");
	} else if (self->state == TASK_WAITING) {
		printf("%s\n", "waiting");
	} else if (self->state == TASK_SUSPEND) {
		printf("%s\n", "suspend");
	}
}