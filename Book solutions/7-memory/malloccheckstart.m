// malloccheckstart.m -- play with MallocCheckHeapStart

/* compile wth:
cc -g -Wall -o malloccheckstart malloccheckstart.m
*/

#import <stdlib.h>   // for malloc()
#import <string.h>   // for memset()

int main (int argc, char *argv[])
{
    int i;
    unsigned char *memory;

    for (i = 0; i < 10000; i++) {
        memory = malloc (10);

        if (i == 3783) {
            // smash some memory
            memset (memory-16, 0x55, 26);
        }
    }
    return (0);
} // main
