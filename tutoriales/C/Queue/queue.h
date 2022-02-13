#include <stdlib.h>
#include <stdio.h>

typedef struct _queue Queue;

// FIFO

Queue *queue_ini();
void push(Queue *s, int value);
int pop(Queue *s);
void queue_destroy(Queue *s);
void queue_print(Queue *s);
