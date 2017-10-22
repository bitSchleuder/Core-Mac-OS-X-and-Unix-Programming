// first.c -- a simple first C program

/* compile with
gcc -g -o first first.c -lm 
(Linux)
cc -g -o first first.c
(Mac OS X)
*/

#include <stdio.h>      // for printf
#include <math.h>       // for cos

int main (int argc, char *argv[])
{
    printf ("the cosine of 1 is %g\n", cos(1.0));
    printf ("thank you, and have a nice day\n");
} // main

