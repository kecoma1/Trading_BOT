#include "tree.h"

int main() {
	Tree *t = tree_init();

	tree_add_node(t, 1);
	tree_add_node(t, 2);
	tree_add_node(t, 3);
	tree_add_node(t, 4);
	tree_add_node(t, 5);
	tree_add_node(t, 6);
	tree_add_node(t, 7);
	tree_add_node(t, 8);
	tree_add_node(t, 9);
	tree_add_node(t, 10);

	tree_destroy(t);

	return 0;
}