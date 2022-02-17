#include "queue.h"


struct _queue {
	int *items;
	short num_items;
};


Queue *queue_ini() {
	Queue *q = NULL;

	q = (Queue *)malloc(sizeof(Queue));
	if (q == NULL) return NULL;

	q->items = NULL;
	q->num_items = 0;
}

void push(Queue *q, int value) {
	q->items = realloc(q->items, (q->num_items+1)*sizeof(int));
	if (q == NULL) return;

	q->items[q->num_items] = value;

	q->num_items++;
}

int pop(Queue *q) {
	if (q->num_items == 0) return -1;

	int first = q->items[0];

	if (q->num_items-1 > 0) {
		for(int i = 0; i+1 < q->num_items; i++)
			q->items[i] = q->items[i+1];

		q->items = realloc(q->items, (q->num_items-1)*sizeof(int));
		if (q == NULL) return -1;

	} else {
		free(q->items);
		q->items = NULL;
	}

	q->num_items--;

	return first;
}

void queue_destroy(Queue *q) {
	if (q->items != NULL) free(q->items);
	free(q);
}

void queue_print(Queue *q) {
	for (int i = 0; i < q->num_items; i++)
		printf("%d ", q->items[i]);
	printf("\n");
}