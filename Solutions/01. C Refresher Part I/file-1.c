// file-1.c -- half of a program split across two files

/* compile with
gcc -g -c file-1.c
(Linux)
cc -g -c file-1.c
(Mac OS X)
*/

/* link with
gcc -o multifile file-1.o file-2.o
(Linux)
cc -o multifile file-1.o file-2.o 
(Mac OS X)
*/


// see the stuff file-2 is exporting
#include "file-1.h"


static int localVar;

int g_globalVar;


static void localFunction ()
{
    printf ("this is file 1's local function. ");
    printf ("No arguments passed.  localVar is %d\n", localVar);

} // localFunction


int main (int argc, char *argv[])
{
    float pi;

    localFunction ();
    pi = file2pi ();

    localVar = 23;
    g_globalVar = 23;
    
    printf ("g_globalVar before is %d\n", g_globalVar);
    printf ("localVar before is %d\n", localVar);

    file2Function ();

    printf ("g_globalVar was changed to %d\n", g_globalVar);
    printf ("localVar after is still %d\n", localVar);

} // main
