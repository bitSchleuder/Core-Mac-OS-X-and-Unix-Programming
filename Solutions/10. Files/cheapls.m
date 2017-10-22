// cheapls.m -- a cheap-o ls program using the directory iteration functions

/* compile with
cc -g -o cheapls cheapls.m
*/

#import <sys/types.h>	// for random type definition
#import <sys/dirent.h>	// for struct dirent
#import <dirent.h>	// for opendir and friends
#import <stdlib.h>	// for EXIT_SUCCESS
#import <stdio.h>	// for printf
#import <errno.h>	// for errno

int main (int argc, char *argv[])
{
    DIR *directory;
    struct dirent *entry;
    int result;

    if (argc != 2) {
	fprintf (stderr, "usage:  %s /path/to/directory\n", argv[0]);
	exit (EXIT_FAILURE);
    }

    directory = opendir (argv[1]);
    if (directory == NULL) {
	fprintf (stderr, "could not open directory '%s'\n", argv[1]);
	fprintf (stderr, "let's see if errno is useful: %d (%s)\n",
		 errno, strerror(errno));
	exit (EXIT_FAILURE);
    }

    while ( (entry = readdir(directory)) != NULL) {
	long position = telldir (directory);
	printf ("%3ld: %s\n", position, entry->d_name);
    }

    result = closedir (directory);
    if (result == -1) {
	fprintf (stderr, "error closing directory: %d (%s)\n",
		 errno, strerror(errno));
	exit (EXIT_FAILURE);
    }

} // main

