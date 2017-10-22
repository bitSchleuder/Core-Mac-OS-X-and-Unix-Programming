// assert.m -- invoke assert, thereby dropping a core file

/* compile with:
cc -g -Wall -o assert assert.m
*/

#import <assert.h>        // for assert
#import <stdio.h>         // for printf() and friends
#import <string.h>        // for strlen()
#import <stdlib.h>        // for EXIT_SUCCESS

void anotherFunction (char *ook)
{
    assert (strlen(ook) > 0);

    printf ("wheeee! Got string %s\n", ook);

} // anotherFunction


void someFunction (char *blah)
{
    anotherFunction (blah);
} // someFunction


int main (int argc, char *argv[])
{
    someFunction (argv[1]);
    return (EXIT_SUCCESS);
} // main
