// openfiles.m -- see what happens when we open a lot of files

/* compile with:
cc -g -Wall -o openfiles openfiles.m
*/

#import <fcntl.h>
#import <stdio.h>

int main (int argc, char *argv[])
{
    int fd, i;

    for (i = 0; i < 260; i++) {
        fd = open ("/usr/include/stdio.h", O_RDONLY);
        printf ("%d: fd is %d\n", i, fd);
    }

    return (0);
    
} // main
