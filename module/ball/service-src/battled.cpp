#include "battled.h"
#include "battle_message.h"

battled::battled() {
	register_cmd("start", std::bind(&service::cmd_join, this, std::_1));
	register_cmd("start", std::bind(&service::cmd_leave, this, std::_1));
	register_cmd("start", std::bind(&service::cmd_opcode, this, std::_1));
}

battled::~battled() {
}

void * battled::cmd_join(void *arg) {

}

void * battled::cmd_leave(void *arg) {
}

void * battled::cmd_opcode(void *arg) {

}

void * battled::cmd_update(void *arg) {
	struct battle_update_message *msg = (struct battle_update_message *)arg;
}