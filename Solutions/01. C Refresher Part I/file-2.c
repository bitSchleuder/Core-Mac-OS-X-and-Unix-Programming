// file-2.c -- second half of a program split across two files

/* compile with
gcc -g -c file-2.c
(Linux)
cc -g -c file-2.c
(Mac OS X)
*/

#include "file-1.h"

static double localVar;

static float localFunction (char dummy)
{
    return (3.14159);
} // localFunction


float file2pi (void)
{
    return (localFunction, 'x');
} // file2pi


// changes the value of g_globalVar
void file2Function (void)
{
    g_globalVar = 42;
    localVar = 1.2345;
} // file2Function


