// mallocsize.m -- see what kind of block sizes malloc is actually giving us

/* compile with
   cc -g -o mallocsize mallocsize.m
*/

#import <stdlib.h>

void allocprint (size_t size)
{
    void *memory;

    memory = malloc (size);
    printf ("malloc(%d) has a block size of %d\n",
	    size, malloc_size(memory));

} // allocprint

int main (int argc, char *argv[])
{
    allocprint (1);
    allocprint (sizeof(double));
    allocprint (14);
    allocprint (16);
    allocprint (32);
    allocprint (48);
    allocprint (64);
    allocprint (100);
    exit (0);
} // main
