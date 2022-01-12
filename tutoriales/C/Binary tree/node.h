typedef struct _node Node;

Node *node_init();
void node_destroy(Node *n);
void node_add(Node *n, int data);