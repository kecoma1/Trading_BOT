#include "tree.h"
#include <stdlib.h>
#include <stdio.h>

struct _tree {
	Node *root;
};

Tree *tree_init() {
	Tree *t = NULL;

	t = (Tree *)malloc(sizeof(Tree));
	if (t == NULL) {
		fprintf(stderr, "Error en la función tree_init\n");
		return NULL;
	}

	t->root = NULL;

	return t;
}

void tree_destroy(Tree *t) {
	if (t == NULL) return;

	node_destroy(t->root);
	free(t);
}

void tree_add_node(Tree *t, int node_data) {

	if (t == NULL) return;

	if (t->root == NULL)
		t->root = node_init(node_data);
	else
		node_add(t->root, node_data);
}