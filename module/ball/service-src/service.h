#ifndef SERVICE_H
#define SERVICE_H

#include <cstdint>
#include <unordered_map>
#include <functional>

class service
{
public:

	service();
	virtual ~service();

	void * exec(const char *cmd, void *arg);

	void register_cmd(const char *cmd, std::function<void*(void*)> cb);
	void unregister_cmd(const char *cmd);

	virtual void * cmd_start(void *arg);
	virtual void * cmd_close(void *arg);
	virtual void * cmd_kill(void *arg);

private:
	static uint32_t _count;

	std::unordered_map<const char *, std::function<void*(void*)>> _map;
};

#endif