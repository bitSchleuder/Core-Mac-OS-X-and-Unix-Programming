// macros.c -- look at C Preprocessor macros

/* compile with
gcc -g -o macros macros.c      (Linux)
cc -g -o macros macros.c       (Mac OS X)
*/

#include <stdio.h>	// for printf


// make some symbolic constants
#define PI		3.14159
#define Version		"beta5"

// make some macros
#define SQUARE(x)		x * x
#define AreaOfACircle(r)	(PI * SQUARE(r))


int main (int argc, char *argv[])
{
    printf ("Welcome to version %s of macros\n", Version);
    printf ("The area of a circle with radius 5 is %f\n",
	    AreaOfACircle(5));
} // main


