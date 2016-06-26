#include "skynet.h"
#include "skynet_env.h"

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <time.h>

struct logger {
	FILE * handle;
	int close;
	time_t today_tt;
	char path[128];
	int path_cp;
	int path_sz;
};

static FILE * 
getname(struct logger *inst) {
	time_t res = time(NULL);
	printf("UTC:   %s", asctime(gmtime(&res)));
    printf("local: %s", asctime(localtime(&res)));

	struct tm *today = localtime(&res);
	struct tm *t = localtime(&inst->today_tt);
	printf("%ld-%ld\n", (long)res, (long)inst->today_tt);
	printf("%d-%d-%d\n", t->tm_year, t->tm_mon, t->tm_mday);
	printf("%d-%d-%d\n", today->tm_year, today->tm_mon, today->tm_mday);
	if (inst->today_tt == 0 ||
		today->tm_year != t->tm_year || 
		today->tm_mon != t->tm_mon ||
		today->tm_mday != t->tm_mday) {
		inst->today_tt = res;
		sprintf(&inst->path[inst->path_sz], "%d-%d-%d.log", today->tm_year+1900, today->tm_mon, today->tm_mday);
		if (inst->close) {
			fclose(inst->handle);
			inst->close = 0;
		}
		printf("%s\n", inst->path);
		inst->handle = fopen(inst->path,"a");
		if (inst->handle) {
			inst->close = 1;
			return inst->handle;
		} else {
			return NULL;
		}
	} else {
		printf("%s\n", "cccedf");
		return inst->handle;
	}
}

struct logger *
catlogger_create(void) {
	struct logger * inst = skynet_malloc(sizeof(*inst));
	inst->handle = NULL;
	inst->close = 0;
	inst->today_tt = 0;
	inst->path_cp = 128;
	inst->path_sz = 0;
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

	FILE *handle = getname(inst);
	if (handle) {
		time_t res = time(NULL);
		struct tm *t = localtime(&res);
		char tmp[32] = {0};
		sprintf(tmp, "%d-%d-%d %d-%d-%d", t->tm_year, t->tm_mon, t->tm_mday, t->tm_hour, t->tm_min, t->tm_sec);
		fprintf(handle, "[:%08x] [%s]",source, tmp);
		fwrite(msg, sz , 1, handle);
		fprintf(handle, "\n");
		fflush(handle);
	}
	
	return 0;
}

int
catlogger_init(struct logger * inst, struct skynet_context *ctx, const char * parm) {
	if (parm) {
		const char *logpath = skynet_getenv("logpath");
		int logpath_sz = strlen(logpath);
		int parm_sz = strlen(parm);
		int sz = logpath_sz + parm_sz;
		inst->path_sz = sz;
		if (sz > inst->path_cp) {
			fprintf(stderr, "%s\n", "length of logpath more than 255.");
			return 1;
		}
		memset(inst->path, 0, 128);
		memcpy(inst->path, logpath, logpath_sz);
		memcpy(&inst->path[logpath_sz], parm, parm_sz);
		FILE *handle = getname(inst);
		if (handle == NULL) {
			printf("%s\n", "abc");
			return 1;
		}
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
