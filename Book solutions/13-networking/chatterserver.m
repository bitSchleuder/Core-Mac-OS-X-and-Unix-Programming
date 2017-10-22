// chatterserver.m -- chat server using standard sockets API

/* compile with:
cc -g -Wall -o chatterserver chatterserver.m
*/

#import <sys/types.h>   // random types
#import <netinet/in.h>  // for sockaddr_in
#import <sys/socket.h>  // for socket(), AF_INET
#import <arpa/inet.h>   // for inet_ntoa
#import <errno.h>       // for errno
#import <string.h>      // for strerror
#import <stdlib.h>      // for EXIT_SUCCESS
#import <stdio.h>       // for fprintf
#import <unistd.h>      // for close
#import <arpa/inet.h>   // for inet_ntoa and friends
#import <fcntl.h>       // for fcntl()
#import <syslog.h>      // for syslog and friends
#import <sys/uio.h>     // for iovec

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
#define MAX_MESSAGE_SIZE        256
#define READ_BUFFER_SIZE        4096

// there is one of these for each connected user

typedef struct chatterUser {
    int         fd;             // zero fd == no user
    char        username[9];    // 8 character name plus trailing zero byte
    int         gotNickname;    // have we gotten the nickname packet?

    // incoming data workspace

    // what the length byte says we should get
    unsigned int currentMessageSize;

    // what we have read (not including length)
    int         bytesRead;         
    char        buffer[READ_BUFFER_SIZE];
} chatterUser;

#define MAX_USERS 50
chatterUser g_users[MAX_USERS];

#define PORT_NUMBER 2342

int g_listenFd;

// returns fd on success, -1 on error
// (this is cut-and-paste from main() of simpleserver.m)

