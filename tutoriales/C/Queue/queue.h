#include <stdlib.h>
#include <stdio.h>


typedef struct _queue Queue;


Queue *queue_ini();
void push(Queue *q, int value);
int pop(Queue *q);
void queue_destroy(Queue *q);
void queue_print(Queue *q);