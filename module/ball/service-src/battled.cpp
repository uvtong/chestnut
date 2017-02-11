#include "battled.h"
#include "battle_message.h"

#include <functional>

battled::battled() {
	register_cmd("start", std::bind(&battled::cmd_start, this, std::placeholders::_1));
	register_cmd("close", std::bind(&battled::cmd_close, this, std::placeholders::_1));
	register_cmd("kill", std::bind(&battled::cmd_kill, this, std::placeholders::_1));
	register_cmd("join", std::bind(&battled::cmd_join, this, std::placeholders::_1));
	register_cmd("leave", std::bind(&battled::cmd_leave, this, std::placeholders::_1));
	register_cmd("opcode", std::bind(&battled::cmd_opcode, this, std::placeholders::_1));
	register_cmd("update", std::bind(&battled::cmd_update, this, std::placeholders::_1));
}

battled::~battled() {
}

void * battled::cmd_start(void *arg) {
	service::cmd_start(arg);
	_app.start();
	return nullptr;
}

void * battled::cmd_close(void * arg) {
	service::cmd_close(arg);
	_app.close();
	return nullptr;
}

void * battled::cmd_kill(void *arg) {
	service::cmd_kill(arg);
	_app.kill();
	return nullptr;
}

void * battled::cmd_join(void *arg) {
	_app.join(1, 0, 1);
	return nullptr;
}

void * battled::cmd_leave(void *arg) {
	_app.leave(1, 0, 1);
	return nullptr;
}

void * battled::cmd_opcode(void *arg) {
	_app.opcode();
	return nullptr;
}

void * battled::cmd_update(void *arg) {
	// struct battle_update_message *msg = (struct battle_update_message *)arg;
	_app.update(1.0f);
	return nullptr;
}