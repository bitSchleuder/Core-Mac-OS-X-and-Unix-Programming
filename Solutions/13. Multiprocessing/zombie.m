// zombie.m -- make a zombie process

/* compile with
cc -g -Wmost -o zombie zombie.m
*/

#import <sys/types.h>	// for pid_t
#import <sys/wait.h>	// for wait()
#import <unistd.h>	// for fork
#import <stdlib.h>	// for EXIT_SUCCESS
#import <stdio.h>	// for printf



int main (int argc, char *argv[])
{
    pid_t child;
    int status;

    if (child = fork()) {
	// in parent
	printf ("Child pid is %ld\n", (long)child);
    } else {
	// in child
	exit (123);
    }

    printf ("check out ps for the child.  It should be zombie\n");
    sleep (15); // take a look at ps during this time

    // now reap the child

    wait (&status);

    printf ("child reaped, status of %d.  It should now be gone from ps.\n",
	    WEXITSTATUS(status));

    sleep (15);

    printf ("that's all folks\n");

    return (EXIT_SUCCESS);

} // main

