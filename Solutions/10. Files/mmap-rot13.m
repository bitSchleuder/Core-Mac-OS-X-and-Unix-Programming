// mmap-rot13.m -- use memory mapped I/O to apply the rot 13 'encryption'
//                 algorithm to a file.

/* compile with
cc -g -o mmap-rot13 mmap-rot13.m
*/

#import <sys/fcntl.h>	// for O_RDWR and open()
#import <sys/stat.h>	// for fstat() and struct stat
#import <sys/mman.h>	// for mmap, etc
#import <stdio.h>	// printf, etc
#import <errno.h>	// for errno
#import <stdlib.h>	// EXIT_SUCCESS, etc

// walk the buffer shifting alphabetic characters 13 places
void rot13 (caddr_t base, size_t length)
{
    char *scan, *stop;

    scan = base;
    stop = scan + length;

    while (scan < stop) {
	// there are tons of implementations of rot13 out on the net
	// much more compact than this
	if (isalpha(*scan)) {
	    if (   (*scan >= 'A' && *scan <= 'M')
		|| (*scan >= 'a' && *scan <= 'm')) {
		*scan += 13;
	    } else if (   (*scan >= 'N' && *scan <= 'Z')
		|| (*scan >= 'n' && *scan <= 'z')) {
		*scan -= 13;
	    }
	}
	scan++;
    }

} // rot13


void processFile (const char *filename)
{
    int fd = -1;
    int result;
    caddr_t base = (caddr_t) -1;
    size_t length;
    struct stat statbuf;

    // open the file first
    fd = open (filename, O_RDWR);
    if (fd == -1) {
	fprintf (stderr, "could not open %s: error %d (%s)\n",
		 filename, errno, strerror(errno));
	goto bailout;
    }

    // figure out how big it is
    result = fstat (fd, &statbuf);
    if (result == -1) {
	fprintf (stderr, "fstat of %s failed: error %d (%s)\n",
		 filename, errno, strerror(errno));
	goto bailout;
    }
    length = statbuf.st_size;

    // mmap it
    base = mmap (NULL, length, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    if (base == (caddr_t) -1) {
	fprintf (stderr, "could not mmap %s: error %d (%s)\n",
		 filename, errno, strerror(errno));
	goto bailout;
    }

    // actually perform the rot13 algorithm
    rot13 (base, length);

    // flush the results
    result = msync (base, length, MS_SYNC);
    if (result == -1) {
	fprintf (stderr, "msync failed for %s: error %d (%s)\n",
		 filename, errno, strerror(errno));
	goto bailout;
    }

 bailout:
    // clean up any messes we've made
    if (base != (caddr_t) -1) {
	munmap (base, length);
    }
    if (fd != -1) {
	close (fd);
    }
    
} // processFile


int main (int argc, char *argv[])
{
    int i;

    if (argc == 1) {
	fprintf (stderr, "usage: %s /path/to/file ... \n"
		 "rot-13s files in-place using memory mapped i/o\n", argv[0]);
	exit (EXIT_FAILURE);
    }

    for (i = 1; i < argc; i++) {
	processFile (argv[i]);
    }

    exit (EXIT_SUCCESS);

} // main
