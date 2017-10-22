// getopt.m -- play with the BSD getopt() function

/* compile with
cc -g -Wall -o getopt getopt.m
*/

#import <unistd.h>	// for getopt()
#import <stdlib.h>	// for EXIT_SUCCESS/FAILURE
#import <stdio.h>	// for priintf

int main (int argc, char *argv[])
{
    int ch;

    while ( (ch = getopt(argc, argv, "fkt:u:V")) != -1) {
        switch (ch) {
          case 'f':
            printf ("found an 'f' flag\n");
            break;
          case 'k':
            printf ("found a 'k' flag\n");
            break;
          case 't':
            printf ("found a 't' flag, and the argument is %s\n",
                    optarg);
            break;
          case 'u':
            printf ("found a 'u' flag, and the argument is %s\n", 
                    optarg);
            break;
          case 'V':
            printf ("found a 'V' flag");
            break;
          case '?':
          default:
            printf ("d'oh!  use these flags: f, k, t (file), u(file), V\n");
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
