// fork.m -- show simple use of fork()

/* compile with
cc -g -Wmost -o fork fork.m
*/


#import <sys/types.h>	// for pid_t
#import <unistd.h>	// for fork
#import <stdlib.h>	// for EXIT_SUCCESS
#import <stdio.h>	// for printf


int main (int argc, char *argv[])
{
    pid_t child;

    printf ("hello there");

    if (child = fork()) {
	printf ("\nChild pid is %ld\n", (long)child);
	sleep (5);
    } else {
	printf ("\nIn the child.  My parent is %ld\n", (long)getppid());
	_exit (EXIT_SUCCESS);
    }

    exit (EXIT_SUCCESS);

} // main
