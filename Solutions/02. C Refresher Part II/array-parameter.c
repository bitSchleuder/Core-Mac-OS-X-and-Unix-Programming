// array-parameter.c

/* compile with
gcc -g -o array-parameter array-parameter.c
(Linux)
cc -g -o array-parameter array-parameter.c
(Mac OS X)
*/

#include <stdio.h>

void printArray (int *array, int length)
{
    int i;

    for (i = 0; i < length; i++) {
	printf ("%d: %d\n", i, array[i]);
    }

} // printArray


int main (int argc, char *argv[])
{
    int array1[5];
    int array2[] = { 23, 42, 55 };
    int i;

    for (i = 0; i < 5; i++) {
	array1[i] = i;
    }

    printf ("array 1:\n");
    printArray (array1, 5);

    printf ("array 2:\n");
    printArray (array2, sizeof(array2) / sizeof(int));
    
    return (0);

} // main
