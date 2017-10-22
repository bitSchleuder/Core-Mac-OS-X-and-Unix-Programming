// readstring.m -- open /tmp/stringfile.txt and write out 
//                 its contents

/* compile with:
cc -g -Wall -o readstring readstring.m
*/
 
#import <fcntl.h>       // for open()
#import <stdlib.h>      // for EXIT_SUCCESS et. al.
#import <stdio.h>       // for printf() and friends
#import <errno.h>       // for errno and strerror()
#import <string.h>      // for strerror()
#import <unistd.h>      // for close() and read()

int main (int argc, char *argv[])
{
    int fd;
    int stringLength;
    ssize_t result;
    char *buffer;

    fd = open ("/tmp/stringfile.txt", O_RDONLY);

    if (fd == -1) {
        fprintf (stderr, "cannot open file.  Error %d (%s)\n",
                 errno, strerror(errno));
        exit (EXIT_FAILURE);
    }

    result = read (fd, &stringLength, sizeof(stringLength));

    if (result == -1) {
        fprintf (stderr, "cannot read file.  Error %d (%s)\n",
                 errno, strerror(errno));
        exit (EXIT_FAILURE);
    }

    buffer = malloc (stringLength + 1);  // account for trailing 0 byte

    result = read (fd, buffer, stringLength);

    if (result == -1) {
        fprintf (stderr, "cannot read file.  Error %d (%s)\n",
                 errno, strerror(errno));
        exit (EXIT_FAILURE);
    }

    buffer[stringLength] = '\000';

    close (fd);

    printf ("our string is '%s'\n", buffer);

    free (buffer); // clean up our mess

    exit (EXIT_SUCCESS);

} // main
