#ifndef __SERVICE_ROOM_H_
#define __SERVICE_ROOM_H_

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>
#include <co_routine.h>

typedef void * (*pfn_task_t)(void *ud);

struct task_t {
	stCoRoutine_t *co;
	pfn_task_t     func;
	void          *arg;
	void          *res;
};

struct battle {
	struct task_t *slots;
	int            cap;
	int            size;
	int            free;
};

struct battle * 
battle_alloc();

void 
battle_free(struct battle *self);

struct task_t *
battle_create_task(struct battle *self);

#ifdef __cplusplus
}
#endif
#endif