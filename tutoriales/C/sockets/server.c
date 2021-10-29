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
    int server_descriptor = 0, client_descriptor = 0; 

    struct sockaddr_in address; 
    address.sin_family = AF_INET; // SOCKET IS FOR IPv4
    address.sin_addr.s_addr = INADDR_ANY;
    address.sin_port = htons( 5001 ); // CREDITS FOR RODRI!! HE FOUND THIS FUNCTION

    printf("I'm the server, my address is: %d\n", address.sin_addr.s_addr);

    /* Creating one TCP socket, IPv4    TCP  */
    server_descriptor = socket(AF_INET, SOCK_STREAM, 0);

    /* Binding a name to a socket */
    bind(server_descriptor, (struct sockaddr *)&address, sizeof(address));

    /* Listening for connections on the socket */
    listen(server_descriptor, 5);

    /* SOCKET SET FINISHED */
    /* ACCEPTING CONNECTIONs */
    printf("I'm the server and I'm ready to receive connections :-)\n");
    printf("I'm going to wait for a connection\n");

    client_descriptor = accept(server_descriptor, NULL, NULL);

    printf("Someone connected, I'm looking for a message\n");

    char msg[100] = "";

    read(client_descriptor, msg, 100);
    printf("This is what I received: %s\n", msg);

    close(server_descriptor);
}