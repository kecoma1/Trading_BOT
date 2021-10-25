#include <stdio.h>
#include <stdlib.h>

#include <signal.h>

#include <unistd.h>

void handler(int sig) {
    printf("I'm in the handler!\n");
}

int main(void) {
    struct sigaction act;

    /* Setting the handler */
    act.sa_handler = handler;

    /* The mask of the handler is empty */
    sigemptyset(&(act.sa_mask));
    act.sa_flags = 0;

    /* Now the handler is linked to the process */
    sigaction(SIGINT, &act, NULL);

    while(1) {
        printf("Waiting for SIGINT (PID = %d)\n", getpid());
        sleep(1);
    }
}