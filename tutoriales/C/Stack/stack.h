#include <stdlib.h>
#include <stdio.h>

typedef struct _stack Stack;

Stack *stack_ini();
void push(Stack *s, int value);
int pop(Stack *s);
void stack_destroy(Stack *s);
void stack_print(Stack *s);
