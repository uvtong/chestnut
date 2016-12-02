#include "service_udpgate.c"

int main(void) {
	struct connection_array *arr = connection_array_alloc(int cap);
	struct rbtree *rbtree = rbtree_alloc(arr);

	for (int i = 0; i < 101; ++i) {
		struct connection *c = NULL;
		assert(rbtree_insert_id(rbtree, rbtree->root, i, &c));
	}

	return 0;
}