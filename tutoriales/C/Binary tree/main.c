#include <stdio.h>
#include <stdlib.h>
#include "tree.h"

int main() {
    Tree *t = tree_init();

    tree_add_node(t, 5);
    tree_add_node(t, 4);
    tree_add_node(t, 6);
    tree_add_node(t, 3);
    tree_add_node(t, 7);
    tree_add_node(t, 2);
    tree_add_node(t, 8);
    tree_add_node(t, 1);
    tree_add_node(t, 9);
    tree_add_node(t, 0);
    tree_add_node(t, 10);
    tree_add_node(t, 1451650);
    tree_add_node(t, 14240);
    tree_add_node(t, 104242);
    tree_add_node(t, 1772770);
    tree_add_node(t, 124240);
    tree_add_node(t, 1742170);
    tree_add_node(t, 14470);
    tree_add_node(t, 14275270);
    tree_destroy(t);

    return 0;
}