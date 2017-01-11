#include "taskpool.h"
#include "task.h"
#include "taskpools.h"

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
std::vector<int> v;
std::queue<

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

void f() {
	std::queue<message> q;
	while (true) {
		message *msg = NULL;
		m1.lock();
		if (gq.size() > 0)
		{
			gq.peek()->thtreid == this_thread;
			msg = gq.peek();
		}
		m1.unlock();
		if (msg == NULL)
		{
			if (q.szie() > 0)
			{
			msg = q.peek();
			}
		}
		if (msg != NULL)
		{
			/* code */
		}
		

		std::cout << "thread id:" << std::this_thread::get_id() << std::endl;
		m1.lock();
		if (v.size() <= 0) {
			// std::this_thread::sleep_for(std::chrono::seconds(2));
			// continue;
			m1.unlock();

			break;
		} else {

			int a = v.back();
			v.pop_back();
			m1.unlock();

			taskpool_t *pool = taskpools::instance()->cur_pool();

			taskpool_resume(pool, NULL, routine, (void *)&a, (void *)&a);
		}		
	}

	taskpools::instance()->free_cur_pool();
}

int main() {

	for (int i = 0; i < 10; ++i)
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

