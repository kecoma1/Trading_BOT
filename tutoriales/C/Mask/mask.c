#include <stdio.h> 
#include <stdlib.h> 

/* For masks */
#include <signal.h>

/* For getpid */
#include <sys/types.h>
#include <unistd.h>


void main () {
    sigset_t mask, suspendmask;

    sigfillset(&mask);
    sigdelset(&mask, SIGINT);

    sigfillset(&suspendmask);
    sigdelset(&suspendmask, SIGUSR1);

    sigprocmask(SIG_BLOCK, &mask, NULL);

    printf("PID: %d\n", getpid());

    sigsuspend(&suspendmask);
}