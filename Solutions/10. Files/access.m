// access.m -- use the access() call to check permissions
//             run this as normal person, then make suid-root and try again

/* to compile:
cc -o access access.m
*/


#import <unistd.h>	// for access()
#import <stdio.h>	// for printf
#import <stdlib.h>	// for EXIT_SUCCESS
#import <errno.h>	// for errno and strerror

int main (int argc, char *argv[])
{
    int result;

    result = access ("/etc/motd", R_OK);

    if (result == 0) {
	printf ("read access to /etc/motd\n");
    } else {
	printf ("no read access to /etc/motd: %d (%s)\n",
		errno, strerror(errno));
    }

    result = access ("/etc/motd", W_OK);

    if (result == 0) {
	printf ("write access to /etc/motd\n");
    } else {
	printf ("no write access to /etc/motd: %d (%s)\n",
		errno, strerror(errno));
    }

} // main

