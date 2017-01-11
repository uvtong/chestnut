#ifndef TASKPOOL_H
#define TASKPOOL_H

#include "task.h"

struct taskpool_t;

struct taskpool_t *
taskpool_alloc();

void 
taskpool_free(struct taskpool_t *self);

void 
taskpool_extend(struct taskpool_t *self);

void
taskpool_resume(struct taskpool_t *self, struct task_t *ta, pfn_task_t func, void *arg, void *res);

void 
taskpool_wait(struct taskpool_t *self, task_t *ta);

void 
taskpool_suspend(struct taskpool_t *self, task_t *ta);

struct task_t * taskpool_query(struct taskpool_t *self, int id);

#endif