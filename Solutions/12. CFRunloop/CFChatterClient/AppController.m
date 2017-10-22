#import "AppController.h"

#import <sys/types.h>	// random types
#import <netinet/in.h>	// for sockaddr_in
#import <sys/socket.h>	// for socket(), AF_INET
#import <netdb.h>	// for gethostbyname, h_errno, etc
#import <errno.h>	// for errno
#import <string.h>	// for strerror
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

} // writeString


typedef struct observerActivities {
    int		activity;
    const char *name;
} observerActivities;

observerActivities g_activities[] = {
    { kCFRunLoopEntry, 		"Run Loop Entry" },
    { kCFRunLoopBeforeTimers, 	"Before Timers" },
    { kCFRunLoopBeforeSources,	"Before Sources" },
    { kCFRunLoopBeforeWaiting,	"Before Waiting" },
    { kCFRunLoopAfterWaiting,	"After Waiting" },
    { kCFRunLoopExit, 		"Exit" }
};

void observerCallback (CFRunLoopObserverRef observer, CFRunLoopActivity activity,
		       void *info)
{
    observerActivities *scan, *stop;

    scan = g_activities;
    stop = scan + (sizeof(g_activities) / sizeof(observerActivities));

    while (scan < stop) {
	if (scan->activity == activity) {
	    NSLog (@"%s", scan->name);
	    break;
	}
	scan++;
    }

} // observerCallback
		       


void addRunLoopObserver ()
{
    CFRunLoopRef rl;
    CFRunLoopObserverRef observer;

    rl = CFRunLoopGetCurrent ();

    observer = CFRunLoopObserverCreate (NULL, // allocator
					kCFRunLoopAllActivities, // activites
					1, // repeats
					0, // order
					observerCallback,
					NULL); // context

    CFRunLoopAddObserver (rl, observer, kCFRunLoopDefaultMode);

    CFRelease (observer);

} // addRunLoopObserver


@implementation AppController


- (id) init
{
    if (self = [super init]) {
	serverSocket = -1;
    }

    // addRunLoopObserver ();
    
    return (self);

} // init



- (void) updateUI
{
    // enable the message field if we're connected
    [messageField setEnabled: (runLoopSocket != NULL)];

} // updateUI



- (void) awakeFromNib
{
    [nicknameField setStringValue: NSUserName ()];
    [self updateUI];
} // awakeFromNib



- (void) closeConnection
{
    if (runLoopSocket != NULL) {
	CFSocketInvalidate (runLoopSocket);
	CFRelease (runLoopSocket);
    } else {
	close (serverSocket);
    }
    serverSocket = -1;
    runLoopSocket = NULL;

    [self updateUI];

} // closeConnection



- (void) dealloc
{
    [self closeConnection];
    [super dealloc];
} // dealloc



- (void) showErrorMessage: (NSString *) message  sysError: (const char *) string
{
    NSString *errnoString = @"";

    if (string != NULL) {
	errnoString = [[NSString alloc] initWithCString: string];
	[errnoString autorelease];
    }

    (void) NSRunAlertPanel (message, errnoString, @"OK", nil, nil);

} // showErrorMessage



- (IBAction) sendMessage: (id) sender
{
    if (serverSocket != -1) {
	NSString *messageString;
	const char *message;
	unsigned char length;
	int result;

	// need to add a newline to match behavior of the command-line client
	messageString = [[messageField stringValue] stringByAppendingString: @"\n"];

	message = [messageString cString];
	length = strlen (message);

	if (length > 1) {
	    
	    result = writeString (serverSocket, message, length);
	    
	    if (result == -1) {
		NSLog (@"error writing: %s\n", strerror(errno));
	    }
	    [messageField setStringValue: @""];
	}
    }

} // sendMessage



- (void) appendMessageAndScrollToEnd: (NSString *) string
{
    NSRange range;
    range = NSMakeRange ([[textView string] length], 0);

    [textView replaceCharactersInRange: range withString: string];

    range = NSMakeRange ([[textView string] length],
			 [[textView string] length]);

    [textView scrollRangeToVisible: range];

} // appendMessageAndScrollToEnd



