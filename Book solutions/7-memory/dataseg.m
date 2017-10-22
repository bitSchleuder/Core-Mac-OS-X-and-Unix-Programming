// dataseg.m -- show size of data segments

/* compile with:
cc -g -Wall -o dataseg dataseg.m
*/

#import <stdio.h>

// about 8K doubles. lives in the initialized data segment.
double x[] = {
    0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0,
    10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0, 17.0, 18.0, 19.0, 
    ...
    1010.0, 1011.0, 1012.0, 1013.0, 1014.0, 1015.0, 
    1016.0, 1017.0, 1018.0, 1019.0
};

// one meg, all zeros.  Lives in the uninitailzed data segment
char buffer[1048576]; 

int main (int argc, char *argv[])
{
    printf ("hi!\n");
    return (0);
} // main
