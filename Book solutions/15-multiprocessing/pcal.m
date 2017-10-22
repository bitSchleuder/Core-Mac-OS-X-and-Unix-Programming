// pcal.m -- display a calendar using popen

/* compile with:
cc -g -Wall -o pcal pcal.m
*/

#import <stdio.h>       // for popen, printf
#import <stdlib.h>      // for EXIT_SUCCESS

#define BUFSIZE   4096
#define NUM_LINES 9

int main (int argc, char *argv[])
{
    int result = EXIT_FAILURE;
    FILE *pipeline = NULL;
    char buffer[BUFSIZE];
    int i;

    // reverse the lines just for fun
    pipeline = popen ("cal 2003 | rev", "r");

    if (pipeline == NULL) {
        fprintf (stderr, "error popening pipeline\n");
        goto bailout;
    }

    for (i = 0; i < NUM_LINES; i++) {
        if (fgets(buffer, BUFSIZE, pipeline) == NULL) {
            fprintf (stderr, "error reading from pipeline\n");
            goto bailout;
        }
        
        printf ("%s", buffer);
    }
    
    result = EXIT_SUCCESS;

bailout:

    if (pipeline != NULL) {
        pclose (pipeline);
    }

    return (result);

} // main
