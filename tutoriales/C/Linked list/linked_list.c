#include "linked_list.h"

struct Node{
    int data;
    Node *next;
};

struct Linked_list {
    Node *root_node;
    int num_nodes;
};

/* Private */

Node *node_init(int data) {
    Node *n = NULL;

    n = (Node*)malloc(sizeof(Node));
    if (n == NULL) {
        perror("Error in malloc:");
        return NULL;
    }
    n->data = data;
    return n;
}

void node_destroy(Node *n) {
    if (n == NULL) return;

    free(n);
}

/* Public */

Linked_list *linked_list_init() {
    Linked_list *l = NULL;

    l = (Linked_list*)malloc(sizeof(Linked_list));
    if (l == NULL) {
        perror("Error in linked_list_init when creating the linked list. malloc:");
        return NULL;
    }

    l->num_nodes = 0;
    return l;
}

Node *linked_list_last(Linked_list *l) {
    if (l == NULL) {
        fprintf(stderr, "Invalid argument in linked_list_last.\n");
        return NULL;
    }

    Node *n = l->root_node;
    if (n == NULL) {
        fprintf(stderr, "List without nodes in linked_list_last.\n");
        return NULL;
    }

    while (n->next != NULL) {
        n = n->next;
    }

    return n;
}

int linked_list_add_node(Linked_list *l, int data) {
    if (data < 0 || l == NULL) {
        fprintf(stderr, "Invalid argument in linked_list_add_node.\n");
        return -1;
    }
    
    Node *n = node_init(data);
    if (n == NULL) {
        fprintf(stderr, "Error in add_node when calling node_init.\n");
        return -1;
    }

    if (l->root_node == NULL) l->root_node = n;
    else {
        Node *last_n = linked_list_last(l);
        if (last_n == NULL) {
            fprintf(stderr, "Error in add_node when calling linked_list_last in linked_list_add_node.\n");
            return -1;
        }

        last_n->next = n;
    }

    l->num_nodes += 1;
    return 0;
}

void linked_list_destroy(Linked_list *l) {
    if (l == NULL) return;

    Node *n = l->root_node;
    while (n != NULL) {
        Node *to_destroy = n;
        n = n->next;
        node_destroy(to_destroy);
    }
    free(l);
}

void linked_list_print(Linked_list *l) {
    if (l == NULL) return;

    printf("Linked list, number of nodes: %d\n", l->num_nodes);
    Node *n = l->root_node;
    while (n != NULL) {
        printf("Node - data: %d -> ", n->data);
        n = n->next;
    }
    printf("\n");
}

