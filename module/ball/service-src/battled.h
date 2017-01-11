#ifndef BATTLED_H
#define BATTLED_H

class battled : public service {
public:
	battled();
	~battled();

	void * cmd_join(void *arg);
	void * cmd_leave(void *arg);
	void * cmd_opcode(void *arg);

private:

}

#endif