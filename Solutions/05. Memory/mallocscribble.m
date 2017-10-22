// mallocscribble.m -- exercise MallocScribble
// run this, then run after doing a 'setenv MallocScribble 1' in the shell

/* compile wth
cc -o mallocscribble mallocscribble.m
*/

#import <stdlib.h>

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


} // main

