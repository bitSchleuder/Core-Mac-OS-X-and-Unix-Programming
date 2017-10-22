// assert2.m -- invoke assert, thereby dropping a core file

/* compile with
cc -g -o assert2 assert2.m
*/

#import <assert.h>
#import <stdio.h>

#import <sys/types.h>
#import <sys/time.h>
#import <sys/resource.h>

#import <errno.h>


void anotherFunction (char *ook)
{
    assert (strlen(ook) > 0);

    printf ("wheeee! Got string %s\n", ook);

} // anotherFunction

void someFunction (char *blah)
{
    anotherFunction (blah);
} // someFunction

void enableCoreDumps ()
{
    struct rlimit rl;

    rl.rlim_cur = RLIM_INFINITY;
    rl.rlim_max = RLIM_INFINITY;

    if (setrlimit (RLIMIT_CORE, &rl) == -1) {
	fprintf (stderr, "error in setrlimit for RLIMIT__COR: %d (%s)\n",
		 errno, strerror(errno));
    }

} // enableCoreDumps


int main (int argc, char *argv[])
{
    enableCoreDumps ();

    someFunction (argv[1]);

} // main


