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

/* FOR WAITING THE CHILD PROCESS */
#include <sys/wait.h>

/* for srand */
#include <time.h>


#define SHM_SEMS "sems_shared_memory3"
#define NUM_KIDS 10


typedef struct {
    sem_t mutex;
    short available_pieces;
} Shared_Variables;

void call_mum_for_cakes(Shared_Variables *sh) {
    sleep((rand() % 5) + 2);

    sh->available_pieces = 3;
    printf("I'm mum, and I have brought a new cake\n");
}

void main() {

    srand(time(NULL));
    
    /* Opening the shared memory */
    int fd_shm = shm_open(SHM_SEMS, O_RDWR | O_CREAT | O_EXCL,  S_IRUSR | S_IWUSR);

    ftruncate(fd_shm, sizeof(Shared_Variables));

    Shared_Variables *sh = mmap(NULL, sizeof(Shared_Variables), PROT_READ | PROT_WRITE, MAP_SHARED, fd_shm, 0);

    // Initializing values
    //                    1 to share between processes    Initial value of the sem
    sem_init(&sh->mutex,                            1,                          1);
    sh->available_pieces = 3;

    for(int i = 0; i < NUM_KIDS; i++) {
        if (fork() == 0) { // Child
            sleep((rand() % 9) + 1);
            printf("Kid %d entered\n", i+1);
            for (int n = 0; n < (rand() % 4) + 1; n++) {


                sem_wait(&sh->mutex);

                if (sh->available_pieces <= 0)
                    call_mum_for_cakes(sh);

                sh->available_pieces -= 1;

                printf("I'm the kid %d and I'm taking my peace of cake. There are %d left\n", i+1, sh->available_pieces);
                sleep((rand() % 4) + 1);

                sem_post(&sh->mutex);

                printf("I'm the kid %d and I'm eating\n", i+1);
                sleep((rand() % 3) + 3);

            }

            munmap(sh, sizeof(Shared_Variables));
            return;
        }
    }

    /* Waiting for the children */
    for (int i = 0; i < NUM_KIDS; i++) 
        while (wait(NULL) == -1);

    munmap(sh, sizeof(Shared_Variables));
    shm_unlink(SHM_SEMS);
}