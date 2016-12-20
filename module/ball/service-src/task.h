#ifndef TASK_H
#define TASK_H

#include <co_routine.h>

struct task_t {
	stCoRoutine_t *co;
	pfn_task_t     func;
	void          *arg;
	void          *res;
};

void task_init(struct task_t *self);
void task_exit(struct task_t *self);

#endif