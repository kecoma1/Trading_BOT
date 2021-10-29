#include <stdio.h>
#include <unistd.h>

void main() {
    while(1) printf("%d Infinite LOOP\n", getpid());
}