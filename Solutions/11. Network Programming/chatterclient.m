// chatterclient.m -- client side of the chatter world

/* compile with
cc -g -Wmost -o chatterclient chatterclient.m
*/


/* message protocol
 * first message is:
 *
 * 1 byte : length of message, no more than 8
 * length bytes : the nickname of the user
 *
 * 1 byte : length of message
 * length bytes : message, not zero-terminated
 *
 * therefore, maxmimum message size is 256 bytes
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
#import <fcntl.h>	// for fcntl()

#define PORT_NUMBER 2342

int writeString (int fd, const void *buffer, size_t length)
{
    int result;
    unsigned char byte;

    if (length > 255) {
	fprintf (stderr, "truncating message to 255 bytes\n");
	length = 255;
    }
    byte = (unsigned char)length;

    result = write (fd, &byte, 1);
    if (result <= 0) {
	goto bailout;
    }

    do {
	result = write (fd, buffer, length);
	if (result <= 0) {
	    goto bailout;
	}
	length -= result;
	buffer += result;
	
    } while (length > 0);

bailout:
    return (result);

} // writeAll


int main (int argc, char *argv[])
{
    int programResult = EXIT_FAILURE;
    int fd = -1, result;
    struct sockaddr_in serverAddress;
    struct hostent *hostInfo;
    unsigned char length;

    if (argc != 3) {
	fprintf (stderr, "usage: chatterclient hostname nickname\n");
	goto bailout;
    }

    // limit nickname to 8 characters
    if (strlen(argv[2]) > 8) {
	fprintf (stderr, "nickname must be 8 characters or less\n");
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

    // set standard in to non-blocking
    result = fcntl (STDIN_FILENO, F_SETFL, O_NONBLOCK);
    if (result == -1) {
	fprintf (stderr, "setting nonblock failed.  error: %d / %s\n",
		 errno, strerror(errno));
	goto bailout;
    }

    result = connect (fd, (struct sockaddr *)&serverAddress, sizeof(serverAddress));

    if (result == -1) {
	fprintf (stderr, "could not connect.  error: %d / %s\n",
		 errno, strerror(errno));
	goto bailout;
    }

    // first, send the nickname
    length = strlen(argv[2]);
    result = write (fd, &length, 1);

    if (result == -1) {
	fprintf (stderr, "could not write nickname length.  error: %d / %s\n",
		 errno, strerror(errno));
	goto bailout;
    }

    result = write (fd, argv[2], length);
    if (result == -1) {
	fprintf (stderr, "could not write nickname.  error: %d / %s\n",
		 errno, strerror(errno));
	goto bailout;
    }

    // now set to non-block
    result = fcntl (fd, F_SETFL, O_NONBLOCK);
    if (result == -1) {
	fprintf (stderr, "setting nonblock on server fd failed.  error: %d / %s\n",
		 errno, strerror(errno));
	goto bailout;
    }
    

    do {
	fd_set readfds;
	char buffer[255];
	
	FD_ZERO (&readfds);
	FD_SET (STDIN_FILENO, &readfds);
	FD_SET (fd, &readfds);
	
	result = select (fd + 1, &readfds, NULL, NULL, NULL);

	if (result == -1) {
	    fprintf (stderr, "error from select(): error %d / %s\n",
		     errno, strerror(errno));
	    continue;
	}

	if (FD_ISSET (STDIN_FILENO, &readfds)) {

	    result = read (STDIN_FILENO, buffer, 254);
	    if (result == -1) {
		fprintf (stderr, "error reading from stdin.  Error %d / %s\n",
			 errno, strerror(errno));
		goto bailout;
	    } else if (result == 0) {
		// closed
		break;
	    }
	    length = result; // lop off the CR
	    result = writeString (fd, buffer, length);
	    if (result == -1) {
		fprintf (stderr, "error writing to chatterserver.  error %d / %s\n",
			 errno, strerror(errno));
		goto bailout;
	    }
	}
	if (FD_ISSET (fd, &readfds)) {
	    char largeBuffer[4096];
	    result = read (fd, largeBuffer, 4096);
	    if (result == -1) {
		fprintf (stderr, "error reading from chatterserver.  error %d / %s\n",
			 errno, strerror(errno));
		goto bailout;
	    } else if (result == 0) {
		fprintf (stderr, "server closed connection\n");
		break;
	    } else {
		largeBuffer[result] = '\000';
		printf ("%s", largeBuffer);
	    }
	}

    } while (1);

    programResult = EXIT_SUCCESS;

bailout:
    close (fd);

    return (programResult);

} // main

