#include "node.h"
#include <stdlib.h>
#include <stdio.h>

struct _node {
	int data;
	Node *left;
	Node *right;
};

Node *node_init(int data) {
	Node *n = NULL;

	n = (Node *)malloc(sizeof(Node));
	if (n == NULL) {
		fprintf(stderr, "Error en la función node_init\n");
		return NULL;
	}

	n->data = data;
	n->left = NULL;
	n->right = NULL;

	return n;
}

void node_destroy(Node *n) {
	if (n == NULL) return;

	node_destroy(n->left);
	node_destroy(n->right);

	free(n);
}

void node_add(Node *n, int data) {

	if (n == NULL) return;

	if (data > n->data) {
		if (n->right == NULL) n->right = node_init(data);
		else node_add(n->right, data);
	} else if (data <= n->data) {
		if (n->left == NULL) n->left = node_init(data);
		else node_add(n->left, data);
	}
}