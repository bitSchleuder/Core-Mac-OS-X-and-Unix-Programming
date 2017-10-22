// writestring.m -- take argv[1] and write it to a file, prepending the
//                  length of the string

/* compile with
cc -g -o writestring writestring.m
 */

#import <fcntl.h>	// for open()
#import <sys/stat.h>	// for permission flags
#import <stdlib.h>	// for EXIT_SUCCESS et. al.
#import <stdio.h>	// for printf() and friends
#import <errno.h>	// for errno and strerror()


int main (int argc, char *argv[])
{
    int fd;
    int stringLength;
    ssize_t result;

    if (argc != 2) {
	fprintf (stderr, "usage:  %s string-to-log", argv[0]);
	exit (EXIT_FAILURE);
    }
    
    fd = open ("/tmp/stringfile.txt", O_WRONLY | O_CREAT | O_TRUNC, 
	       S_IRUSR | S_IWUSR);

    if (fd == -1) {
	fprintf (stderr, "can't open file.  Error %d (%s)\n",
		 errno, strerror(errno));
	exit (EXIT_FAILURE);
    }

    stringLength = strlen (argv[1]);
    result = write (fd, &stringLength, sizeof(stringLength));

    if (result == -1) {
	fprintf (stderr, "can't write to file.  Error %d (%s)\n",
		 errno, strerror(errno));
	exit (EXIT_FAILURE);
    }

    result = write (fd, argv[1], stringLength);

    if (result == -1) {
	fprintf (stderr, "can't write to file.  Error %d (%s)\n",
		 errno, strerror(errno));
	exit (EXIT_FAILURE);
    }

    close (fd);

    exit (EXIT_SUCCESS);

} // main

