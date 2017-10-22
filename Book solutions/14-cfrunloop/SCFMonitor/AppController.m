#import "AppController.h"

// result is a dictionary with Name, UID, and GID keys
#define CONSOLE_USER_KEY        (CFSTR("State:/Users/ConsoleUser"))

// result is a dictionary with a LocalHostName key.
// For illustration, this uses the convenience API for dealing
// with hostnames.  Change this by tweaking the Rendezvous Name
// in the Sharing preferences
#define HOSTNAME_KEY            (SCDynamicStoreKeyCreateHostNames(NULL))

// match any IPv4 service.  The "[^/]+" part of the pattern means
// "match one or more characters that are not slashes"
#define IP_PATTERN (CFSTR("State:/Network/Service/[^/]+/IPv4"))

// gets called when the dynamic store changes

void storeCallback (SCDynamicStoreRef store, CFArrayRef changedKeys,
                    void *info)
{
    NSLog (@"storeCallback: changedKeys is %@", changedKeys);

    AppController *controller = (AppController *)info;

    [controller refreshUI];

} // storeCallback


@implementation AppController

- (NSString *) hostname
{
    CFStringRef hostname;

    hostname = SCDynamicStoreCopyLocalHostName (dynamicStore);

    return ((NSString *) hostname);

} // hostname

- (NSString *) consoleUser
{
    NSArray *keyList;
    keyList = 
        (NSArray *) SCDynamicStoreCopyKeyList (dynamicStore, 
                                               CONSOLE_USER_KEY);
    
    CFStringRef consoleValueKey;
    consoleValueKey = (CFStringRef)[keyList objectAtIndex:0];

    NSDictionary *consoleUserDict;
    consoleUserDict = 
        (NSDictionary *)SCDynamicStoreCopyValue (dynamicStore, 
                                                 consoleValueKey);

    NSMutableString *consoleUser;
    consoleUser = [[NSMutableString alloc] init];

    // make a string of the form "username (user-id, group-id)"
    [consoleUser appendString:[consoleUserDict objectForKey: @"Name"]];
    [consoleUser appendFormat:@" (%@, %@)",
                 [consoleUserDict objectForKey:@"UID"],
                 [consoleUserDict objectForKey:@"GID"]];

    return (consoleUser);
    
} // consoleUser

- (NSString *) localIPs
{
    NSMutableString *localIPs;

    localIPs = [[NSMutableString alloc] init];


    // make an array of stuff so we can use SCDynamicStoreCopyMultiple
    // and get a consistent snapshot, since there may be several IP 
    // addresses, rather than several calls to SCDynamicStoreCopyValue

    NSArray *patternList;
    patternList = [NSArray arrayWithObject:(NSString *)IP_PATTERN];

    NSDictionary *dictionary;
    dictionary = 
        (NSDictionary*)SCDynamicStoreCopyMultiple (dynamicStore, 
                            NULL,  // keys
                            (CFArrayRef)patternList);
    // now walk the dictionary.
    // the key is an identifier, like State:/Network/Service/5/IPv4
    // the value is another dictionary, which has a key of "Addresses"
    // that is an array strings, which are the actual IP addresses

    NSEnumerator *enumerator;
    enumerator = [dictionary keyEnumerator];
    
    NSString *key;
    while ((key = [enumerator nextObject])) {
        NSDictionary *oneConfig;
        oneConfig = [dictionary objectForKey: key];

        NSArray *addresses;
        addresses = [oneConfig objectForKey: @"Addresses"];
        
        // now walk the addresses
        NSEnumerator *addressesEnumerator;
        addressesEnumerator = [addresses objectEnumerator];

        NSString *address;
        while ((address = [addressesEnumerator nextObject])) {
            [localIPs appendString: address];
            [localIPs appendString: @" "];
        }
    }
    
    return (localIPs);

} // localIP

- (void) refreshUI
{
    [hostnameField setStringValue:[self hostname]];
    [consoleUserField setStringValue:[self consoleUser]];
    [localIPField setStringValue:[self localIPs]];

} // refreshUI

- (void) awakeFromNib
{
    // create the dynamic store
    SCDynamicStoreContext context = {
        0, self, NULL, NULL, NULL
    };

    dynamicStore = SCDynamicStoreCreate (NULL,                // allocator
                                         CFSTR("SCFMonitor"), // name
                                         storeCallback,       // callback
                                         &context);       // context
    if (dynamicStore == NULL) {
        NSLog (@"could not create dynamic store reference");
    }

    // what are we interested in receiving notifications about?
    NSArray *noteKeys, *notePatterns;

    noteKeys = [NSArray arrayWithObjects: 
                        (NSString *) HOSTNAME_KEY,
                        (NSString *) CONSOLE_USER_KEY,
                        nil];
    notePatterns = [NSArray arrayWithObject:
                                (NSString *) IP_PATTERN];
    // register those notifications
    if (!SCDynamicStoreSetNotificationKeys(dynamicStore,
                                           (CFArrayRef) noteKeys, 
                                           (CFArrayRef) notePatterns)) {
        NSLog (@"could not register notification keys");
    }

    // create a run loop source
    CFRunLoopSourceRef runLoopSource;
    
    runLoopSource = SCDynamicStoreCreateRunLoopSource (NULL, // allocator
                                                       dynamicStore,
                                                       0);   // order
    // stick it into the current runloop

    CFRunLoopRef runLoop = CFRunLoopGetCurrent ();
    CFRunLoopAddSource (runLoop, runLoopSource, kCFRunLoopDefaultMode);

    CFRelease (runLoopSource);

    [self refreshUI];
    
} // awakeFromNib

@end // AppController
