#include "task.h"

void task_init(struct task_t *self) {
	co_create(&self->co, NULL, routine, self);
	self->func = NULL;
	self->arg  = NULL;
	self->res  = NULL;
}

void task_exit(struct task_t *self) {
	co_release(self->co);
}