#include "taskpool.h"

#ifdef __cplusplus
extern "C" {
#endif
#include "skynet.h"
#include "skynet_malloc.h"
#ifdef __cplusplus
}
#endif





struct taskpool_t *
taskpool_alloc() {
	struct taskpool_t *inst = (struct taskpool_t *)skynet_malloc(sizeof(*inst));
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
taskpool_free(struct taskpool_t *self) {
	for (int i = 0; i < self->cap; ++i)
	{
		struct task_t *ta = &self->slots[i];
		task_exit(ta);
	}
	skynet_free(self->slots);
	skynet_free(self);
}

struct task_t *
taskpool_create_task(struct taskpool_t *self) {
	if (self->size == self->cap)
	{
		// extand
		assert(false);
		return NULL;
	} else {
		if (self->free < 0) 
			self->free = self->cap - 1;
		struct task_t *ta = &self->slots[self->free];
		self->free--;
		self->size++;
		return ta;
	}
}

void 
taskpool_release_task(struct taskpool_t *self, struct task_t *ta) {
	self->size--;
}