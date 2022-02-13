#include "stack.h"


struct _stack {
	int *items;
	short num_items;
};


Stack *stack_ini() {

	Stack *s = NULL;

	s = (Stack *)malloc(sizeof(Stack));
	if (s == NULL) return NULL;

	s->items = NULL;
	s->num_items = 0;
}

void push(Stack *s, int value) {

	s->items = (int *)realloc(s->items, (s->num_items+1)*sizeof(int));
	if (s == NULL) return;

	s->items[s->num_items] = value;

	s->num_items++;
}

int pop(Stack *s) {

	if (s->num_items == 0) return -1;

	int last = s->items[s->num_items-1];

	if (s->num_items - 1 > 0) {
		s->items = (int *)realloc(s->items, (s->num_items - 1)*sizeof(int));
		if (s->items == NULL) return -1;
	} else {
		free(s->items);
		s->items = NULL;
	}

	s->num_items--;

	return last;
}

void stack_destroy(Stack *s) {
	if (s->items != NULL) free(s->items);
	free(s);
}

void stack_print(Stack *s) {
	for (int i = 0; i < s->num_items; i++) 
		printf("%d ", s->items[i]);
	printf("\n");
}