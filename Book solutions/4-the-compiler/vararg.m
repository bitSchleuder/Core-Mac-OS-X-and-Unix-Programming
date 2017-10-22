// vararg.m -- demonstrate variable argument lists

/* compile with:
cc -g -Wall -o vararg vararg.m
*/

#import <stdio.h>    // for printf
#import <stdarg.h>   // varargs stuff

// sum all the integers passed in.  Stopping if it is zero

int addemUp (int firstNum, ...)
{
    va_list args;

    int sum = firstNum;
    int number;

    va_start (args, firstNum);

    while (1) { // just keep spinning until we are done
        number = va_arg (args, int);
        sum += number;
        if (number == 0) {
            break;
        }
    }

    va_end (args);

    return (sum);

} // addemUp

int main (int argc, char *argv[])
{
    int sumbody;

    sumbody = addemUp (1,2,3,4,5,6,7,8,9,0);
    printf ("sum of 1..9 is %d\n", sumbody);

    sumbody = addemUp (1,3,5,7,9,11,0);
    printf ("sum of odds from 1..11 is %d\n", sumbody);

    return (0);

} // main
