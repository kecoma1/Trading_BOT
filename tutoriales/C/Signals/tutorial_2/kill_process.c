#include <stdio.h>
#include <stdlib.h>

#include <signal.h>
#include <sys/types.h>

void main() {
    int pid = 0;

    printf("Introduce the PID: ");
    scanf("%d", &pid);

    kill(pid, SIGTERM);
}