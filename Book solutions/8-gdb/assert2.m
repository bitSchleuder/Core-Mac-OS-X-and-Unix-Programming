// assert2.m -- invoke assert, thereby dropping a core file

/* compile with:
cc -g -Wall -o assert2 assert2.m
*/

#import <assert.h>        // for assert()
#import <stdio.h>         // for printf() and firends
#import <sys/types.h>     // for random types
#import <sys/time.h>      // for random types
#import <sys/resource.h>  // for setrlimit()
#import <errno.h>         // for errno
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

void enableCoreDumps()
{
	struct rlimit rl;

	rl.rlim_cur = RLIM_INFINITY;
	rl.rlim_max = RLIM_INFINITY;
	
	if (setrlimit (RLIMIT_CORE, &rl) == -1){
		fprintf(stderr, "error in setrlimit for RLIMIT_CORE: %d (%s)\n",
				errno,strerror(errno));
	}

}//enableCoreDumps

int main (int argc, char *argv[])
{

    enableCoreDumps();

    someFunction (argv[1]);
    return (EXIT_SUCCESS);
} // main
