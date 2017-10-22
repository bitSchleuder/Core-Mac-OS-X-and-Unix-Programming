#import <Cocoa/Cocoa.h>
#import "ChatterServing.h"

@interface AppController : NSObject <ChatterUsing>
{
    IBOutlet NSTextField *hostField;
    IBOutlet NSTextField *messageField;
    IBOutlet NSTextField *nicknameField;
    IBOutlet NSTextView *textView;
    NSString *nickname;
    NSString *serverHostname;
    id proxy;
}
- (IBAction)sendMessage:(id)sender;
- (IBAction)subscribe:(id)sender;
- (IBAction)unsubscribe:(id)sender;
@end
