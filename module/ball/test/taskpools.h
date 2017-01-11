#ifndef TASKPOOLS_H
#define TASKPOOLS_H

#include "taskpool.h"

#include <map>
#include <mutex>
#include <thread>

class taskpools {
public:
	static taskpools* instance();
	static void release();

	taskpools();
	~taskpools();

	taskpool_t * cur_pool();

	void free_cur_pool();
private:
	static taskpools  *_inst;
	static std::mutex  _mtxpools;

	std::map<std::thread::id, taskpool_t *> _pools;
	std::mutex                              _mtx;
};

#endif