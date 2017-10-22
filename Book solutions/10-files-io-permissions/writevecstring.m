// writevecstring.m -- take argv[1] and write it to a file, prepending 
//                     the length of the string.  and using 
//                     scatter/gather I/O

/* compile with:
cc -g -Wall -o writevecstring writevecstring.m
*/

#import <sys/types.h>   // for ssize_t
#import <sys/uio.h>     // for writev() and struct iovec
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
    struct iovec vector[2]; // one for size, one for string

    if (argc != 2) {
        fprintf (stderr, "usage:  %s string-to-log\n", argv[0]);
        exit (EXIT_FAILURE);
    }
    
    fd = open ("/tmp/stringfile.txt", O_WRONLY | O_CREAT | O_TRUNC, 
               S_IRUSR | S_IWUSR);

    if (fd == -1) {
        fprintf (stderr, "cannot open file.  Error %d (%s)\n",
                 errno, strerror(errno));
        exit (EXIT_FAILURE);
    }
    
    stringLength = strlen (argv[1]);
    vector[0].iov_base = (void *) &stringLength;
    vector[0].iov_len = sizeof(stringLength);
    vector[1].iov_base = argv[1];
    vector[1].iov_len = stringLength;

    result = writev (fd, vector, 2);

    if (result == -1) {
        fprintf (stderr, "cannot write to file.  Error %d (%s)\n",
                 errno, strerror(errno));
        exit (EXIT_FAILURE);
    }

    close (fd);

    exit (EXIT_SUCCESS);

} // main
