#include <stdio.h>
#include <stdlib.h>

int main() {

    FILE *fp = NULL;
    fp = fopen("nuevo_archivo.txt", "w");

    fprintf(fp, "Hola este es un test %d\n", 3);

    fclose(fp);

    return 0;
}