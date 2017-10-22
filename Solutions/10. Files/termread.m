// termread.m - read from standard IN.  And see if it reads char-by-char or
// line at a time.  yep, reads line at a time

/* compile with
 cc -g -o termread termread.m
*/

#import <fcntl.h>
#import <sys/types.h>
#import <sys/uio.h>
#import <unistd.h>
#import <errno.h>

int main (int argc, char *argv[])
{
    ssize_t bytesread;
    char buffer[4096];
    

    do {
	bytesread = read (STDIN_FILENO, buffer, 4096 - 1);
	if (bytesread == 0) {
	    printf ("end of file.  bye!\n");
	} else if (bytesread < 0) {
	    printf ("error: errno %d (%s)\n", errno, strerror(errno));
	} else {
	    buffer[bytesread] = '\000';
	    printf ("read: %s", buffer);
	}
    }	while (bytesread > 0);

} // main
