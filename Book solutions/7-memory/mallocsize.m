// mallocsize.m -- see what kind of block sizes malloc is 
//                 actually giving us

/* compile with:
cc -g -Wall -o mallocsize mallocsize.m
*/

#import <stdlib.h>      // for malloc()
#import <stdio.h>       // for printf()
#import <objc/malloc.h> // for malloc_size()

void allocprint (size_t size)
{
    void *memory;

    memory = malloc (size);
    printf ("malloc(%d) has a block size of %d\n",
            (int)size, (int)malloc_size(memory));

} // allocprint

int main (int argc, char *argv[])
{
    allocprint (1);
    allocprint (sizeof(double)); // 8 bytes
    allocprint (14);
    allocprint (16);
    allocprint (32);
    allocprint (48);
    allocprint (64);
    allocprint (100);
    return (0);
} // main
