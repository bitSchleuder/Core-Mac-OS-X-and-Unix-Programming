// leaveout.c -- use the preprocessor to comment out a chunk of code

/* compile with:
cc -g -Wall -o leaveout leaveout.c
*/

#include <stdio.h>      // for printf()

int main (int argc, char *argv[])
{
#if 0
    printf ("oh happy day\n");
    printf ("bork bork bork\n");
    we_can even have syntax errors in here
    since the compiler will never see this part
#endif

#if 1
    printf ("this is included.  wheee.\n");
#endif

    printf ("that is all folks\n");

    return (0);

} // main
