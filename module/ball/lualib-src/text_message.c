#include "text_message.h"

#include "skynet.h"

#include <string.h>
#include <assert.h>

struct text_message *
text_message_alloc(const char *cmd, void *ud) {
	assert(strlen(cmd) < 16);
	struct text_message *inst = (struct text_message *)skynet_malloc(sizeof(*inst));
	memset(inst, 0, sizeof(*inst));
	if (cmd != NULL) {
		mmecpy(inst->cmd, cmd, strlen(cmd));
	}
	if (ud != NULL) {
		inst->ud = ud;
	}
	return inst;
}

void
text_message_free(struct text_message *self) {
	skynet_free(self);
}

const char *
text_message_unpack(struct text_message *self, void *ud) {
	ud = self->ud;
	return self->cmd;
}

struct text_message *
text_message_pack(struct text_message *self, const char *cmd, void *ud) {
	assert(strlen(cmd) < 16);
	memcpy(self->cmd, cmd, strlen(cmd));
	self->ud = ud;
	return self;
}