#include "taskpool.h"
#include "taskconf.h"

#include <string.h>
#include <stdlib.h>
#include <assert.h>
#include <math.h>


#define add(head, item) (item)->next = (head); (head) = (item);
#define remove(T, head, item) \
T *node = (head); \
if (node == item) { \
	(head) = (head)->next; \
	(item)->next = NULL; \
} else { \
	while (node->next != NULL) { \
		if (node->next == item) { \
			node->next = node->next->next; \
			item->next = NULL; \
			break; \
		} \
		node = node->next; \
	} \
}  \
assert(item->next == NULL);

// #define pop(head, item) (head != NULL) ? head

struct taskpool_t {
	struct task_t *slots[10];
	int            size;

	struct task_t *normal;
	struct task_t *running;
	struct task_t *suspend;
	struct task_t *waiting;
};

struct taskpool_t *
taskpool_alloc() {
	struct taskpool_t *inst = (struct taskpool_t *)MALLOC(sizeof(*inst));
	memset(inst, 0, sizeof(*inst));
	inst->size = 0;
	taskpool_extend(inst);
	return inst;
}

void 
taskpool_free(struct taskpool_t *self) {
	assert(self->suspend == NULL);
	while (self->waiting != NULL)
	{
		struct task_t *ta = self->waiting;
		self->waiting = self->waiting->next;
		task_return(ta);
	}
	while (self->running != NULL) {
		struct task_t *ta = self->running;
		self->running = self->running->next;
		task_return(ta);
	}
	for (int i = 0; i < self->size; ++i)
	{
		int count = pow(10, i+1);
		for (int j = 0; j < count; ++j)
		{
			struct task_t *ta = &self->slots[i][j];
			task_exit(ta);
		}
		FREE(self->slots[i]);
	}
	FREE(self);
}

void 
taskpool_extend(struct taskpool_t *self) {
	int count = pow(10, self->size+1);
	struct task_t *slots = (struct task_t *)MALLOC(sizeof(struct task_t) * count);
	for (int i = 0; i < count; ++i)
	{
		struct task_t *ta = &slots[i];
		task_init(ta, self);
		add(self->normal, ta);
	}
	self->slots[self->size] = slots;
	self->size++;
}

void
taskpool_resume(struct taskpool_t *self, struct task_t *ta, pfn_task_t func, void *arg, void *res) {
	if (ta != NULL) {
		assert(ta->state == TASK_SUSPEND);
		remove(struct task_t, self->suspend, ta);
		add(self->running, ta);
		task_resume(ta, NULL, NULL, NULL);
		return;
	} else {
		if (self->waiting != NULL)
		{
			struct task_t *ta = self->waiting;
			self->waiting = ta->next;
			add(self->running, ta);
			task_resume(ta, func, arg, res);
			return;
		}
		if (self->normal != NULL) {
		} else {
			taskpool_extend(self);	
		}
		struct task_t *ta = self->normal;
		self->normal = ta->next;
		add(self->running, ta);
		task_resume(ta, func, arg, res);
	}
}

void 
taskpool_wait(struct taskpool_t *self, task_t *ta) {
	assert(ta->state == TASK_RESUME);
	remove(struct task_t, self->running, ta);
	add(self->waiting, ta);
	task_wait(ta);
}

void 
taskpool_suspend(struct taskpool_t *self, task_t *ta) {
	// remove from running
	assert(ta->state == TASK_RESUME);
	remove(struct task_t, self->running, ta);
	add(self->suspend, ta);
	task_suspend(ta);
}

struct task_t * taskpool_query(struct taskpool_t *self, int id) {
	for (int i = 0; i < self->size; ++i)
	{
		int count = pow(10, i+1);
		for (int j = 0; j < count; ++j)
		{
			struct task_t *ta = &self->slots[i][j];
			if (ta->id == id)
			{
				return ta;
			}
		}
	}
	return NULL;
}