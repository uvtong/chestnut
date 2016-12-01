#include "stdafx.h"
//#include "skynet.h"
//#include "skynet_socket.h"

#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <stdarg.h>
#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>


#define SIZE 11
#ifndef skynet_malloc
#define skynet_malloc malloc
#endif // !skynet_malloc

#ifndef skynet_free
#define skynet_free free
#endif // !skynet_free

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

	char *key;

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
	inst->cfree = cap - 1;
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
	if (idx >= 0 && idx < inst->ccap) {
		return &inst->data[idx];
	}
	return NULL;
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
	struct connection *c = NULL;
	int idx = 0;
	do {
		if (inst->cfree < 0) {
			inst->cfree = inst->ccap - 1;
		}
		idx = inst->cfree;
		c = &inst->data[idx];
		if (c->free == 0) {  // free
			inst->cfree--;
			inst->csize++;
			break;
		} else {
			inst->cfree--;
		}
	} while (1);
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
	inst->csize--;
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
rbtree_rotate_left(struct rbtree *inst, int idx) {
	assert(idx >= 0 && idx < inst->arr->ccap);
	struct connection *c = connection_array_at(inst->arr, idx);
	struct connection *p = connection_array_at(inst->arr, c->id_parent);
	struct connection *r = connection_array_at(inst->arr, c->id_rnext);
	struct connection *rl = connection_array_at(inst->arr, r->id_lnext);

	c->id_rnext = r->id_lnext;
	if (rl) {
		rl->id_parent = idx;
	}

	c->id_parent = connection_array_idx(inst->arr, r);
	r->id_rnext = idx;
	if (p) {
		if (p->id_rnext == idx) {
			p->id_rnext = connection_array_idx(inst->arr, r);
		} else {
			p->id_lnext = connection_array_idx(inst->arr, r);
		}
	} else {
		r->id_parent = -1;
	}

	r->id_color = c->id_color;
	c->id_color = 1;   // red
}

