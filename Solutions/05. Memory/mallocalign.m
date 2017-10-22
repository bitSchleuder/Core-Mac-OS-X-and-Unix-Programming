// mallocalign.m -- see how malloc aligns its pointers

/* compile with
   cc -o mallocalign mallocalign.m
*/
#import <stdlib.h>

void allocprint (size_t size)
{
    void *memory;

    memory = malloc (size);
    printf ("malloc(%d) == %p\n", size, memory);
    // intentionally don't free so we get a new malloced block of memory
} // allocprint

int main (int argc, char *argv[])
{
    allocprint (1);
    allocprint (2);
    allocprint (sizeof(double));
    allocprint (1024 * 1024);
    allocprint (1);
    allocprint (1);
} // main

