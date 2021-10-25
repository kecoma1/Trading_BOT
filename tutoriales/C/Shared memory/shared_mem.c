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
    int shared_var;
    sem_t sem1;
    sem_t semaphore2;
} Sems;

void main() {
    
    /* Opening the shared memory */
    int fd_shm = shm_open(SHM_SEMS, O_RDWR | O_CREAT | O_EXCL,  S_IRUSR | S_IWUSR);

    ftruncate(fd_shm, sizeof(Sems));

    Sems *sems = mmap(NULL, sizeof(Sems), PROT_READ | PROT_WRITE, MAP_SHARED, fd_shm, 0);


    //                    1 to share between processes    Initial value of the sem
    sem_init(&sems->sem1,                            1,                          0);
    sem_init(&sems->semaphore2,                            1,                          0);

    for (int i = 0; i < 190; i++)

    if (fork() == 0) { // child
        printf("CHILD: %d\n", sems->shared_var);
        printf("CHILD: I'm going to change the value to 1\n");
        sems->shared_var = 1;
        sems->shared_var = 0;
        printf("CHILD: %d\n", sems->shared_var);
        sem_post(&sems->sem1);

        

        /* Unmapping the sems */
        munmap(sems, sizeof(Sems));

    } else { // father
        printf("FATHER: %d\n", sems->shared_var);
        sem_wait(&sems->sem1);
        printf("FATHER: %d\n", sems->shared_var);

        wait(NULL);

        /* Only the father destroys the sems */
        sem_destroy(&sems->sem1);
        sem_destroy(&sems->semaphore2);

        /* Unmapping the sems */
        munmap(sems, sizeof(Sems));

        /* Destroying the shared memory (only the father) */
        shm_unlink(SHM_SEMS);
    }

}