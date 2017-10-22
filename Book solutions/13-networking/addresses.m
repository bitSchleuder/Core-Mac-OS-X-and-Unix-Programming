// addresses.m -- play around with addressing API

/* compile with:
cc -g -Wall -o addresses addresses.m
*/

#import <sys/types.h>   // random types
#import <sys/socket.h>  // for AF_INET
#import <netinet/in.h>  // constants and types
#import <arpa/inet.h>   // for inet_ntoa and friends
#import <stdlib.h>      // for EXIT_SUCCESS
#import <stdio.h>       // for fprintf
#import <unistd.h>      // for hostname
#import <sys/param.h>   // for MAXHOSTNAMELEN
#import <errno.h>       // for errno
#import <string.h>      // for strerror
#import <netdb.h>       // for gethostbyname

int main (int argc, char *argv[])
{
    struct in_addr address;
    const char *asciiAddress = "127.0.0.2";
    const char *translatedAddress;

    // convert to and from an ascii dotted quad

    if (inet_aton(asciiAddress, &address) != 1) {
        fprintf (stderr, "could not inet_aton '%s'\n", asciiAddress);
    } else {
        printf ("address value of %s is %x\n", asciiAddress, 
                address.s_addr);
    }

    translatedAddress = inet_ntoa (address);
    printf ("and translated back is '%s'\n", translatedAddress);

    // see what our hostname is
    {
        char hostname[MAXHOSTNAMELEN];
        if (gethostname(hostname, MAXHOSTNAMELEN) == -1) {
            fprintf (stderr, "error getting hostname. Error is %d / %s\n",
                     errno, strerror(errno));
        } else {
            printf ("our hostname is '%s'\n", hostname);
        }
    }

    // look up host names
    {
        struct hostent *hostinfo;

        hostinfo = gethostbyname ("www.apple.com");
        if (hostinfo == NULL) {
            fprintf (stderr, 
                     "error wtih gethostbyname / apple. Error %s\n",
                     hstrerror(h_errno));
        } else {
            char **scan;

            printf ("gethostbyname www.apple.com\n");
            printf ("    official name: %s\n", hostinfo->h_name);

            if (hostinfo->h_aliases[0] != NULL) {
                scan = hostinfo->h_aliases;
                printf ("    aliases:\n");
                while (*scan != NULL) {
                    printf ("        %s\n", *scan);
                    scan++;
                }
            } else {
                printf ("    no aliases\n");
            }

            printf ("    h_addrtype: %d (%s)\n", 
                    hostinfo->h_addrtype,
                    (hostinfo->h_addrtype == AF_INET) 
                        ? "AF_INET" : "unknown");

            if (hostinfo->h_addr_list[0] != NULL) {
                printf ("    addresses:\n");

                scan = hostinfo->h_addr_list;

                while (*scan != NULL) {
                    printf ("        %s\n", 
                            inet_ntoa(*((struct in_addr *)*scan)));
                    scan++;
                }
            } else {
                printf ("    no addresses\n");
            }
        }
    }

    exit (EXIT_SUCCESS);

} // main