static void
rbtree_rotate_right(struct rbtree *inst, int idx) {
	assert(idx >= 0 && idx < inst->arr->ccap);
	struct connection *c = connection_array_at(inst->arr, idx);
	struct connection *p = connection_array_at(inst->arr, c->id_parent);
	struct connection *l = connection_array_at(inst->arr, c->id_lnext);
	struct connection *lr = connection_array_at(inst->arr, l->id_rnext);

	c->id_lnext = l->id_rnext;
	if (lr) {
		lr->id_parent = idx;
	}
	c->id_parent = connection_array_idx(inst->arr, l);

	l->id_rnext = idx;
	if (p) {
		l->id_parent = connection_array_idx(inst->arr, p);

		if (p->id_rnext == idx) {
			p->id_rnext = connection_array_idx(inst->arr, l);
		} else {
			p->id_lnext = connection_array_idx(inst->arr, l);
		}
	} else {
		l->id_parent = -1;
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

static void
rbtree_insert_fix(struct rbtree *inst, int idx) {
	assert(idx >= 0 && idx < inst->arr->ccap);
	struct connection *c = connection_array_at(inst->arr, idx);
	if (c->id_parent == -1) {    // case 1
		c->id_color = 0;  // black;
		return;
	} else {
		struct connection *p = connection_array_at(inst->arr, c->id_parent);
		if (p->id_color == 0) {  // case 2
			return;
		} else {
			// notice
			assert(c->id_color == 1 && p->id_color == 1);
			struct connection *g = connection_array_at(inst->arr, p->id_parent);
			struct connection *u = NULL;
			if (g && g->id_lnext == c->id_parent) {
				u = connection_array_at(inst->arr, g->id_rnext);
			} else {
				u = connection_array_at(inst->arr, g->id_lnext);
			}
			if (u && u->id_color == 1) { // case 3
				rbtree_flip_color(inst, p->id_parent);
				rbtree_insert_fix(inst, p->id_parent);
			} else { // case 4
				if (idx == p->id_rnext && c->id_parent == g->id_lnext) {
					rbtree_rotate_left(inst, c->id_parent);
					idx = c->id_lnext;
					c = connection_array_at(inst->arr, idx);
					p = connection_array_at(inst->arr, c->id_parent);
					g = connection_array_at(inst->arr, p->id_parent);
				} else if (idx == p->id_lnext && c->id_parent == g->id_rnext) {
					rbtree_rotate_right(inst, c->id_parent);
					idx = c->id_rnext;
					c = connection_array_at(inst->arr, idx);
					p = connection_array_at(inst->arr, c->id_parent);
					g = connection_array_at(inst->arr, p->id_parent);
				}
				// case 5
				p->id_color = 0;
				g->id_color = 1;
				if (idx == p->id_lnext) {
					rbtree_rotate_right(inst, p->id_parent);
				} else {
					rbtree_rotate_left(inst, p->id_parent);
				}
			}
		}
	}
}

static struct connection *
rbtree_get_connection(struct rbtree *inst, int *idx) {
	if (*idx == -1) {
		*idx = connection_array_alloc_co(inst->arr);
		return connection_array_at(inst->arr, *idx);
	} else {
		return connection_array_at(inst->arr, *idx);
	}
}

static bool
rbtree_insert(struct rbtree *inst, int parent, int key, int idx, struct connection **cc) {
	if (parent == -1) {
		// achive c
		struct connection *c = rbtree_get_connection(inst, &idx);
		assert(c != NULL && idx != -1);

		assert(inst->size == 0);
		inst->root = idx;
		inst->size++;

		c->id = key;
		c->id_color = 0;   // black
		c->id_parent = parent;
		c->id_lnext = -1;
		c->id_rnext = -1;

		rbtree_insert_fix(inst, idx);

		*cc = c;
		return true;
	} else {
		assert(parent >= 0 && parent < inst->arr->ccap);
		struct connection *p = connection_array_at(inst->arr, parent);
		if (key < p->id) {  // left
			if (p->id_lnext == -1) {
				struct connection *c = rbtree_get_connection(inst, &idx);
				assert(c != NULL && idx != -1);

				p->id_lnext = idx;
				inst->size++;

				c->id = key;
				c->id_color = 1;  // red
				c->id_parent = parent;
				c->id_lnext = -1;
				c->id_rnext = -1;

				// fix 
				rbtree_insert_fix(inst, idx);

				*cc = c;
				return true;
			} else {
				return rbtree_insert(inst, p->id_lnext, key, idx, cc);
			}
		} else {
			if (p->id_rnext == -1) {
				struct connection *c = rbtree_get_connection(inst, &idx);
				assert(c != NULL && idx != -1);

				p->id_rnext = idx;
				inst->size++;

				c->id = key;
				c->id_color = 1;
				c->id_parent = parent;
				c->id_lnext = -1;
				c->id_rnext = -1;

				// fix 
				rbtree_insert_fix(inst, idx);

				*cc = c;
				return true;
			} else {
				return rbtree_insert(inst, p->id_rnext, key, idx, cc);
			}
		}
	}
}

static int
rbtree_find_min(struct rbtree *inst, int idx) {
	int c_idx = idx;
	struct connection *c = connection_array_at(inst->arr, c_idx);
	while (c->id_lnext >= 0) {
		c_idx = c->id_lnext;
		c = connection_array_at(inst->arr, c_idx);
	}
	return c_idx;
}

static void
rbtree_replace_node_in_parent(struct rbtree *inst, int idx, int nidx) {
	assert(idx >= 0 && idx < inst->arr->ccap);
	struct connection *c = connection_array_at(inst->arr, idx);
	if (c->id_parent >= 0) {
		struct connection *p = connection_array_at(inst->arr, c->id_parent);
		if (p->id_rnext == idx) {
			p->id_rnext = nidx;
		} else {
			p->id_lnext = nidx;
		}
	}
	if (nidx >= 0) {
		struct connection *nc = connection_array_at(inst->arr, nidx);
		nc->id_parent = c->id_parent;
	}

	// c->free = 0;
}

static int
rbtree_sibling(struct rbtree *inst, int idx) {
	struct connection *c = connection_array_at(inst->arr, idx);
	if (c->id_parent >= 0) {
		struct connection *p = connection_array_at(inst->arr, c->id_parent);
		if (p->id_lnext == idx) {
			return p->id_rnext;
		} else {
			return p->id_lnext;
		}
	} else {
		return -1;
	}
}

// idx n
static bool
rbtree_remove_fix(struct rbtree *inst, int idx) {
	assert(idx >= 0 && idx < inst->arr->ccap);
	struct connection *c = connection_array_at(inst->arr, idx);
	if (c->id_parent >= 0) { // case 1
		int s_idx = rbtree_sibling(inst, idx);
		struct connection *s = connection_array_at(inst->arr, s_idx);
		struct connection *p = connection_array_at(inst->arr, c->id_parent);

		struct connection *sl = NULL;
		struct connection *sr = NULL;
		if (s->id_lnext >= 0) {
			sl = connection_array_at(inst->arr, s->id_lnext);
		}
		if (s->id_rnext >= 0) {
			sr = connection_array_at(inst->arr, s->id_rnext);
		}

		if (s->id_color == 1) {  // case 2
			if (idx == p->id_rnext) {
				rbtree_rotate_right(inst, c->id_parent);
			} else {
				rbtree_rotate_left(inst, c->id_parent);
			}
		} else if (p->id_color == 0 && s->id_color == 0 &&  // case 3
			(s->id_lnext == -1 || sl->id_color == 0) &&
			(s->id_rnext == -1 || sr->id_color == 0)) {
			s->id_color = 1; // red
			rbtree_remove_fix(inst, c->id_parent);
		} else if (p->id_color == 1 &&   // case 4
			s->id_color == 0 &&
			(sl->id_color == 0 || s->id_lnext == -1) &&
			(sr->id_color == 0 || s->id_rnext == -1)) {
			s->id_color = 1;
			p->id_color = 0;
		} else if (s->id_color == 0) { // case 5
			if (idx == p->id_lnext &&
				(s->id_lnext == -1 || sl->id_color == 0) &&
				(sr->id_color == 1)) {
				s->id_color = 1;
				sl->id_color = 0;
				rbtree_rotate_right(inst, connection_array_idx(inst->arr, s));
			} else if (idx == p->id_rnext) {
				s->id_color = 1;
				sr->id_color = 0;
				rbtree_rotate_left(inst, connection_array_idx(inst->arr, s));
			}
		} else { // case 6
			s->id_color = p->id_color;
			p->id_color = 0;
			if (idx == p->id_lnext) {
				sr->id_color = 0;
				rbtree_rotate_left(inst, connection_array_idx(inst->arr, p));
			} else {
				sl->id_color = 0;
				rbtree_rotate_right(inst, connection_array_idx(inst->arr, p));
			}
		}
	} else {
		// root
	}
	return true;
}

static bool
rbtree_remove(struct rbtree *inst, int idx, int key, struct connection **cc) {
	if (idx == -1) {
		return false;
	}
	assert(idx >= 0 && idx < inst->arr->ccap);
	struct connection *c = connection_array_at(inst->arr, idx);
	if (key < c->id) {
		rbtree_remove(inst, c->id_lnext, key, cc);
	} else if (key > c->id) {
		rbtree_remove(inst, c->id_rnext, key, cc);
	} else {
		int child = -1;
		struct connection *child_c = NULL;
		if (c->id_lnext >= 0 && c->id_rnext >= 0) {
			int min_idx = rbtree_find_min(inst, c->id_rnext);
			// replace c
			struct connection *n = connection_array_at(inst->arr, min_idx);
			struct connection *np = connection_array_at(inst->arr, n->id_parent);
			np->id_lnext = -1;

			n->id_lnext = c->id_lnext;
			n->id_rnext = c->id_rnext;
			n->id_parent = c->id_parent;

			struct connection *p = connection_array_at(inst->arr, c->id_parent);
			if (p->id_lnext == idx) {
				p->id_lnext = min_idx;
			} else {
				p->id_rnext = min_idx;
			}

			struct connection *l = connection_array_at(inst->arr, n->id_lnext);
			struct connection *r = connection_array_at(inst->arr, n->id_rnext);
			l->id_parent = min_idx;
			r->id_parent = min_idx;

			child = min_idx;
			child_c = n;

		} else if (c->id_lnext >= 0 && c->id_rnext == -1) {
			rbtree_replace_node_in_parent(inst, idx, c->id_lnext);
			child = c->id_lnext;
			child_c = connection_array_at(inst->arr, c->id_lnext);
			// fix
		} else if (c->id_lnext == -1 && c->id_rnext >= 0) {
			rbtree_replace_node_in_parent(inst, idx, c->id_rnext);

			child = c->id_rnext;
			child_c = connection_array_at(inst->arr, c->id_rnext);
		} else {
			assert(c->id_lnext == -1 && c->id_rnext == -1);
			rbtree_replace_node_in_parent(inst, idx, -1);
		}

		// 
		if (c->id_color == 0) {
			if (child_c->id_color == 1) {
				child_c->id_color = 0;  // to be black.
			} else {
				rbtree_remove_fix(inst, child);
			}
		}

		// last
		*cc = c;
		connection_array_free_co(inst->arr, idx);
		return true;
	}
}

static bool
rbtree_search(struct rbtree *inst, int idx, int key, struct connection **cc) {
	if (idx == -1) { // leaf
		*cc = NULL;
		return false;
	}
	assert(idx >= 0 && idx < inst->arr->ccap);
	struct connection *c = connection_array_at(inst->arr, idx);
	if (key < c->id) {
		return rbtree_search(inst, c->id_lnext, key, cc);
	} else if (key == c->id) {
		*cc = c;
		return true;
	} else {
		return rbtree_search(inst, c->id_rnext, key, cc);
	}
}

typedef void(*handler)(struct connection *c);

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


static void
test(void) {
	struct connection_array *arr = connection_array_alloc(16);
	struct rbtree *rbtree = rbtree_alloc(arr);

	for (int i = 0; i < 101; ++i) {
		struct connection *c = NULL;
		assert(rbtree_insert(rbtree, rbtree->root, i, -1, &c));
	}
	rbtree_foreach(rbtree, rbtree->root, print);

	struct connection *c = NULL;
	rbtree_remove(rbtree, rbtree->root, 72, &c);

	printf("%s\n", "abc");
	rbtree_foreach(rbtree, rbtree->root, print);
}

int main(void) {
	test();
	return 0;
}