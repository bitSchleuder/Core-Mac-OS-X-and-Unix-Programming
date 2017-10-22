// openfiles.m -- see what happens when we open a lot of files

/* compile with
cc -o openfiles openfiles.m
 */

#import <sys/types.h>
#import <sys/time.h>
#import <sys/resource.h>
#import <fcntl.h>
#import <stdio.h>
#import <errno.h>

int main (int argc, char *argv[])
{
    int fd, i;
    int limit;
    struct rlimit rl;
    
    if (argc != 2) {
	fprintf (stderr, "usage:  %s open-file-rlimit\n", argv[0]);
	exit (1);
    }
    limit = atoi (argv[1]);
    rl.rlim_cur = limit;
    rl.rlim_max = RLIM_INFINITY;

    if (setrlimit(RLIMIT_NOFILE, &rl) == -1) {
	fprintf (stderr, "error in setrlimit for RLIM_NOFILE: %d/%s\n",
		 errno, strerror(errno));
	exit (1);
    }

    for (i = 0; i < 260; i++) {
	fd = open ("/usr/include/stdio.h", O_RDONLY);
	printf ("%d: fd is %d\n", i, fd);
    }

    exit (0);
    
} // main

