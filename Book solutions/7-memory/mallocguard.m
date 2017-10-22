// mallocguard.m -- exercise MallocGuardEdges.

/* compile with:
cc -g -Wall -o mallocguard mallocguard.m
*/

#import <stdlib.h>

int main (int argc, char *argv[])
{
    unsigned char *memory = malloc (1024 * 16);
    unsigned char *dummy = malloc (1024 * 16);

    unsigned char *offTheEnd = memory + (1024 * 16) + 1;

    *offTheEnd = 'x';

    return (0);

} // main
