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

	printf("\n");

	printf("POP %d - ", pop(q));
	queue_print(q);
	printf("POP %d - ", pop(q));
	queue_print(q);
	printf("POP %d - ", pop(q));
	queue_print(q);
	printf("POP %d - ", pop(q));
	queue_print(q);

	printf("\n");

	push(q, 112);
	queue_print(q);
	push(q, 22);
	queue_print(q);
	push(q, 345131);
	queue_print(q);
	push(q, 13141);
	queue_print(q);

	printf("\n");

	printf("POP %d - ", pop(q));
	queue_print(q);

	queue_destroy(q);

	return 0;
}