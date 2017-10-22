// minimal 'read from stdin, process, send to stdout'

#import <stdlib.h>			// for EXIT_FAILURE
#import <Foundation/Foundation.h>	// for BOOL
#import <stdio.h>			// for standard I/O stuff

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


#define BUFFER_SIZE 2048

int main (int argc, char *argv[])
{
    char buffer[BUFFER_SIZE];
    size_t length;
    BOOL upcase = YES;

    while (!feof(stdin)) {
	length = fread (buffer, 1, BUFFER_SIZE, stdin);
	changecaseBuffer (buffer, length, upcase);
	fwrite (buffer, 1, length, stdout);
    }

} // main

