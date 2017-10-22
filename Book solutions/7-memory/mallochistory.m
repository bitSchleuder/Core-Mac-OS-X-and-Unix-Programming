// mallochistory.m -- do some mallocation so we can use malloc_history
// be sure to the environment variable MallocStackLogging or
// MallocStackLoggingNoCompact to 1. Then run this program, and while
// it sleeps at the end, run 'malloc_history pid -all_by_size' or
// 'malloc_history pid -all_by_count'

/* compile with:
cc -g -Wall -o mallochistory mallochistory.m
*/

#import <unistd.h>   // for getpid(), sleep()
#import <stdlib.h>   // for malloc()
#import <stdio.h>    // for printf

void func2 ()
{
    char *stuff;
    int i;

    for (i = 0; i < 3; i++) {
        stuff = malloc (50);
        free (stuff);
    }
    stuff = malloc (50);
    // so we can use the malloc_history address feature
    printf ("address of stuff is %p\n", stuff);

    // intentionally leak stuff

} // func2

void func1 ()
{
    int *numbers;

    numbers = malloc (sizeof(int) * 100);
    func2 ();

    // intentionally leak numbers
    
} // func1

int main (int argc, char *argv[])
{
    printf ("my process id is %d\n", getpid());
    func1 ();

    sleep (600);
    return (0);
} // main
