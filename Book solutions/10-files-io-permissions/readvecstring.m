// readvecstring.m -- open /tmp/stringfile.txt and write out 
//                    its contents using scatter/gather reads

/* compile with:
cc -g -Wall -o readvecstring readvecstring.m
*/

#import <sys/types.h>   // for ssize_t
#import <sys/uio.h>     // for readv() and struct iovec
#import <fcntl.h>       // for open()
#import <sys/stat.h>    // for permission flags
#import <stdlib.h>      // for EXIT_SUCCESS et. al.
#import <stdio.h>       // for printf() and friends
#import <errno.h>       // for errno
#import <string.h>      // for strerror()
#import <unistd.h>      // for close()

int main (int argc, char *argv[])
{
    int fd;
    int stringLength;
    ssize_t result;
    char buffer[4096];
    struct iovec vector[2];

    fd = open ("/tmp/stringfile.txt", O_RDONLY);

    if (fd == -1) {
        fprintf (stderr, "cannot open file.  Error %d (%s)\n",
                 errno, strerror(errno));
        exit (EXIT_FAILURE);
    }

    vector[0].iov_base = (void *) &stringLength;
    vector[0].iov_len = sizeof(stringLength);
    vector[1].iov_base = buffer;
    vector[1].iov_len = 4096;

    result = readv (fd, vector, 2);

    if (result == -1) {
        fprintf (stderr, "cannot read file.  Error %d (%s)\n",
                 errno, strerror(errno));
        exit (EXIT_FAILURE);
    }

    buffer[stringLength] = '\000'; // need to zero-terminate it

    close (fd);

    printf ("our string is '%s'\n", buffer);

    exit (EXIT_SUCCESS);

} // main
