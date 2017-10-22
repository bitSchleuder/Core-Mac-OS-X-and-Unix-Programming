// argparse.m -- using getopt to parse arguments

#import <unistd.h>
#import <stdlib.h>

// here's a very contrived program, but it shows how to handle parsing
// different command line arguments.  Say for a webserver

// here are the flags 
// single flag values:
//   -f 
//   -k 
// -t file-name
// -u file-name
// -V prints stuff and exits the program
// and then an arbitrary number of file names

// "fkit:u:V"
// getopt will parse up through flags, and then leave file names alone

// and yeah, -t -f  will assume that the arg to -t is -f


int main (int argc, char *argv[])
{
    int ch;

    while ( (ch = getopt(argc, argv, "fkit:u:V")) != -1) {
	switch (ch) {
	case 'f':
	    printf ("found an 'f' flag\n");
	    break;
	case 'k':
	    printf ("found a 'k' flag\n");
	    break;
	case 't':
	    printf ("found a 't' flag, and the argument is %s\n", optarg);
	    break;
	case 'u':
	    printf ("found a 'u' flag, and the argument is %s\n", optarg);
	    break;
	case 'V':
	    printf ("found a 'V' flag");
	    break;
	case '?':
	default:
	    printf ("d'oh!  use these flags: f, k, i, t (file), u(file), V\n");
	    return (EXIT_FAILURE);
	}
    }

    // bias the argv/argc to skip over the processed args
    argc -= optind;
    argv += optind;

    {
	int i;
	for (i = 0; i < argc; i++) {
	    printf ("found file argument: %s\n", argv[i]);
	}
    }

    return (EXIT_SUCCESS);

} // main


