#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>

int main() {
    if (fork() == 0) { // Child's execution
        printf("I'm the child\n");
    } else { // Father's execution
        printf("I'm the father\n");
        wait(NULL);
    }
    return 0;
}