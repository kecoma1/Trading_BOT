#include "queue.h"

int main() {
    Queue *q = queue_ini();

    push(q, 1);
    queue_print(q);
    push(q, 2);
    queue_print(q);
    push(q, 3);
    queue_print(q);
    push(q, 4);
    queue_print(q);

    printf("\nPOP %d - ", pop(q));
    queue_print(q);
    printf("POP %d - ", pop(q));
    queue_print(q);
    printf("POP %d - ", pop(q));
    queue_print(q);
    printf("POP %d - ", pop(q));
    queue_print(q);
    printf("\n");

    push(q, 10);
    queue_print(q);
    push(q, 20);
    queue_print(q);
    push(q, 30);
    queue_print(q);
    push(q, 40);
    queue_print(q);

    printf("\nPOP %d - ", pop(q));
    queue_print(q);
    printf("POP %d - ", pop(q));
    queue_print(q);
    printf("POP %d - ", pop(q));
    queue_print(q);
    printf("POP %d - ", pop(q));
    queue_print(q);
    printf("\n");

    queue_destroy(q);

    return 0;
}