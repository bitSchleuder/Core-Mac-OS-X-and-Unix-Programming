// variables.c -- some simple variable declarations

/* compile with
gcc -g -o variables variables.c
(Linux)
cc -g -o variables variables.c
(Mac OS X)
*/

#include <stdio.h>	// for printf

int aGlobalInt;		// global
float pi = 3.14159;	// global


void someFunction ()
{
    int aLocalVariable = 0;	// local
    unsigned short myShort;	// local
    static unsigned char aByte;	// static

    myShort = 500;
    aGlobalInt = 5;

    aByte++;

    printf ("aByte: %d, myShort: %d  aGlobalInt: %d\n", 
	    aByte, myShort, aGlobalInt);

} // someFunction


int main (int argc, char *argv[])
{
    printf ("aGlobalInt before someFunction: %d\n", aGlobalIntt);
    someFunction ();
    printf( "aGlobalInt after someFunction: %d\n", aGlobalInt);
    someFunction ();
    aGlobalInt = 23;
    someFunction ();

} // main