- (void) readFromSocket
{
    int result;
    char buffer[5000];

    result = read (serverSocket, buffer, 5000 - 1);

    if (result == 0) {
	// other side closed
	[self closeConnection];
	NSLog (@"other side closed connection");
	[self showErrorMessage: @"Server closed the connection" sysError: NULL];

    } else if (result == -1) {
	[self showErrorMessage: @"Error reading from server" 
	      sysError: strerror(errno)];

    } else {
	[self appendMessageAndScrollToEnd: [NSString stringWithCString: buffer
						     length: result]];
    }

} // readFromSocket



void socketCallBack (CFSocketRef socketref, CFSocketCallBackType type,
		     CFDataRef address, const void *data, void *info)
{
    AppController *me = (AppController *) info;

    [me readFromSocket];

} // socketCallBack



- (void) addSocketMonitor
{
    CFSocketContext context = { 0, self, NULL, NULL, NULL };
    CFRunLoopSourceRef rls;

    runLoopSocket = CFSocketCreateWithNative (NULL,
					      serverSocket,
					      kCFSocketReadCallBack,
					      socketCallBack,
					      &context);
    if (runLoopSocket == NULL) {
	// something went wrong
	[self showErrorMessage: @"could not CFSocketCreateWithNative"
	      sysError: NULL];
	goto bailout;
    }

    rls = CFSocketCreateRunLoopSource (NULL, runLoopSocket, 0);
    if (rls == NULL) {
	[self showErrorMessage: @"could not create a run loop source"
	      sysError: NULL];
	goto bailout;
    }

    CFRunLoopAddSource (CFRunLoopGetCurrent(), rls,
			kCFRunLoopDefaultMode);
    CFRelease (rls);

bailout:
    return;
    

} // addSocketMonitor



- (IBAction) subscribe: (id) sender
{
    NSString *errorMessage = nil;
    char *sysError = NULL;
    int result;
    struct sockaddr_in serverAddress;


    if (serverSocket != -1) {
	[self closeConnection];
    }

    // sanity check our nick name before trying to connect
    if ([[nicknameField stringValue] length] == 0 ||
	[[nicknameField stringValue] length] > 8) {
	errorMessage = @"Nickname should be between 1 and 8 characters long";
	goto bailout;
    }

    {
	struct hostent *hostInfo;
	const char *hostname = [[hostField stringValue] cString];

	hostInfo = gethostbyname (hostname);
	if (hostInfo == NULL) {
	    errorMessage = [NSString stringWithFormat: @"Could not resolve host '%s'", hostname];
	    sysError = hstrerror(h_errno);
	    goto bailout;
	}
	
	serverAddress.sin_len = sizeof (struct sockaddr_in);
	serverAddress.sin_family = AF_INET;
	serverAddress.sin_port = htons (PORT_NUMBER);
	serverAddress.sin_addr = *((struct in_addr *)(hostInfo->h_addr));
	memset (&(serverAddress.sin_zero), 0, sizeof(serverAddress.sin_zero));
    }

    serverSocket = socket (AF_INET, SOCK_STREAM, 0);

    if (serverSocket == -1) {
	errorMessage = @"Could not create server socket.  Error is %s.";
	sysError = strerror (errno);
	goto bailout;
    }

    result = connect (serverSocket, (struct sockaddr *)&serverAddress, 
		      sizeof(serverAddress));
    if (result == -1) {
	errorMessage = @"could not connect to server";
	sysError = strerror (errno);
	goto bailout;
    }
    

    // write out the nickname
    {
	const char *nickname;
	unsigned char length;
	nickname = [[nicknameField stringValue] cString];
	length = strlen (nickname);

	result = write (serverSocket, &length, 1);
	if (result == -1) {
	    errorMessage = @"Could not write nickname length";
	    sysError = strerror (errno);
	    goto bailout;
	}
	result = write (serverSocket, nickname, length);
	if (result == -1) {
	    errorMessage = @"could not write nickname.";
	    sysError = strerror (errno);
	    goto bailout;
	}
    }
    
    // set the serverSocket to non-blocking
    result = fcntl (serverSocket, F_SETFL, O_NONBLOCK);
    if (result == -1) {
	errorMessage = @"Could not set serverSocket to nonblocking mode.";
	sysError = strerror(errno);
	goto bailout;
    }

    // yay!  We're done.
    [self addSocketMonitor];

bailout:
    if (errorMessage != nil) {
	[self showErrorMessage: errorMessage  sysError: sysError];
	[self closeConnection];
    }

    [self updateUI];

    return;

} // subscribe


- (void) unsubscribe: (id) sender
{
    [self closeConnection];

} // unsubscribe


@end // AppController

