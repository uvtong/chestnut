#include "skynet.h"
#include "skynet_socket.h"

#include "rbtree.h"

#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <stdarg.h>
#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>

#define SIZE 11

struct connection_ud {
	int id;
	int session;
};

struct udpgate {
	int id;
	char host[128];
	int port;
	int room;
	struct rbtree *id2v;
	struct rbtree *session2v;
};

static int
comp(void *_1, void *_2) {
	return 1;
}

static void
_ctrl(struct skynet_context *ctx, struct udpgate *ud, const void *msg, size_t sz) {
}

static void
dispatch_socket_message(struct skynet_context *ctx, struct udpgate *ud, const struct skynet_socket_message *msg, int sz) {
	switch (msg->type) {
		case SKYNET_SOCKET_TYPE_DATA: {
			break;
		}
		case SKYNET_SOCKET_TYPE_CLOSE:
		case SKYNET_SOCKET_TYPE_ERROR: {
			break;
		}
		case SKYNET_SOCKET_TYPE_WARNING: {
			skynet_error(ctx, "fd (%d)", msg->id);
			break;
		}
	}
}

static int
_cb(struct skynet_context *ctx, void *ud, int type, int session, uint32_t source, const void *msg, size_t sz) {
	switch(type) {
		case PTYPE_TEXT:
		_ctrl(ctx, ud, msg, sz);
		break;
		case PTYPE_SOCKET:
		// dispatch_socket_message(ctx, ud, msg, (int)(sz - sizeof(struct skynet_socket_msssage)));
		break;
	}
	return 0;
}

struct udpgate *
udpgate_create() {
	struct udpgate *inst = skynet_malloc(sizeof(*inst));
	memset(inst, 0, sizeof(*inst));
	inst->id = -1;
	inst->port = -1;
	inst->room = -1;
	inst->id2v = rbtree_alloc(comp);
	inst->session2v = rbtree_alloc(comp);
	return inst;
}

void 
udpgate_release(struct udpgate *inst) {
	if (inst->id2v != NULL) {
		rbtree_free(inst->id2v);
	}
	if (inst->session2v != NULL) {
		rbtree_free(inst->session2v);
	}
	skynet_free(inst);
}

int 
udpgate_init(struct udpgate *inst, struct skynet_context *ctx, const char *parm) {
	if (parm == NULL)
		return 1;
	int sz = strlen(parm) + 1;
	char binding[sz];
	int port = 0;
	int n = sscanf(parm, "%s %d", binding, &port);
	if (n < 2) {
		skynet_error(ctx, "Invalid gate parm %s", parm);
		return 1;
	}

	skynet_callback(ctx, inst, _cb);

	inst->id = skynet_socket_udp(ctx, binding, port);
	if (inst->id < 0)
		return 1;
	return 0;
}


static void
test(void) {
	// struct connection_array *arr = connection_array_alloc(16);
	// struct rbtree *tree = rbtree_alloc(arr);

	// for (int i = 0; i < 101; ++i) {
	// 	struct connection *c = NULL;
	// 	assert(rbtree_insert(tree, tree->root, i, -1, &c));
	// }
	// rbtree_foreach(tree, tree->root, print);

	// struct connection *c = NULL;
	// rbtree_remove(tree, tree->root, 72, &c);
	// rbtree_remove(tree, tree->root, 14, &c);
	// rbtree_remove(tree, tree->root, 32, &c);
	// rbtree_remove(tree, tree->root, 16, &c);
	// rbtree_remove(tree, tree->root, 29, &c);
	// rbtree_remove(tree, tree->root, 56, &c);

	// printf("%s\n", "abc");
	// rbtree_foreach(tree, tree->root, print);
}

int main(void) {
	test();
	return 0;
}