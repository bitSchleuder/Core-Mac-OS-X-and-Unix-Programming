#import <Cocoa/Cocoa.h>
#import <SystemConfiguration/SystemConfiguration.h>

@interface AppController : NSObject
{
    IBOutlet    NSTextField     *hostnameField;
    IBOutlet    NSTextField     *consoleUserField;
    IBOutlet    NSTextField     *localIPField;

    SCDynamicStoreRef   dynamicStore;
}

- (void)refreshUI;

- (NSString *)hostname;
- (NSString *)consoleUser;
- (NSString *)localIPs;

@end // AppController
