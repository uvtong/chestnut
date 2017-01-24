#include "battled.h"
#include "battle_message.h"

battled::battled() {
	register_cmd("start", std::bind(&battled::cmd_start, this, std::_1));
	register_cmd("close", std::bind(&service::cmd_close, this, std::_1));
	register_cmd("kill", std::bind(&service::cmd_kill, this, std::_1));
	register_cmd("join", std::bind(&service::cmd_join, this, std::_1));
	register_cmd("leave", std::bind(&service::cmd_leave, this, std::_1));
	register_cmd("opcode", std::bind(&service::cmd_opcode, this, std::_1));
	register_cmd("update", std::bind(&service::cmd_update, this, std::_1));
}

battled::~battled() {
}

void * battled::cmd_start(void *arg) {
	service::cmd_start(arg);
	_app.start();
}

void * battled::cmd_close(void * arg) {
	service::cmd_close(arg);
	_app.close();
}

void * battled::cmd_kill(void *arg) {
	service::cmd_kill(arg);
	_app.kill();
}

void * battled::cmd_join(void *arg) {
	_app.join(1, 0, 1);
}

void * battled::cmd_leave(void *arg) {
	_app.leave(1, 0, 1);
}

void * battled::cmd_opcode(void *arg) {
	_app.opcode();
}

void * battled::cmd_update(void *arg) {
	// struct battle_update_message *msg = (struct battle_update_message *)arg;
	_app.update();
}