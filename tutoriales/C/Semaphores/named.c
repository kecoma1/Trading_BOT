/* FOR SEMAPHORE */
#include <semaphore.h>
#include <fcntl.h>           /* For O_* constants */
#include <sys/stat.h>        /* For mode constants */

#include <stdlib.h>
#include <stdio.h>

/* FOR FORK */
#include <sys/types.h>
#include <unistd.h>

/* FOR KILLING THE CHILD PROCESS */
#include <sys/wait.h>

#define SEM_NAME_1 "/sem_1"
#define SEM_NAME_2 "/sem_2"

void main() {
    sem_t *sem1 = NULL, *sem2 = NULL;

    /* If O_CREAT and O_EXCL are here then if the semaphore exists it will give us an error */
    sem1 = sem_open(SEM_NAME_1, O_CREAT | O_EXCL, S_IRUSR | S_IWUSR, 0);
    sem2 = sem_open(SEM_NAME_2, O_CREAT | O_EXCL, S_IRUSR | S_IWUSR, 0);

    if (fork() == 0) { // child
        printf("1\n");
        sem_post(sem1);
        sem_wait(sem2);
        printf("3\n");
        sem_post(sem1);

        /* Every process closes the sems */
        sem_close(sem1);
        sem_close(sem2);
    } else { // father
        sem_wait(sem1);
        printf("2\n");
        sem_post(sem2);
        sem_wait(sem1);
        printf("4\n");

        wait(NULL);

        /* Every process closes the sems */
        sem_close(sem1);
        sem_close(sem2);
    
        /* Only the father 'destroys' the sems */
        sem_unlink(SEM_NAME_1);
        sem_unlink(SEM_NAME_2);
    }

}