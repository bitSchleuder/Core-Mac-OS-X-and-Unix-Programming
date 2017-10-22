// mallocscribble.m -- exercise MallocScribble

/* compile wth:
cc -g -Wall -o mallocscribble mallocscribble.m
*/

#import <stdlib.h>      // for malloc()
#import <stdio.h>       // for printf()
#import <string.h>      // for strcpy()


typedef struct Thingie {
    char blah[16];
    char string[30];
} Thingie;

int main (int argc, char *argv[])
{
    Thingie *thing = malloc (sizeof(Thingie));
    
    strcpy (thing->string, "hello there");
    printf ("before free: %s\n", thing->string);
    free (thing);
    printf ("after free: %s\n", thing->string);
 
    return (0);

} // main
