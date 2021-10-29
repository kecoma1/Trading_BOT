/* SOCKETS */
#include <sys/types.h>
#include <sys/socket.h>

/* Descriptor functions (read and close) */
#include <unistd.h>

/* Classic tyvole */
#include <stdio.h>
#include <stdlib.h>

/* For htons */
#include <arpa/inet.h> // man inet

void main() {
    int client_descriptor = 0;

    struct sockaddr_in address; 
    address.sin_family = AF_INET;
    address.sin_addr.s_addr = INADDR_ANY;
    address.sin_port = htons( 5001 );

    /* Creating the client's socket IPv4  TCP */
    client_descriptor = socket(AF_INET, SOCK_STREAM, 0);

    /* Connecting to the server */
    connect(client_descriptor, (struct sockaddr *)&address,sizeof (address));
    printf("Connected to the server\n");

    char msg[100] = "";

    printf("Write something to send to the server: ");
    scanf("%s", msg);

    printf("Sending the message to the server\n");
    write(client_descriptor, msg, 100);

    close(client_descriptor);
}