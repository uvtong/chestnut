#include "skynet.h"
#include "skynet_socket.h"

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

struct connection {
	int id;               // managed by rbtree
	int id_color;         // managed by rbtree, 0 back, 1 red.
	int id_parent;
	int id_lnext;         // managed by rbtree, -1 NULL.
	int id_rnext;

	int free;  // 1 use, 0 free. fixed by connection_arry

	void *ud;
};

struct connection_array {
	struct connection *data;
	int csize;
	int ccap;
	int cfree;
};

struct rbtree {
	struct connection_array *arr;
	int root;
	int size;
};

static struct connection_array *
connection_array_alloc(int cap) {
	struct connection_array *inst = (struct connection_array *)skynet_malloc(sizeof(*inst));
	if (inst == NULL) {
		return NULL;
	}
	inst->csize = 0;
	inst->ccap = cap;
	inst->cfree = cap -1;
	inst->data = NULL;
	struct connection *c = (struct connection *)skynet_malloc(sizeof(*c) * cap);
	if (c == NULL) {
		skynet_free(inst);
		return NULL;
	}
	inst->data = c;
	memset(c, 0, sizeof(*c) * cap);
	return inst;
}

static void
connection_array_free(struct connection_array *inst) {
	if (inst->data != NULL) {
		skynet_free(inst->data);
	}
	skynet_free(inst);
}

static struct connection *
connection_array_at(struct connection_array *inst, int idx) {
	return &inst->data[idx];
}

static int 
connection_array_idx(struct connection_array *inst, struct connection *c) {
	return (int)(c - inst->data);
}

static int 
connection_array_alloc_co(struct connection_array *inst) {
	if (inst->csize == inst->ccap) {
		int cap = inst->ccap * 2;
		struct connection *c = (struct connection *)skynet_malloc(sizeof(*c) * cap);
		memcpy(c, inst->data, inst->ccap * sizeof(struct connection));
		inst->data = c;
		// inst->csize
		inst->ccap = cap;
		inst->cfree = cap - 1;
	}
	int idx = 0;
	do {
		if (inst->cfree < 0) {
			inst->cfree = inst->ccap - 1;
		}
		idx = inst->cfree;
		if (inst->data[idx].free == 0) {
			inst->cfree--;
			inst->csize++;
			break;
		} else {
			inst->cfree--;
		}
	} while (1);
	struct connection *c = &inst->data[idx];
	assert(c->free == 0);
	c->free = 1;
	return idx;
}

static void
connection_array_free_co(struct connection_array *inst, int idx) {
	assert(idx < inst->ccap && idx >= 0);
	struct connection *c = &inst->data[idx];
	assert(c->free == 1);
	c->free = 0;
}

static struct rbtree *
rbtree_alloc(struct connection_array *arr) {
	assert(arr != NULL);
	struct rbtree *inst = (struct rbtree *)skynet_malloc(sizeof(*inst));
	if (inst == NULL) {
		return NULL;
	}
	inst->arr = arr;
	inst->root = -1;
	inst->size = 0;
	return inst;
}

static void 
rbtree_free(struct rbtree *inst) {
	skynet_free(inst);
}

// 
static void
rbtree_rotate_left_id(struct rbtree *inst, int idx) {
	assert(idx >= 0 && idx < inst->arr->ccap);
	struct connection *c = connection_array_at(inst->arr, idx);

	struct connection *p = connection_array_at(inst->arr, c->id_parent);

	struct connection *r = connection_array_at(inst->arr, c->id_rnext);
	
	c->id_rnext = r->id_lnext;
	c->id_parent = connection_array_idx(inst->arr, r);

	r->id_lnext = idx;
	r->id_parent = connection_array_idx(inst->arr, p);;

	if (p->id_rnext == idx) {
		p->id_rnext = connection_array_idx(inst->arr, r);	
	} else {
		p->id_lnext = connection_array_idx(inst->arr, r);
	}
	
	r->id_color = c->id_color;
	c->id_color = 1;   // red
}

static void
rbtree_rotate_right_id(struct rbtree *inst, int idx) {
	assert(idx >= 0 && idx < inst->arr->ccap);
	struct connection *c = connection_array_at(inst->arr, idx);

	struct connection *p = connection_array_at(inst->arr, c->id_parent);

	struct connection *l = connection_array_at(inst->arr, c->id_lnext);

	c->id_lnext = l->id_rnext;
	c->id_parent = connection_array_idx(inst->arr, l);

	l->id_rnext = idx;
	l->id_parent = connection_array_idx(inst->arr, p);

	if (p->id_rnext == idx) {
		p->id_rnext = connection_array_idx(inst->arr, l);
	} else {
		p->id_lnext = connection_array_idx(inst->arr, l);
	} 

	l->id_color = c->id_color;
	c->id_color = 1;  // red
}

