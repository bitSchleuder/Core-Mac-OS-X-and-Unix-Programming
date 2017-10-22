#import "ChatterServer.h"
#import "ChatterServing.h"
#import "ConnectionMonitor.h"
#include <sys/socket.h>

#import <Foundation/Foundation.h>

int main (int argc, const char * argv[]) {
    NSSocketPort *receivePort;
    NSConnection *connection;

    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    NSRunLoop *runloop = [NSRunLoop currentRunLoop];
    ConnectionMonitor *monitor = [[ConnectionMonitor alloc] init];
    ChatterServer *chatterServer = [[ChatterServer alloc] init];

    // Magic fix for socketPort/host leaks!
    if ([NSHost respondsToSelector:@selector(_fixNSHostLeak)]) {
        [NSHost _fixNSHostLeak];
    }
    if ([NSSocketPort respondsToSelector:
                             @selector(_fixNSSocketPortLeak)]) {
        [NSSocketPort _fixNSSocketPortLeak];
    }

    NS_DURING
        // This server will wait for requests on port 8081
        receivePort = [[NSSocketPort alloc] initWithTCPPort:8081];
    NS_HANDLER
        NSLog(@"unable to get port 8081");
        exit(-1);
    NS_ENDHANDLER

    // Create the connection object
    connection = [NSConnection connectionWithReceivePort:receivePort 
                                                sendPort:nil];

    // The port is retained by the connection
    [receivePort release];

    // When clients use this connection, they will 
    // talk to the ChatterServer
    [connection setRootObject:chatterServer];

    // The chatter server is retained by the connection
    [chatterServer release];

    // Set up the monitor object
    [connection setDelegate:monitor];
    [[NSNotificationCenter defaultCenter] addObserver:monitor 
              selector:@selector(connectionDidDie:) 
                  name:NSConnectionDidDieNotification 
                object:nil];

    // Start the runloop
    [runloop run];      

    // If the run loop exits (and I do not know why it would), cleanup
    [connection release];
    [monitor release];
    [pool release];
    return 0;
}
