#include <stdlib.h>
#include <stdio.h>
#include <errno.h>

typedef struct Node Node;
typedef struct Linked_list Linked_list;



Linked_list *linked_list_init();
Node *linked_list_last(Linked_list *l);
int linked_list_add_node(Linked_list *l, int data);
void linked_list_destroy(Linked_list *l);
void linked_list_print(Linked_list *l);