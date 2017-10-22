// writestring.m -- take argv[1] and write it to a file, 
//                  prepending the length of the string

/* compile with:
cc -g -Wall -o writestring writestring.m
*/

#import <fcntl.h>       // for open()
#import <sys/stat.h>    // for permission flags
#import <stdlib.h>      // for EXIT_SUCCESS et. al.
#import <stdio.h>       // for printf() and friends
#import <errno.h>       // for errno 
#import <string.h>       // for strerror()
#import <unistd.h>       // for write()

int main (int argc, char *argv[])
{
    int fd;
    int stringLength;
    ssize_t result;

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
    
    // write the length
    stringLength = strlen (argv[1]);
    result = write (fd, &stringLength, sizeof(stringLength));

    if (result == -1) {
        fprintf (stderr, "cannot write to file.  Error %d (%s)\n",
                 errno, strerror(errno));
        exit (EXIT_FAILURE);
    }

    // now write the string
    result = write (fd, argv[1], stringLength);

    if (result == -1) {
        fprintf (stderr, "cannot write to file.  Error %d (%s)\n",
                 errno, strerror(errno));
        exit (EXIT_FAILURE);
    }

    close (fd);

    exit (EXIT_SUCCESS);

} // main
