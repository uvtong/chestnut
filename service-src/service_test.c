#include "skynet.h"

#include "test.h"

#include <string.h>

struct test {
	int dummy;
};

static void
_ctrl(struct skynet_context *ctx, struct test *ud, int session, uint32_t source, const void *msg, size_t sz) {
	struct test_message *message = (struct test_message *)msg;
	if (strcmp(message->cmd, "T") == 0) {
		skynet_error(ctx, "c service : %d", message->dummy);
		skynet_free(message);

		message = skynet_malloc(sizeof(*message));
		message->cmd[0] = 'T';
		message->cmd[1] = '\0';
		message->dummy = 11;
		skynet_send(ctx, 0, source, PTYPE_RESPONSE | PTYPE_TAG_DONTCOPY, session, message, sizeof(*message));
	}
}

static int 
_cb(struct skynet_context *ctx, void *ud, int type, int session, uint32_t source, const void *msg, size_t sz) {
	switch (type) {
		case PTYPE_TEXT: {
			_ctrl(ctx, ud, session, source, msg, sz);
		}
		break;
	}
	return 0;
}

struct test *
test_create() {
	struct test *inst = skynet_malloc(sizeof(*inst));
	memset(inst, 0, sizeof(*inst));
	return inst;
}

void
test_release(struct test *inst) {
	skynet_free(inst);
}

int
test_init(struct test *inst, struct skynet_context *ctx, const char *parm) {
	if (parm == NULL) {
		return 1;
	}
	skynet_callback(ctx, inst, _cb);
	skynet_command(ctx, "REG", ".TEST");
	return 0;
}
