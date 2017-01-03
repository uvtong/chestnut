#include "taskpool.h"
#include <pthread.h>


static uint32_t Service::_count = 0;

Service::Service() {
}

Service::~Service() {
}

// struct service *
// service_alloc() {
// 	count++;

// }

// void service_free(struct service *) {
// 	count--;
// }

// void service_message(char *msg, int sz) {
// 	pthread_t key = pthread_self();
// 	if (h.contains(key)) {
// 		taskpool_t *tp = taskpool_alloc(10);
// 		h[key] = tp;
// 	}
// 	taskpool_resume(tp, )
// }