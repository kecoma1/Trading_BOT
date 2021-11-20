#include <fcntl.h>
#include <mqueue.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>

#define MQ_NAME "/mq_cola_queue"

typedef struct {
    char msg[80];
} Mensaje;

int main(void) {
    struct mq_attr attributes = {
        .mq_flags = 0,
        .mq_maxmsg = 10,
        .mq_curmsgs = 0,
        .mq_msgsize = sizeof(Mensaje)
    };

    mqd_t queue = mq_open(MQ_NAME,
        O_CREAT | O_RDONLY | O_NONBLOCK,
        S_IRUSR | S_IWUSR,
        &attributes);

    if(queue == (mqd_t)-1) {
        fprintf(stderr, "Error opening the queue\n");
        return EXIT_FAILURE;
    }

    Mensaje msg;

    mq_receive(queue, (char *)&msg, sizeof(msg), NULL);

    printf("%s\n", msg.msg);

    /* Wait for input to end the program */
    fprintf(stdout, "Press any key to finish\n");
    getchar();

    mq_close(queue);

    return EXIT_SUCCESS;
}