static void
rbtree_flip_color(struct rbtree *inst, int idx) {
	assert(idx >= 0 && idx < inst->arr->ccap);
	struct connection *c = connection_array_at(inst->arr, idx);
	assert(c->id_color == 0);
	c->id_color = 1; // red

	struct connection *r = connection_array_at(inst->arr, c->id_rnext);
	struct connection *l = connection_array_at(inst->arr, c->id_lnext);
	r->id_color = 0;  // black
	l->id_color = 0;  // black
}

static bool
rbtree_fix(struct rbtree *inst, int idx) {
	assert(idx >= 0 && idx < inst->arr->ccap);
	struct connection *c = connection_array_at(inst->arr, idx);	
	if (c->id_parent == -1) {
		c->id_color = 0;  // black;
		return true;
	} else {
		struct connection *p = connection_array_at(inst->arr, c->id_parent);
		if (p->id_color == 0) {
			return true;
		} else {
			struct connection *g = connection_array_at(inst->arr, p->id_parent);
			if (g->id_lnext == c->id_parent) {
				struct connection *u = connection_array_at(inst->arr, g->id_rnext);
				if (c->id_color == 1 && p->id_color == 1 && u->id_color == 1) {
					rbtree_flip_color(inst, p->id_parent);
					return rbtree_fix(inst, p->id_parent);
				} else if (c->id_color == 1 && p->id_color == 1 && u->id_color == 0) {
					if (p->id_lnext == idx) {
					 	rbtree_rotate_right_id(inst, p->id_parent);
					 	return true;
					} else {
						rbtree_rotate_left_id(inst, connection_array_idx(inst->arr, p));
						return rbtree_fix(inst, connection_array_idx(inst->arr, p));
					}
				}
			} else {
				struct connection *u = connection_array_at(inst->arr, g->id_lnext);
				if (c->id_color == 1 && p->id_color == 1 && u->id_color == 1) {
					rbtree_flip_color(inst, p->id_parent);
					rbtree_fix(inst, p->id_parent);
				} else if (c->id_color == 1 && p->id_color == 1 && u->id_color == 0) {
					if (p->id_lnext == idx) {
						// rr
						rbtree_rotate_right_id(inst, connection_array_idx(inst->arr, p));
						return rbtree_fix(inst, connection_array_idx(inst->arr, p));
					} else {
						// rl
						rbtree_rotate_left_id(inst, connection_array_idx(inst->arr, g));
						return true;
					}
				}
			}
		}	
	}
}

static bool
rbtree_insert_id(struct rbtree *inst, int parent, int key, int idx, struct connection **cc) {
	if (parent == -1) {
		// achive c
		struct connection *c = NULL;
		if (idx == -1) {
			idx = connection_array_alloc_co(inst->arr);
			c = connection_array_at(inst->arr, idx);
		} else {
			c = connection_array_at(inst->arr, idx);
		}
		assert(c != NULL);
		assert(idx != -1);

		assert(inst->size == 0);
		inst->root = idx;
		inst->size++;
		
		c->id = key;
		c->id_color  = 0;   // black
		c->id_parent = -1;
		c->id_lnext  = -1;
		c->id_rnext  = -1;

		*cc = c;
		return true;
	} else {
		assert(parent >= 0 && parent < inst->arr->ccap);
		struct connection *p = connection_array_at(inst->arr, parent);
		if (key < p->id) {
			if (p->id_lnext == -1) {
				struct connection *c = NULL;
				if (idx == -1) {
					idx = connection_array_alloc_co(inst->arr);
					c = connection_array_at(inst->arr, idx);
				} else {
					c = connection_array_at(inst->arr, idx);
				}
				assert(c != NULL);
				assert(idx != -1);

				p->id_lnext = idx;
				inst->size++;

				c->id = key;
				c->id_color  = 1;  // red
				c->id_parent = -1;
				c->id_lnext  = -1;
				c->id_rnext  = -1;

				// fix 
				rbtree_fix(inst, idx);

				*cc = c;
				return true;
			} else {
				return rbtree_insert_id(inst, p->id_lnext, key, idx, cc);
			}
		} else {
			if (p->id_rnext == -1) {
				struct connection *c = NULL;
				if (idx == -1) {
					idx = connection_array_alloc_co(inst->arr);
					c = connection_array_at(inst->arr, idx);
				} else {
					c = connection_array_at(inst->arr, idx);
				}
				assert(c != NULL);
				assert(idx != -1);

				p->id_rnext = idx;
				inst->size++;

				c->id = key;
				c->id_color  = 1;
				c->id_parent = -1;
				c->id_lnext  = -1;
				c->id_rnext  = -1;

				// fix 
				rbtree_fix(inst, idx);

				*cc = c;
				return true;
			} else {
				return rbtree_insert_id(inst, p->id_rnext, key, idx, cc);
			}
		}
	}
}

