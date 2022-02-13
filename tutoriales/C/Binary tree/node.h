typedef struct _node Node;

Node *node_init(int data);
void node_destroy(Node *n);
void node_add(Node *n, int data);