int startListening ()
{
    int fd = -1, success = 0;
    int result;

    // cut and pasted from main() in simpleserver.m

    result = socket (AF_INET, SOCK_STREAM, 0);
    
    if (result == -1) {
        fprintf (stderr, "could not make a scoket.  error: %d / %s\n",
                 errno, strerror(errno));
        goto bailout;
    }
    fd = result;

    {
        int yes = 1;
        result = setsockopt (fd, SOL_SOCKET, SO_REUSEADDR, 
                             &yes, sizeof(int));
        if (result == -1) {
            fprintf (stderr, 
                 "unable to setsockopt to reuse address. %d / %s\n",
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

    success = 1;

bailout:
    if (!success) {
        close (fd);
        fd = -1;
    }

    return (fd);

} // startListening

// our listening socket appeared in a readfd from select.  That means
// there is a connection there we can accept

void acceptConnection (int listenFd)
{
    struct sockaddr_in address;
    int addressLength = sizeof(address), result, fd, i;
    chatterUser *newUser = NULL;
    
    result = accept (g_listenFd, (struct sockaddr *)&address, 
                     &addressLength);

    if (result == -1) {
        fprintf (stderr, "accept failed.  error: %d / %s\n",
                 errno, strerror(errno));
        goto bailout;
    }
    fd = result;

    // set to non-blocking
    result = fcntl (fd, F_SETFL, O_NONBLOCK);
    if (result == -1) {
        fprintf (stderr, "setting nonblock failed.  error: %d / %s\n",
                 errno, strerror(errno));
        goto bailout;
    }

    // find the next free spot in the users array
    for (i = 0; i < MAX_USERS; i++) {
        if (g_users[i].fd == 0) {
            // found it
            newUser = &g_users[i];
            break;
        }
    }

    if (newUser == NULL) {
        const char *gripe = "too many users.  try again later";
        write (fd, gripe, strlen(gripe));
        goto bailout;
    }

    // ok, clear out the structure, and get it set up
    memset (newUser, 0, sizeof(chatterUser));

    newUser->fd = fd;

    // log where the connection is from

    syslog (LOG_NOTICE, "accepted connection from IP '%s' for fd %d",
            inet_ntoa (address.sin_addr), fd);
bailout:
    return;
    
} // acceptConnection


// send a message to all the signed-in users

void broadcastMessage (const char *username, const char *message)
{
    chatterUser *scan, *stop;  // use a pointer chase for fun
    struct iovec iovector[4];  // use scattered writes just for fun too
    const char *seperator = ": ";

    printf ("Broadcast message: %s: %s\n", username, message);

    scan = g_users;
    stop = scan + MAX_USERS;
    
    while (scan < stop) {
        if (scan->fd != 0) {
            iovector[0].iov_base = (char *)username;
            iovector[0].iov_len = strlen (username);
            iovector[1].iov_base = (char *)seperator;
            iovector[1].iov_len = strlen (seperator);
            iovector[2].iov_base = (char *)message;
            iovector[2].iov_len = strlen (message);

            writev (scan->fd, iovector, 3);
        }
        scan++;
    }

} // broadcastMessage

// user disconnected.  Do any mop-up

void cleanUpUser (chatterUser *user)
{
    syslog (LOG_NOTICE, "disconnected user on fd %d\n", user->fd);

    // broadcast 'user disconnected' message
    close (user->fd);
    user->fd = 0;

    broadcastMessage (user->username, "has left the channel\n");

} // cleanUpUser

// the first packet is the user's nickname.  Get it

void readNickname (chatterUser *user)
{
    int result;

    // see if we have read anything yet
    if (user->currentMessageSize == 0) {
        unsigned char length;
        // we need to get the size

        result = read (user->fd, &length, 1);

        if (result == 1) {
            // we got our length byte
            user->currentMessageSize = length;
            user->bytesRead = 0;

        } else if (result == 0) {
            // end of file
            cleanUpUser (user);
            goto bailout;

        } else if (result == -1) {
            fprintf (stderr, "error reading.  error is %d / %s\n",
                     errno, strerror(errno));
            cleanUpUser (user);
            goto bailout;
        }

    } else {
        int readLeft;

        // ok, try to read just the rest of the nickname
        readLeft = user->currentMessageSize - user->bytesRead;

        result = read (user->fd, user->buffer + user->bytesRead,
                       readLeft);
        
        if (result == readLeft) {
            // have the whole nickname
            memcpy (user->username, user->buffer, 
                    user->currentMessageSize);
            user->username[user->currentMessageSize] = '\000';
            printf ("have a nickname! %s\n", user->username);
            user->gotNickname = 1;

            // no current message, so clear it out
            user->currentMessageSize = 0;

            syslog (LOG_NOTICE, "nickname for fd %d is %s", 
                    user->fd, user->username);
            broadcastMessage (user->username, "has joined the channel\n");

        } else if (result == 0) {
            // other side closed the connection
            cleanUpUser (user);
            goto bailout;

        } else if (result == -1) {
            fprintf (stderr, "error reading.  error is %d / %s\n",
                     errno, strerror(errno));
            cleanUpUser (user);
            goto bailout;

        } else {
            // did not read all of it
            user->bytesRead += result;
        }
    }

bailout:
    return;

} // readNickname

// get message data from the given user

void readMessage (chatterUser *user)
{
    int result;
    char *scan, messageBuffer[MAX_MESSAGE_SIZE + 1];

    // read as much as we can into the buffer
    result = read (user->fd, user->buffer, 
                   READ_BUFFER_SIZE - user->bytesRead);

    if (result == 0) {
        // other side closed
        cleanUpUser (user);
        // ok to skip message sending, since we have sent all complete
        // messages already
        goto bailout;

    } if (result == -1) {
        fprintf (stderr, "error reading.  error %d / %s\n",
                 errno, strerror(errno));
        goto bailout;

    } else {
        user->bytesRead += result;
    }

    // now see if we have any complete messages we can send out to
    // other folks the beginning of the buffer should have the length
    // byte, plus any subsequent message bytes

    scan = user->buffer;

    while (user->bytesRead > 0) {

        if (user->currentMessageSize == 0) {
            // start processing new message
            user->currentMessageSize = (unsigned char)*scan++;
            user->bytesRead--;
        }

        if (user->bytesRead >= user->currentMessageSize) {
            // we have a complete message
            memcpy (messageBuffer, scan, user->currentMessageSize);
            messageBuffer[user->currentMessageSize] = '\000';
            user->bytesRead -= user->currentMessageSize;
            scan += user->currentMessageSize;
            
            // slide the rest of the data over
            memmove (user->buffer, scan, user->bytesRead);
            scan = user->buffer;

            broadcastMessage (user->username, messageBuffer);

            // done with this message
            user->currentMessageSize = 0;
        } else {
            break;
        }
    }

bailout:
    return;

} // readMessage

// we got read activity for a user

void handleRead (chatterUser *user)
{
    if (!user->gotNickname) {
        readNickname (user);
    } else {
        readMessage (user);
    }

} // handleRead

int main (int argc, char *argv[])
{
    int programResult = EXIT_FAILURE;
    g_listenFd = startListening ();

    if (g_listenFd == -1) {
        fprintf (stderr, "could not open listening socket\n");
        goto bailout;
    }

    // block SIGPIPE
    signal (SIGPIPE, SIG_IGN);

    // wait for activity
    while (1) {
        fd_set readfds;
        int maxFd = -1, result, i;
        
        FD_ZERO (&readfds);

        // add our listen socket
        FD_SET (g_listenFd, &readfds);
        maxFd = MAX (maxFd, g_listenFd);

        // add our users;
        for (i = 0; i < MAX_USERS; i++) {
            if (g_users[i].fd != 0) {
                FD_SET (g_users[i].fd, &readfds);
                maxFd = MAX (maxFd, g_users[i].fd);
            }
        }


        // wait until something interesting happens
        result = select (maxFd + 1, &readfds, NULL, NULL, NULL);

        if (result == -1) {
            fprintf (stderr, "error from select(): error %d / %s\n",
                     errno, strerror(errno));
            continue;
        }

        // see if we have a new user
        if (FD_ISSET (g_listenFd, &readfds)) {
            acceptConnection (g_listenFd);
        }

        // handle any new incoming data from the users.
        // closes appear here too.
        for (i = 0; i < MAX_USERS; i++) {
            if (FD_ISSET(g_users[i].fd, &readfds)) {
                handleRead (&g_users[i]);
            }
        }
    }
    
    programResult = EXIT_SUCCESS;

bailout:
    return (programResult);

} // main
