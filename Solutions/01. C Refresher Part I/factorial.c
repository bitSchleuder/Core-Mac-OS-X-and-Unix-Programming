// factorial.c -- calculate factorials recursively

/* compile with
gcc -g -o factorial factorial.c
(Linux)
cc -g -o factorial factorial.c
(Mac OS X)
*/

#include <stdio.h>	// for printf



long long factorial (long long value)
{
    if (value == 1) {
	return (1);
    } else {
	return (value * factorial (value - 1));
    }
} // factorial


int main (int argc, char *argv[])
{
    printf ("factorial of 16 is %lld\n", factorial(16));
} // main


