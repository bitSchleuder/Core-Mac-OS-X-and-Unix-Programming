// append.m -- show an opening of a logfile, replacing a 
//             standard stream.

/* compile with:
cc -g -Wall -o append append.m
*/

#import <unistd.h>      // for STDOUT_FILENO
#import <stdlib.h>      // for EXIT_SUCCESS
#import <fcntl.h>       // for OPEN
#import <stdio.h>       // for printf() and friends
#import <errno.h>       // for errno
#import <string.h>      // for strerror()
#import <sys/stat.h>     // for permission constants

int main (int argc, char *argv[])
{
    int fd;

    close (STDOUT_FILENO);

    // open a log file, write only, and to always automatically append.
    // oh, and create the file if it does not exist already
    fd = open ("/tmp/logthingie.txt", O_WRONLY | O_CREAT | O_APPEND,
               S_IRUSR | S_IWUSR);

    if (fd == -1) {
        fprintf (stderr, "cannot open log file.  Error %d (%s)\n",
                 errno, strerror(errno));
        exit (EXIT_FAILURE);
    }

    printf ("wheee, we have a log file open\n");

    exit (EXIT_SUCCESS);
    
} // main
