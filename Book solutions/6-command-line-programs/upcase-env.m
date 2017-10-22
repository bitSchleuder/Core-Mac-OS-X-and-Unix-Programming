// upcase.m -- convert text to upper case

/* compile with
cc -g -Wall -o upcase-env upcase-env.m
*/
#import <Foundation/Foundation.h>     // for BOOL
#import <stdlib.h>                    // for EXIT_FAILURE/SUCCESS
#import <stdio.h>                     // for standard I/O stuff


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
    
    char *envSetting;
    
    envSetting = getenv ("CASE_CONV");
    
    if (envSetting != NULL) {
	if (strcmp(envSetting, "UPPER") == 0) {
	    printf ("upper!\n");
	    upcase = YES;
	}
	if (strcmp(envSetting, "LOWER") == 0) {
	    printf ("lower!\n");
	    upcase = NO;
	}
    }
    
    while (!feof(stdin)) {
        length = fread (buffer, 1, BUFFER_SIZE, stdin);
        changecaseBuffer (buffer, length, upcase);
        fwrite (buffer, 1, length, stdout);
    }

    return (EXIT_SUCCESS);

} // main
