#include "node.h"

typedef struct _tree Tree;

Tree *tree_init();
void tree_destroy(Tree *t);
void tree_add_node(Tree *t, int node_data);