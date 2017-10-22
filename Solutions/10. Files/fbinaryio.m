// fbinaryio.m -- do some binary reading and writing using buffered i/o

/* compile with
cc -g -o fbinaryio fbinaryio.m
*/

#import <stdlib.h>	// for EXIT_SUCCES, etc
#import <stdio.h>	// for the buffered I/O API
#import <errno.h>	// for errno and strerror()

typedef struct Thing {
    int 	thing1;
    float	thing2;
    char	thing3[8];
} Thing;

Thing things[] = {
    { 3, 3.14159, "hello" },
    { 4, 4.29301, "bye" },
    { 2, 2.14214, "bork" },
    { 5, 5.55556, "elf up" }
};

int main (int argc, char *argv[])
{
    size_t thingCount = sizeof(things) / sizeof(Thing); // how many we have
    size_t numWrote;
    FILE *file;

    file = fopen ("/tmp/thingfile", "w");
    
    if (file == NULL) {
	fprintf (stderr, "error opening file: %d (%s)\n",
		 errno, strerror(errno));
	exit (EXIT_FAILURE);
    }

    numWrote = fwrite (things, sizeof(Thing), thingCount, file);

    if (numWrote != thingCount) {
	fprintf (stderr, "incomplete write (%d out of %d).  Error %d (%s)\n",
		 numWrote, thingCount, errno, strerror(errno));
	exit (EXIT_FAILURE);
    }

    fclose (file);

    // now re-open and re-read and make sure everything is groovy
    file = fopen ("/tmp/thingfile", "r");

    if (file == NULL) {
	fprintf (stderr, "error opening file: %d (%s)\n",
		 errno, strerror(errno));
	exit (EXIT_FAILURE);
    }


    {
	// we know we're reading in thingCount, so we can go ahead and
	// allocate that much space
	Thing readThings[sizeof(things) / sizeof(Thing)];
	ssize_t numRead;
	
	numRead = fread (readThings, sizeof(Thing), thingCount, file);
	if (numRead != thingCount) {
	    fprintf (stderr, "short read.  Got %d, expected %d\n",
		     numRead, thingCount);
	    if (feof(file)) {
		fprintf (stderr, "we got an end of file\n");
	    }
	    if (ferror(file)) {
		fprintf (stderr, "we got an error: %d (%s)\n",
			 errno, strerror(errno));
	    }
	} else {
	    // just for fun, compare the newly read ones with the ones
	    // we have statically declared
	    int i;
	    for (i = 0; i < thingCount; i++) {
		if (   (things[i].thing1 != readThings[i].thing1)
		    || (things[i].thing2 != readThings[i].thing2)
		    || (strcmp(things[i].thing3, readThings[i].thing3) != 0)) {
		    fprintf (stderr, "mismatch with element %d\n", i);
		} else {
		    printf ("successfully compared element %d\n", i);
		}
	    }
	}
    }

    fclose (file);

    exit (EXIT_SUCCESS);

} // main


