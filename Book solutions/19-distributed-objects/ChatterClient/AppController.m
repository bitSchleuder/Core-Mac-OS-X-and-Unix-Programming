#import "AppController.h"

@implementation AppController

// Private method to clean up connection and proxy
// Seems to be leaking NSSocketPorts
- (void)cleanup
{
    NSConnection *connection = [proxy connectionForProxy];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [connection invalidate];
    [proxy release];
    proxy = nil;
}

// Show message coming in from server
- (oneway void)showMessage:(in bycopy NSString *)message 
    fromNickname:(in bycopy NSString *)n
{
    NSString *string = [NSString stringWithFormat:@"%@ says, \"%@\"\n", 
                                                             n, message];
    NSTextStorage *currentContents = [textView textStorage];
    NSRange range = NSMakeRange([currentContents length], 0);
    [currentContents replaceCharactersInRange:range withString:string];
    range.length = [string length];
    [textView scrollRangeToVisible:range];
    // Beep to get user's attention
    NSBeep();
}

// Accessors
- (bycopy NSString *)nickname
{
    return nickname;
}

- (void)setNickname:(NSString *)s
{
    [s retain];
    [nickname release];
    nickname = s;
}

- (void)setServerHostname:(NSString *)s
{
    [s retain];
    [serverHostname release];
    serverHostname = s;
}

// Connect to the server
- (void)connect
{
    BOOL successful;
    NSConnection *connection;
    NSSocketPort *sendPort;

    // Create the send port
    sendPort = [[NSSocketPort alloc] initRemoteWithTCPPort:8081 
                                              host:serverHostname];

    // Create an NSConnection
    connection = [NSConnection connectionWithReceivePort:nil 
                                                sendPort:sendPort];
    
    // Set timeouts to something reasonable
    [connection setRequestTimeout:10.0];
    [connection setReplyTimeout:10.0];

    // The send port is retained by the connection
    [sendPort release];
           
    NS_DURING
        // Get the proxy
        proxy = [[connection rootProxy] retain];

        // Get informed when the connection fails
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                 selector:@selector(connectionDown:) 
                                     name:NSConnectionDidDieNotification 
                                   object:connection];

        // By telling the proxy about the protocol for the object 
        // it represents, we significantly reduce the network 
        // traffic involved in each invocation
        [proxy setProtocolForProxy:@protocol(ChatterServing)];

        // Try to subscribe with chosen nickname
        successful = [proxy subscribeClient:self];
        if (successful) {
            [messageField setStringValue:@"Connected"];
        } else {
            [messageField setStringValue:@"Nickname not available"];
            [self cleanup];
        }
    NS_HANDLER
        // If the server does not respond in 10 seconds,  
        // this handler will get called
        [messageField setStringValue:@"Unable to connect"];
        [self cleanup];
    NS_ENDHANDLER
}

// Read hostname and nickname then connect
- (IBAction)subscribe:(id)sender
{
    // Is the user already subscribed?
    if (proxy) {
        [messageField setStringValue:@"unsubscribe first!"];
    } else {
        // Read the hostname and nickname from UI
        [self setServerHostname:[hostField stringValue]];
        [self setNickname:[nicknameField stringValue]];

        // Connect
        [self connect];
    }
}

- (IBAction)sendMessage:(id)sender
{
    NSString *inString;

    // If there is no proxy,  try to connect.
    if (!proxy) {
        [self connect];
        // If there is still no proxy, bail
        if (!proxy){
            return;
        }
    }
    
    // Read the message from the text field
    inString = [messageField stringValue];
    NS_DURING
        // Send a message to the server
        [proxy sendMessage:inString fromClient:self];
    NS_HANDLER
        // If something goes wrong
        [messageField setStringValue:@"The connection is down"];
        [self cleanup];
    NS_ENDHANDLER
}

- (IBAction)unsubscribe:(id)sender
{
    NS_DURING
        [proxy unsubscribeClient:self];
        [messageField setStringValue:@"Unsubscribed"];
        [self cleanup];
    NS_HANDLER
        [messageField setStringValue:@"Error unsubscribing"];
    NS_ENDHANDLER
}

// Delegate methods

//  If the connection goes down,  do cleanup
- (void)connectionDown:(NSNotification *)note
{
    NSLog(@"connectionDown:");
    [messageField setStringValue:@"connection down"];
    [self cleanup];
}

// If the app terminates,  unsubscribe.
- (NSApplicationTerminateReply)applicationShouldTerminate:
                                        (NSApplication *)app
{
    NSLog(@"invalidating connection");
    if (proxy) {
        [proxy unsubscribeClient:self];
        [[proxy connectionForProxy] invalidate];
    }
    return NSTerminateNow;
}

- (void)dealloc
{
    [self cleanup];
    [super dealloc];
}

@end
