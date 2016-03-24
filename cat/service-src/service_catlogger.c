#include "skynet.h"
#include "skynet_env.h"

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

struct logger {
	FILE * handle;
	int close;
};

struct logger *
catlogger_create(void) {
	struct logger * inst = skynet_malloc(sizeof(*inst));
	inst->handle = NULL;
	inst->close = 0;
	return inst;
}

void
catlogger_release(struct logger * inst) {
	if (inst->close) {
		fclose(inst->handle);
	}
	skynet_free(inst);
}

static int
_logger(struct skynet_context * context, void *ud, int type, int session, uint32_t source, const void * msg, size_t sz) {
	struct logger * inst = ud;
	fprintf(inst->handle, "[:%08x] ",source);
	fwrite(msg, sz , 1, inst->handle);
	fprintf(inst->handle, "\n");
	fflush(inst->handle);

	return 0;
}

int
catlogger_init(struct logger * inst, struct skynet_context *ctx, const char * parm) {
	if (parm) {
		const char *logpath = skynet_getenv("logpath");
		int logpath_sz = strlen(logpath);
		int parm_sz = strlen(parm);
		int sz = logpath_sz + parm_sz;
		char tmp[255] = { 0 };
		if (sz > 255) {
			fprintf(stderr, "%s\n", "length of logpath more than 255.");
			return 1;
		}
		memset(tmp, 0, 255);
		memcpy(tmp, logpath, logpath_sz);
		memcpy(&tmp[logpath_sz], parm, parm_sz);
		inst->handle = fopen(tmp,"w");
		if (inst->handle == NULL) {
			return 1;
		}
		inst->close = 1;
	} else {
		inst->handle = stdout;
	}
	if (inst->handle) {
		skynet_callback(ctx, inst, _logger);
		skynet_command(ctx, "REG", ".logger");
		return 0;
	}
	return 1;
}
