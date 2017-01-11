#ifndef SERVICE_H
#define SERVICE_H

#include <cstdint>
#include <unordered_map>
#include <functional>

class service
{
public:

	service();
	~service();

	void register_cmd(const char *cmd, cmd_cb cb);
	void unregister_cmd(const char *cmd);

	void * cmd_start(void *arg);
	void * cmd_close(void *arg);
	void * cmd_kill(void *arg);

private:
	static uint32_t _count;

	std::unordered_map<const char *, std::function<void*(void*)>> _map;
};

#endif