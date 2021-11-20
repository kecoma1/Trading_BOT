#include <fcntl.h>
#include <mqueue.h>
#include <sys/stat.h>

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
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

    mqd_t queue = mq_open(MQ_NAME, O_CREAT | O_WRONLY, S_IRUSR | S_IWUSR, &attributes);

    Mensaje struct_to_send;
    strcpy(struct_to_send.msg, "Este es el mensaje que voy a enviar");

    mq_send(queue, (char *)&struct_to_send, sizeof(struct_to_send), 1);

    /* Wait for input to end the program */
    fprintf(stdout, "Press any key to finish\n");
    getchar();

    mq_close(queue);
    mq_unlink(MQ_NAME);

    return EXIT_SUCCESS;
}