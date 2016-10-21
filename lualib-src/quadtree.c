#include "quadtree.h"
#include "math3d.h"
#include <stdio.h>

struct rect {
	struct vector3 min;
	struct vector3 max;
};

struct obj {
	struct vector3   pos;
	struct quadnode *qn;
	void *           ud;
};

struct listnode {
	struct listnode *prio;
	struct listnode *next;
	struct obj      *obj;
};

struct quadnode {
	struct rect box;
	struct quadnode *parent;
	struct quadnode *children[4];
	bool             leaf;
	struct listnode *head;
};

struct quadtree {
	struct quadnode *root;
	int depth;
	struct map map;
};

static void 
create_node(struct quadnode *parent, int depth) {
	if (depth <= 0) {
		return;
	} else {
		depth--;
		if (depth == 1) {

		}
		struct quadnode *tr = (struct quadnode *)malloc(sizeof(*node));
		tr->parent = parent;
		parent->children[0] = tr;
		create_node(tr, depth)
		struct quadnode *tl = (struct quadnode *)malloc(sizeof(*node));
		tl->parent = parent;
		parent->children[1] = tl;
		create_node(tl, depth);
		struct quadnode *br = (struct quadnode *)malloc(sizeof(*node));
		br->parent = parent;
		parent->children[2] = br;
		create_node(br, depth);
		struct quadnode *bl = (struct quadnode *)malloc(sizeof(*node));	
		bl->parent = parent;
		parent->children[3] = bl;
	}
}

struct quadtree *
quadtree_new(struct rect rt, int depth) {
	struct quadtree * tree = (struct quadtree *)malloc(size(*tree));
	struct quadnode *root = (struct quadnode *)malloc(sizeof(*root));	
	root->rect = rt;
	tree->root = root;
	tree->depth = 3;
	create_node(root, 2);
	return tree;
} 

void
quadtree_release(struct quadtree *tree) {

}

static quadnode * query(struct quadtree *node, struct obj *obj) {
	if (node->leaf) {
		node->rect.min.x < obj->pos.x;
	}
}

void 
quadtree_insert(struct quadtree *tree, struct obj *obj) {
	// map
	struct quadnode *root = tree->root;
}
