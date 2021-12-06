#include "linked_list.h"

int main() {

    Linked_list *l = linked_list_init();
    if (l == NULL) {
        fprintf(stderr, "Error creating the linked list.\n");
        return -1;
    }

    if (linked_list_add_node(l, 1) == -1) {
        fprintf(stderr, "Error adding a node.\n");
        linked_list_destroy(l);
        return -1;
    }
    if (linked_list_add_node(l, 2589) == -1) {
        fprintf(stderr, "Error adding a node.\n");
        linked_list_destroy(l);
        return -1;
    }
    if (linked_list_add_node(l, 3) == -1) {
        fprintf(stderr, "Error adding a node.\n");
        linked_list_destroy(l);
        return -1;
    }
    if (linked_list_add_node(l, 348) == -1) {
        fprintf(stderr, "Error adding a node.\n");
        linked_list_destroy(l);
        return -1;
    }
    
    if (linked_list_add_node(l, 30) == -1) {
        fprintf(stderr, "Error adding a node.\n");
        linked_list_destroy(l);
        return -1;
    }
    if (linked_list_add_node(l, 18) == -1) {
        fprintf(stderr, "Error adding a node.\n");
        linked_list_destroy(l);
        return -1;
    }

    linked_list_print(l);
    linked_list_destroy(l);
}