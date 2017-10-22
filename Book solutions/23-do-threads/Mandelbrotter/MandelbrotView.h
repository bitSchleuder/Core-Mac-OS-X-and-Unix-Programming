/* MandelbrotView */
#import <Cocoa/Cocoa.h>
#import "MandelbrotProtocols.h"

@class MandelbrotServer;

@interface MandelbrotView : NSView <MandelbrotClientMethods>
{
    // The array of Mandelbrot servers
    NSMutableArray *servers;
    
    // The imageRep that is displayed
    NSBitmapImageRep *imageRep;
    
    // The bitmask which determines if all the servers
    // are done with their work
    int serversThatAreDone;
    
    // UI stuff
    IBOutlet NSTextField *progressTextField;
    IBOutlet NSButton *refreshButton;
    
    // Stuff to deal with selecting regions
    NSRect region;
    BOOL dragging;
    NSPoint downPoint, currentPoint;
}

- (id)initWithFrame:(NSRect)rect;
- (void)createServer;
- (IBAction)refreshImage:(id)sender;
- (NSRect)selectedRect;
@end
