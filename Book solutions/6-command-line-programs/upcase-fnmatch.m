// upcase.m -- convert text to upper case

/* compile with
cc -g -Wall -o upcase-fnmatch upcase-fnmatch.m
*/
#import <Foundation/Foundation.h>     // for BOOL
#import <stdlib.h>                    // for EXIT_FAILURE/SUCCESS
#import <stdio.h>                     // for standard I/O stuff
#import <fnmatch.h>		      // for fnmatch()


#define BUFFER_SIZE 2048

void changecaseBuffer (char buffer[], size_t length, BOOL upcase)
{
    char *scan, *stop;

    scan = buffer;
    stop = buffer + length;

    while (scan < stop) {
        if (upcase) {
            *scan = toupper (*scan);
        } else {
            *scan = tolower (*scan);
        }
        scan++;
    }

} // changecaseBuffer


int main (int argc, char *argv[])
{
    char buffer[BUFFER_SIZE];
    size_t length;
    BOOL upcase = YES;


    if (fnmatch ("*upcase", argv[0], 0) == 0) {
        printf ("upcase!\n");
        upcase = YES;
    }
    if (fnmatch ("*downcase", argv[0], 0) == 0) {
        printf ("downcase!\n");
        upcase = NO;
    }


    while (!feof(stdin)) {
        length = fread (buffer, 1, BUFFER_SIZE, stdin);
        changecaseBuffer (buffer, length, upcase);
        fwrite (buffer, 1, length, stdout);
    }

    return (EXIT_SUCCESS);

} // main
