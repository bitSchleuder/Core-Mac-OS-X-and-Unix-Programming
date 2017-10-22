// buffread.m -- show how to read using buffered I/O, including 
//               error / eof handling

/* compile with:
cc -g -Wall -o buffread buffread.m
*/

#import <stdlib.h>      // for EXIT_SUCCESS, etc
#import <stdio.h>       // all the buffered I/O API
#import <errno.h>       // for errno
#import <string.h>      // for strerror()

int main (int argc, char *argv[])
{
    FILE *file;
    int result;

    file = fopen ("/etc/motd", "r");

    while (1) {
        result = fgetc (file);
        if (result == EOF) {
            if (feof(file)) {
                printf ("EOF found\n");
            }
            if (ferror(file)) {
                printf ("error reading file: %d (%s)\n", 
                        errno, strerror(errno));
            }
            break;
        } else {
            printf ("got a character: '%c'\n", (char) result);
        }
    }

    fclose (file);

    return (EXIT_SUCCESS);

} // main
