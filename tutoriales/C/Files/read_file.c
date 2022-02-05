#include <stdio.h>
#include <stdlib.h>

int main() {

    FILE *fp = NULL;
    fp = fopen("ejemplo.txt", "r");

    for (int i = 0; i < 4; i++) {
        char str[10];
        fscanf(fp, "%s\n", str);
        printf("%s\n", str);
    }

    fclose(fp);

    return 0;
}