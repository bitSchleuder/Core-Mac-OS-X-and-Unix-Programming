// conditional.c -- look at conditional compilation

/* compile with
gcc -g -o conditional conditional.c
(Linux)
cc -g -o conditional conditional.c
(Mac OS X)
*/

#include <stdio.h>	// for printf

int main (int argc, char *argv[])
{
#define THING1

#ifdef THING1
    printf ("thing1 defined\n");
#else
    printf ("thing1 is not defined\n");
#endif

#ifdef THING2
    printf ("thing2 is defined\n");
#else
    printf ("thing2 is not defined\n");
#endif

} // main

