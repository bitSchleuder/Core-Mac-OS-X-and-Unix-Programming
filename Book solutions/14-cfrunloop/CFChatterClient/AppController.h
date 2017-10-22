#import <Cocoa/Cocoa.h>

@interface AppController : NSObject
{
    IBOutlet    NSTextField     *hostField;
    IBOutlet    NSTextField     *messageField;
    IBOutlet    NSTextField     *nicknameField;
    IBOutlet    NSTextView      *textView;
                int              serverSocket;
                CFSocketRef      runLoopSocket;
} 

- (IBAction)sendMessage:(id)sender;
- (IBAction)subscribe:(id)sender;
- (IBAction)unsubscribe:(id)sender;

@end // AppController
