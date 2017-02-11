#ifndef BATTLED_H
#define BATTLED_H

#include "App.h"
#include "service.h"

class battled : public service {
public:
	battled();
	virtual ~battled();

	virtual void * cmd_start(void *arg) override;
	virtual void * cmd_close(void * arg) override;
	virtual void * cmd_kill(void *arg) override;

	void * cmd_join(void *arg);
	void * cmd_leave(void *arg);
	void * cmd_opcode(void *arg);
	void * cmd_update(void *arg);
	
private:
	App _app;
};

#endif