// file-2.c -- second half of a program split across two files

/* compile with:
cc -g -Wall -c file-2.c
*/

#include "file-1.h"
#include "file-2.h"

static double localVar;

static float localFunction (char dummy)
{
    return (3.14159);
} // localFunction

float file2pi (void)
{
    return (localFunction('x'));
} // file2pi

// changes the value of g_globalVar
void file2Function (void)
{
    g_globalVar = 42;
    localVar = 1.2345;
} // file2Function
