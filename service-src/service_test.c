#include "skynet.h"

struct test {
	int dummy;
};

static int 
_cb(struct skynet_context *ctx, void *ud, int type, int session, uint32_t source, const void *msg, size_t sz) {
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
test_init(struct test *inst, skynet skynet_context *ctx, const char *parm) {
	if (parm == NULL) {
		return 1;
	}
	skynet_callback(ctx, inst, _cb);
	return 0;
}
