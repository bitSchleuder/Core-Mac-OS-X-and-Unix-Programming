// mallocguard.m -- exercise MallocGuardEdges.
// run this, then run after doing a 'setenv MallocGuardEdges 1' in the shell

/* compile with
cc -o mallocguard mallocguard.m
 */

#import <stdlib.h>

int main (int argc, char *argv[])
{
    unsigned char *memory = malloc (1024 * 16);
    unsigned char *dummy = malloc (1024 * 16);
    unsigned char *offTheEnd = memory + (1024 * 16) + 1;

    *offTheEnd = 'x';

    exit (0);

} // main


