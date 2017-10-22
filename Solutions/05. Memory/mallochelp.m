#import <stdlib.h>

/* compile with
cc -o mallochelp mallochelp.m
 */

int main (int argc, char *argv[])
{
    char *blah = malloc (1024 * 16);
    printf ("my process ID is %d\n", getpid());
    sleep (30);
    exit (0);
} // main

