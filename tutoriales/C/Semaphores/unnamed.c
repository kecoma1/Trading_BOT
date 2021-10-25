/* FOR SEMAPHORE */
#include <semaphore.h>

/* SHARED MEMORY */
#include <sys/mman.h>
#include <sys/stat.h>        /* For mode constants */
#include <fcntl.h>           /* For O_* constants */

#include <stdlib.h>
#include <stdio.h>

/* FOR FORK */
#include <sys/types.h>
#include <unistd.h>

/* FOR KILLING THE CHILD PROCESS */
#include <sys/wait.h>

#define SHM_SEMS "sems_shared_memory"

typedef struct {
    sem_t sem1;
    sem_t sem2;
} Sems;

void main() {
    
    /* Opening the shared memory */
    int fd_shm = shm_open(SHM_SEMS, O_RDWR | O_CREAT | O_EXCL,  S_IRUSR | S_IWUSR);

    ftruncate(fd_shm, sizeof(Sems));

    Sems *sems = mmap(NULL, sizeof(Sems), PROT_READ | PROT_WRITE, MAP_SHARED, fd_shm, 0);

    //                    1 to share between processes    Initial value of the sem
    sem_init(&sems->sem1,                            1,                          0);
    sem_init(&sems->sem2,                            1,                          0);

    if (fork() == 0) { // child
        printf("1\n");
        sem_post(&sems->sem1);
        sem_wait(&sems->sem2);
        printf("3\n");
        sem_post(&sems->sem1);

        /* Unmapping the sems */
        munmap(sems, sizeof(Sems));

    } else { // father
        sem_wait(&sems->sem1);
        printf("2\n");
        sem_post(&sems->sem2);
        sem_wait(&sems->sem1);
        printf("4\n");

        wait(NULL);

        /* Only the father destroys the sems */
        sem_destroy(&sems->sem1);
        sem_destroy(&sems->sem2);

        /* Unmapping the sems */
        munmap(sems, sizeof(Sems));

        /* Destroying the shared memory (only the father) */
        shm_unlink(SHM_SEMS);
    }
}