// multilineMacro.m -- multi-line macro hygiene

/* compile with:
cc -g -Wall -o multilineMacro multilineMacro.m
*/

#import <stdio.h>

#define FOUND_AN_ERROR(desc)   \
     error_count++;   \
     fprintf(stderr, "found an error '%s' at file %s, line %d\n", \
             desc, __FILE__, __LINE__);

int error_count;

int main (int argc, char *argv[])
{
    if (argc == 2) {
        FOUND_AN_ERROR ("something bad happened");
    }
    printf ("done\n");
    return (0);
} // main