static bool 
rbtree_remove_id(struct rbtree *inst, int parent, int key, struct connection **cc) {
	if (parent == -1) {
		return false;
	}
	assert(parent >= 0 && parent < inst->arr->ccap);
	struct connection *c = connection_array_at(inst->arr, parent);
	if (c->id_lnext == -1 && c->id_rnext == -1) {
		struct connection *p = connection_array_at(inst->arr, c->id_parent);
		if (p->id_rnext == connection_array_idx(inst->arr, c)) {
			p->id_rnext = -1;
		} else {
			p->id_lnext = -1;
		}
		c->free = 0;
		*cc = c;
		return true;
	} else {
	}
}

static bool
rbtree_search_id(struct rbtree *inst, int idx, int key, struct connection **cc) {
	if (idx == -1) { // leaf
		*cc = NULL;
		return false;
	}
	assert(idx >= 0 && idx < inst->arr->ccap);
	struct connection *c = connection_array_at(inst->arr, idx);
	if (key < c->id) {
		return rbtree_search_id(inst, c->id_lnext, key, cc);
	} else if (key == c->id) {
		*cc = c;
		return true;	
	} else {
		return rbtree_search_id(inst, c->id_rnext, key, cc);
	}
}


typedef void (*handler)(struct connection *c);

static void print(struct connection *c) {
	printf("%d\n", c->id);
}

static void
rbtree_foreach(struct rbtree *inst, int idx, handler h) {
	if (idx == -1) {
		return;
	}
	struct connection *c = connection_array_at(inst->arr, idx);
	h(c);
	rbtree_foreach(inst, c->id_lnext, h);
	rbtree_foreach(inst, c->id_rnext, h);
}

struct udpgate {
	int id;
	char host[128];
	int port;
	int room;
	struct connection_array *arr;
	struct rbtree *id2v;
	struct rbtree *session2v;
};

// static void
// _ctrl(struct skynet_context *ctx, struct udpgate *ud, const void *msg, size_t sz) {
// }

// static void
// dispatch_socket_message(struct skynet_context *ctx, struct udpgate *ud, const struct skynet_socket_message *msg, int sz) {
// 	switch (msg->type) {
// 		case SKYNET_SOCKET_TYPE_DATA: {
// 			break;
// 		}
// 		case SKYNET_SOCKET_TYPE_CLOSE:
// 		case SKYNET_SOCKET_TYPE_ERROR: {
// 			break;
// 		}
// 		case SKYNET_SOCKET_TYPE_WARNING: {
// 			skynet_error(ctx, "fd (%d)", msg->id);
// 			break;
// 		}
// 	}
// }

// static int
// _cb(struct skynet_context *ctx, void *ud, int type, int session, uint32_t source, const void *msg, size_t sz) {
// 	switch(type) {
// 		case PTYPE_TEXT:
// 		_ctrl(ctx, ud, msg, sz);
// 		break;
// 		case PTYPE_SOCKET:
// 		// dispatch_socket_message(ctx, ud, msg, (int)(sz - sizeof(struct skynet_socket_msssage)));
// 		break;
// 	}
// 	return 0;
// }

// struct udpgate *
// udpgate_create() {
// 	struct udpgate *inst = skynet_malloc(sizeof(*inst));
// 	memset(inst, 0, sizeof(*inst));
// 	inst->id = -1;
// 	inst->port = -1;
// 	inst->room = -1;
// 	inst->arr = connection_array_alloc(16);
// 	inst->id2v = rbtree_alloc(inst->arr);
// 	inst->session2v = rbtree_alloc(inst->arr);
// 	return inst;
// }

// void 
// udpgate_release(struct udpgate *inst) {
// 	if (inst->arr != NULL) {
// 		connection_array_free(inst->arr);
// 	}
// 	if (inst->id2v != NULL) {
// 		rbtree_free(inst->id2v);
// 	}
// 	if (inst->session2v != NULL) {
// 		rbtree_free(inst->session2v);
// 	}
// 	skynet_free(inst);
// }

// int 
// udpgate_init(struct udpgate *inst, struct skynet_context *ctx, const char *parm) {
// 	if (parm == NULL)
// 		return 1;
// 	int sz = strlen(parm) + 1;
// 	char binding[sz];
// 	int port = 0;
// 	int n = sscanf(parm, "%s %d", binding, &port);
// 	if (n < 2) {
// 		skynet_error(ctx, "Invalid gate parm %s", parm);
// 		return 1;
// 	}

// 	skynet_callback(ctx, inst, _cb);

// 	inst->id = skynet_socket_udp(ctx, binding, port);
// 	if (inst->id < 0)
// 		return 1;
// 	return 0;
// }

int main(void) {
	struct connection_array *arr = connection_array_alloc(16);
	struct rbtree *rbtree = rbtree_alloc(arr);

	for (int i = 0; i < 101; ++i) {
		struct connection *c = NULL;
		assert(rbtree_insert_id(rbtree, rbtree->root, i, -1, &c));
	}
	rbtree_foreach(rbtree, rbtree->root, print);

	return 0;
}