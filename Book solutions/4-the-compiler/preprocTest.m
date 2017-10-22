// preprocTest -- a program to show preprocessor output

/* compile with:
cc -g -Wall -o preprocTest preprocTest.m
or
cc -Wall -E preprocTest.m > junk.i
*/

#import <stdio.h>

#define BUFFER_SIZE 2048

int main (int argc, char *argv[])
{
    char buffer[BUFFER_SIZE];   /* this is a comment */
    char *thing;
    
    thing = fgets (buffer, BUFFER_SIZE, stdin);
    printf ("%s", thing);

    /* some other comment */
    return (0);

} // main
