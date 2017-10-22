// locality.m -- time the effect of locality of reference

/* compile with
cc -g -Wall -o locality locality.m
*/

#include <stdio.h>   // for printf
#include <time.h>    // for time_t, time()
#include <stdlib.h>  // for EXIT_SUCCESS

#define ARRAYSIZE (10000)
int a[ARRAYSIZE][ARRAYSIZE]; // make a huge array

int main (int argc, char *argv[])
{
    int i = 0, j = 0;
    time_t starttime;
    time_t endtime;
    
    starttime = time(NULL);

    // walk the array in row-major order, so that once we're done
    // with a page we never bother with it again

    for (i = 0; i < ARRAYSIZE; i++){
        for(j = 0; j < ARRAYSIZE; j++){
            a[i][j] = 1;
        }
    }

    endtime = time(NULL);

    printf("%d operations in %d seconds.\n", i * j, 
           (int)(endtime - starttime));

    starttime = time(NULL);

    // walk the array in column-major order. We end 
    // up touching a bunch of pages multiple times

    for (j = 0; j < ARRAYSIZE; j++){
        for(i = 0; i < ARRAYSIZE; i++){
            a[i][j] = 1;
        }
    }

    endtime = time(NULL);

    printf("%d operations in %d seconds.\n", i * j, 
           (int)(endtime - starttime));
    
    return (EXIT_SUCCESS);

} // main
