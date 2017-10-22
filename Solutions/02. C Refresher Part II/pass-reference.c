// pass-reference.c -- show pass-by-reference using pointers

/* compile with
gcc -g -o pass-reference pass-reference.c -lm 
(Linux)
cc -g -o pass-reference pass-reference.c
(Mac OS X)
*/

#include <stdio.h>	// for printf

void addemUp (int a, int b, int *result)
{
    *result = a + b;
} // addemUp


int main (int argc, char *argv[])
{
    int answer;

    addemUp (1, 2, &answer);

    printf ("1 + 2 = %d\n", answer);

} // main

