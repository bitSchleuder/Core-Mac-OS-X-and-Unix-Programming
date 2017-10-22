// sample.c -- take a tour of basic C stuff

/* compile with
gcc -g -Wmost -o sample sample.c
*/

#include <stdio.h>	// for printf
#include <stdlib.h>	// for EXIT_SUCCESS


// return the next Fibbonacci number in the sequence:
// 1 1 2 3 5 8 13 ...

int nextFibbonacci ()
{
    static int i;
    static int j;
    int value;

    if (i == 0) {
	i = 1;
	return (1);
    } else if (j == 0) {
	j = 1;
    }
    
    value = i + j;
    i = j;
    j = value;

    return (value);

} // nextFibbonacci


int main (int argc, char *argv[])
{
    int i;
    
    for (i = 0; i < 10; i++) {
	printf ("%d\n", nextFibbonacci());
    }

    return (EXIT_SUCCESS);

} // main


