#ifndef TASKPOOL_H
#define TASKPOOL_H

#include "task.h"

struct taskpool_t {
	struct task_t *slots;
	int            cap;
	int            size;
	int            free;
};




#endif