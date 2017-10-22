// assert.m -- invoke assert, thereby dropping a core file

/* compile with
cc -g -o assert assert.m
*/

#import <assert.h>
#import <stdio.h>


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
} // main


