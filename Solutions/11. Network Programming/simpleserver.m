// simpleserver.m -- listen on a port, and display any bytes that come through

/* compile with
cc -g -Wmost -o simpleserver simpleserver.m
*/


#import <sys/types.h>	// random types
#import <netinet/in.h>	// for sockaddr_in
#import <sys/socket.h>	// for socket(), AF_INET
#import <arpa/inet.h>	// for inet_ntoa
#import <errno.h>	// for errno
#import <string.h>	// for strerror
#import <stdlib.h>	// for EXIT_SUCCESS
#import <stdio.h>	// for fprintf
#import <unistd.h>	// for close

#define PORT_NUMBER 2342

int main (int argc, char *argv[])
{
    int fd = -1, result;
    int programResult = EXIT_FAILURE;

    // get a socket
    result = socket (AF_INET, SOCK_STREAM, 0);

    if (result == -1) {
	fprintf (stderr, "could not make a socket.  error: %d / %s\n",
		 errno, strerror(errno));
	goto bailout;
    }
    fd = result;

    // reuse the address so we don't fail on program launch
    {
	int yes = 1;
	result = setsockopt (fd, SOL_SOCKET, SO_REUSEADDR, &yes, sizeof(int));
	if (result == -1) {
	    fprintf (stderr, "could not setsockopt to reuse address. %d / %s\n",
		     errno, strerror(errno));
	    goto bailout;
	}
    }

    // bind to an address and port
    {
	struct sockaddr_in address;
	address.sin_len = sizeof (struct sockaddr_in);
	address.sin_family = AF_INET;
	address.sin_port = htons (PORT_NUMBER);
	address.sin_addr.s_addr = htonl (INADDR_ANY);
	memset (address.sin_zero, 0, sizeof(address.sin_zero));

	result = bind (fd, (struct sockaddr *)&address, sizeof(address));
	if (result == -1) {
	    fprintf (stderr, "could not bind socket.  error: %d / %s\n",
		     errno, strerror(errno));
	    goto bailout;
	}
    }
    
    result = listen (fd, 8);

    if (result == -1) {
	fprintf (stderr, "listen failed.  error: %d /  %s\n",
		 errno, strerror(errno));
	goto bailout;
    }

    while (1) {
	struct sockaddr_in address;
	int addressLength = sizeof(address);
	int remoteSocket;
	char buffer[4096];

	result = accept (fd, (struct sockaddr*)&address, &addressLength);
	if (result == -1) {
	    fprintf (stderr, "accept failed.  error: %d / %s\n",
		     errno, strerror(errno));
	    continue;
	}
	printf ("accepted connection from %s:%d\n",
		inet_ntoa(address.sin_addr), ntohs(address.sin_port));
	remoteSocket = result;

	// drain the socket
	while (1) {
	    result = read (remoteSocket, buffer, 4095);

	    if (result == 0) {
		// EOF.
		break;
	    } else if (result == -1) {
		fprintf (stderr, "could not read from remote socket.  %d / %s\n",
			 errno, strerror(errno));
		break;
	    } else {
		// null-terminate the string and print it out
		buffer[result] = '\000';
		printf ("%s", buffer);
	    }
	}

	close (remoteSocket);

	printf ("\n--------------------------------------------------\n");

    }
    
    programResult = EXIT_SUCCESS;

bailout:
    close (fd);
    return (programResult);
    
} // main


