#include "taskpools.h"

taskpools* taskpools::_inst = nullptr;
std::mutex taskpools::_mtxpools;

taskpools* taskpools::instance() {
	_mtxpools.lock();
	if (_inst == nullptr)
	{
		_inst = new taskpools();
	}
	_mtxpools.unlock();
	return _inst;
}
	
void taskpools::release() {
	_mtxpools.lock();
	if (_inst != nullptr)
	{
		delete _inst;
		_inst = nullptr;
	}
	_mtxpools.unlock();
}

taskpools::taskpools() {
}

taskpools::~taskpools() {
}

taskpool_t * taskpools::cur_pool() {
	taskpool_t *pool = NULL;
	_mtx.lock();
	if (_pools.find(std::this_thread::get_id()) != _pools.end())
	{
		pool = _pools[std::this_thread::get_id()];
		_mtx.unlock();
	} else {
		pool = taskpool_alloc();
		_pools[std::this_thread::get_id()] = pool;
		_mtx.unlock();
	}
	return pool;
} 

void taskpools::free_cur_pool() {
	taskpool_t *pool = cur_pool();
	taskpool_free(pool);
	_pools[std::this_thread::get_id()] = nullptr;
	_pools.erase(std::this_thread::get_id());
}