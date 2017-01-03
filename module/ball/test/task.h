#ifndef TASK_H
#define TASK_H

#define TASK_NONE    0  // not init or delete
#define TASK_NORMAL  1  // create
#define TASK_RESUME  (1 << 1)  // resume
#define TASK_YIELD   (1 << 2)  // yield not use
#define TASK_SUSPEND ((1 << 8) | TASK_YIELD) // syspend for yield
#define TASK_WAITING ((2 << 8) | TASK_YIELD) // waitting for yield
#define TASK_RETURN  (1 << 8)

#define live(x) (((x)->state & 0xff & (TASK_RESUME | TASK_YIELD)) > 0)

typedef void * (*pfn_task_t)(struct task_t *ta, void *ud);

struct stCoRoutine_t;
struct taskpool_t;
struct task_t {
	int            id;  // not change after init
	stCoRoutine_t *co;  // not change after init

	int            state;
	pfn_task_t     func;
	void          *arg;
	void          *res;

	struct task_t     *next;
	struct taskpool_t *pool;
};

void task_init(struct task_t *self, struct taskpool_t *pool);
void task_exit(struct task_t *self);
void task_resume(struct task_t *self, pfn_task_t func, void *arg, void *res);
void task_wait(struct task_t *self);
void task_suspend(struct task_t *self);
void task_return(struct task_t *self);
void task_print(struct task_t *self);
#endif