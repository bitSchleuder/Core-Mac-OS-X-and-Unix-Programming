#import <stdio.h>

#define BUFFER_SIZE 2048

int main (int argc, char *argv[])
{
    char buffer[BUFFER_SIZE];	/* this is my buffer, there are many like it */
    char *thing;
    
    thing = fgets (buffer, BUFFER_SIZE, stdin);
    printf ("%s", thing);

    /* happiness and light */
    return (0);

} // main

