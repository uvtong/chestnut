#include "taskpool.h"
#include "task.h"

#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <assert.h>
#include <vector>
#include <thread>
#include <map>
#include <mutex>
#include <iostream>

std::mutex  m1;  // for v
std::mutex  m2;  // pools
std::vector<int> v;
std::map<std::thread::id, taskpool_t *> pools;

struct routine_context {
	int arg;
	int res;
};

static void *
routine(struct task_t *ta, void *arg) {
	assert(ta);
	printf("task id: %d\n", ta->id);
	int *ctx = (int *)arg;
	(*ctx)++;
	printf("res = %d\n", *ctx);
	return arg;
}

static void *
routine_1(struct task_t *ta, void *arg) {
	assert(ta);
	printf("%s:%d\n", "routine_yield", ta->id);
	v.push_back(ta->id);
	taskpool_suspend(ta->pool, ta);
	return 0;
}

static void
test(void) {
	// struct task_t t1 = { NULL, 1 };
	// struct task_t t2 = { NULL, 2 };

	// // struct stCoRoutineAttr_t attr;
	// // attr.stack_size = 
	// co_create(&t1.co, NULL, routine, &t1);
	// co_create(&t2.co, NULL, routine, &t2);

	// co_resume(t1.co);
	// co_resume(t2.co);
	// co_resume(t1.co);
	// co_resume(t2.co);

	struct routine_context ctx;
	memset(&ctx, 0, sizeof(ctx));
	taskpool_t *pool = taskpool_alloc();
	taskpool_resume(pool, NULL, routine, (void *)&ctx, (void *)&ctx);
	taskpool_resume(pool, NULL, routine, (void *)&ctx, (void *)&ctx);
	taskpool_resume(pool, NULL, routine, (void *)&ctx, (void *)&ctx);
	taskpool_resume(pool, NULL, routine, (void *)&ctx, (void *)&ctx);

	for (int i = 0; i < 10; ++i)
	{
		taskpool_resume(pool, NULL, routine_1, (void *)&ctx, (void *)&ctx);	
	}
	for (int i = 0; i < v.size(); ++i)
	{
		printf("task id :%d\n", v[i]);
		struct task_t *ta = taskpool_query(pool, v[i]);
		assert(ta->state == TASK_SUSPEND);
	}
	for (int i = 0; i < 100; ++i)
	{
		taskpool_resume(pool, NULL, routine, (void *)&ctx, (void *)&ctx);		
	}
	printf("%s\n", "begain to resume");
	for (int i = 0; i < v.size(); ++i)
	{
		struct task_t *ta = taskpool_query(pool, v[i]);
		taskpool_resume(pool, ta, NULL, NULL, NULL);
	}

	taskpool_free(pool);

	printf("%s\n", "over");
}

void f() {
	while (true) {
		if (v.size() <= 0)
		{
			// std::this_thread::sleep_for(std::chrono::seconds(2));
			// continue;
			break;
		}
		std::cout << "thread id:" << std::this_thread::get_id() << std::endl;
		int a = 0;
		m1.lock();
		a = v.back();
		v.pop_back();
		m1.unlock();

		taskpool_t *pool = NULL;
		if (pools.find(std::this_thread::get_id()) != pools.end())
		{
			pool = pools[std::this_thread::get_id()];
		} else {
			pool = taskpool_alloc();
			m2.lock();
			pools[std::this_thread::get_id()] = pool;
			m2.unlock();
		}
		taskpool_resume(pool, NULL, routine, (void *)&a, (void *)&a);
	}
	taskpool_t *pool = NULL;
	if (pools.find(std::this_thread::get_id()) != pools.end())
	{
		pool = pools[std::this_thread::get_id()];
		taskpool_free(pool);
	}
}

int main() {

	for (int i = 0; i < 1000; ++i)
	{
		v.push_back(i);
	}

	std::thread t1(f);
	std::thread t2(f);
	std::thread t3(f);
	t1.join();
	t2.join();
	t3.join();

	printf("%s\n", "over");
	return 0;
}

