// mallochistory.m -- do some mallocation so we can use malloc_history
// be sure to the environment variable MallocStackLogging or
// MallocStackLoggingNoCompact to 1. Then run this proram, and while it
// sleeps at the end, run 'malloc_history pid -all_by_size' or
// 'malloc_history pid -all_by_count'

/* compile with
cc -g -o mallochistory mallochistory.m
*/

#import <stdlib.h>

int func2 ()
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


int func1 ()
{
    int i;
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

} // main
