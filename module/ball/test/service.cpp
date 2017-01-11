#include "taskpool.h"
#include <pthread.h>


static uint32_t Service::_count = 0;

service::service() {
	_count++;

	register_cmd("start", std::bind(&service::cmd_start, this, std::_1));
	register_cmd("close", std::bind(&service::cmd_close, this, std::_1));
	register_cmd("kill", std::bind(&service::cmd_kill, this, std::_1));
}

service::~service() {
	_count--;
}

void service::register_cmd(const char *cmd, cmd_cb cb) {
	if (_map.find(cmd) != _map.end()) {
		_map[cmd] = cb;
	} else {
		_map[cmd] = cb;
	}
}

void unregister_cmd(const char *cmd) {
	if (_map.find(cmd) != _map.end()) {
		_map.erase(cmd);
	}
}

void * service::cmd_start(void *arg) {
	return 1;
}

void * service::cmd_close(void *arg) {
	return 1;
}

void * service::cmd_kill(void *arg) {
	return 1;
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