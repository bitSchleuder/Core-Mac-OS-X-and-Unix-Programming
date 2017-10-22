// simpleclient.m -- read from stdin and send to the simpleserver

/* compile with
cc -g -Wmost -o simpleclient simpleclient.m
*/

#import <sys/types.h>	// random types
#import <netinet/in.h>	// for sockaddr_in
#import <sys/socket.h>	// for socket(), AF_INET
#import <netdb.h>	// for gethostbyname, h_errno, etc
#import <errno.h>	// for errno
#import <string.h>	// for strerror
#import <stdlib.h>	// for EXIT_SUCCESS
#import <stdio.h>	// for fprintf
#import <unistd.h>	// for close

#define PORT_NUMBER 2342

int main (int argc, char *argv[])
{
    int programResult = EXIT_FAILURE;
    int fd = -1, result;
    struct sockaddr_in serverAddress;
    struct hostent *hostInfo;

    if (argc != 2) {
	fprintf (stderr, "usage: client hostname\n");
	goto bailout;
    }

    hostInfo = gethostbyname(argv[1]);

    if (hostInfo == NULL) {
	fprintf (stderr, "could not gethostbyname for '%s'\n", argv[1]);
	fprintf (stderr, "  error: %d / %s\n", h_errno, hstrerror(h_errno));
	goto bailout;
    }
    serverAddress.sin_len = sizeof (struct sockaddr_in);
    serverAddress.sin_family = AF_INET;
    serverAddress.sin_port = htons (PORT_NUMBER);
    serverAddress.sin_addr = *((struct in_addr *)(hostInfo->h_addr));
    memset (&(serverAddress.sin_zero), 0, sizeof(serverAddress.sin_zero));

    result = socket (AF_INET, SOCK_STREAM, 0);

    if (result == -1) {
	fprintf (stderr, "could not make a socket.  error: %d / %s\n",
		 errno, strerror(errno));
	goto bailout;
    }
    fd = result;

    // no need to bind() or listen()


    result = connect (fd, (struct sockaddr *)&serverAddress, sizeof(serverAddress));

    if (result == -1) {
	fprintf (stderr, "could not connect.  error: %d / %s\n",
		 errno, strerror(errno));
	goto bailout;
    }

    do {
	char buffer[4096];
	size_t readCount;
	readCount = fread (buffer, 1, 4096, stdin);

	result = write (fd, buffer, readCount);

	if (result == -1) {
	    fprintf (stderr, "error writing: %d / %s\n", errno, strerror(errno));
	    break;
	}

	// check EOF
	if (readCount < 4096) {
	    if (ferror(stdin)) {
		fprintf (stderr, "error reading: %d / %s\n", errno, strerror(errno));
	    } else if (feof(stdin)) {
		fprintf (stderr, "EOF\n");
	    }
	    break;
	}

    } while (1);


    programResult = EXIT_SUCCESS;

bailout:
    close (fd);
    return (programResult);


} // main

