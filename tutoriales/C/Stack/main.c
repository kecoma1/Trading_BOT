#include "stack.h"

int main() {
    Stack *s = stack_ini();

    push(s, 1);
    stack_print(s);
    push(s, 2);
    stack_print(s);
    push(s, 3);
    stack_print(s);
    push(s, 4);
    stack_print(s);

    printf("\nPOP %d - ", pop(s));
    stack_print(s);
    printf("POP %d - ", pop(s));
    stack_print(s);
    printf("POP %d - ", pop(s));
    stack_print(s);
    printf("POP %d - ", pop(s));
    stack_print(s);
    printf("\n");

    push(s, 10);
    stack_print(s);
    push(s, 20);
    stack_print(s);
    push(s, 30);
    stack_print(s);
    push(s, 40);
    stack_print(s);

    printf("\nPOP %d - ", pop(s));
    stack_print(s);
    printf("POP %d - ", pop(s));
    stack_print(s);
    printf("POP %d - ", pop(s));
    stack_print(s);
    printf("POP %d - ", pop(s));
    stack_print(s);
    printf("\n");

    stack_destroy(s);

    return 0;
}