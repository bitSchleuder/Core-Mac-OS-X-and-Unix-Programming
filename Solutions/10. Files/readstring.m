// readstring.m -- open /tmp/stringfile.txt and write out its contents

/* compile with
cc -g -o readstring readstring.m
 */

#import <fcntl.h>	// for open()
#import <stdlib.h>	// for EXIT_SUCCESS et. al.
#import <stdio.h>	// for printf() and friends
#import <errno.h>	// for errno and strerror()


int main (int argc, char *argv[])
{
    int fd;
    int stringLength;
    ssize_t result;
    char *buffer;

    fd = open ("/tmp/stringfile.txt", O_RDONLY);

    if (fd == -1) {
	fprintf (stderr, "can't open file.  Error %d (%s)\n",
		 errno, strerror(errno));
	exit (EXIT_FAILURE);
    }

    result = read (fd, &stringLength, sizeof(stringLength));

    if (result == -1) {
	fprintf (stderr, "can't read file.  Error %d (%s)\n",
		 errno, strerror(errno));
	exit (EXIT_FAILURE);
    }

    buffer = malloc (stringLength + 1);  // must account for trailing zero byte

    result = read (fd, buffer, stringLength);

    if (result == -1) {
	fprintf (stderr, "can't read file.  Error %d (%s)\n",
		 errno, strerror(errno));
	exit (EXIT_FAILURE);
    }

    buffer[stringLength] = '\000';

    close (fd);

    printf ("our string is '%s'\n", buffer);

    free (buffer); // clean up our mess

    exit (EXIT_SUCCESS);

} // main

