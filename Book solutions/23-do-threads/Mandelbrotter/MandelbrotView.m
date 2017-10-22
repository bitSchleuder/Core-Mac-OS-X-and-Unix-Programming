#import "MandelbrotView.h"
#import "MandelbrotServer.h"
#define SERVER_COUNT 4
#define READY 15

@implementation MandelbrotView

- (id)initWithFrame:(NSRect)frameRect
{
    [super initWithFrame:frameRect];
    
    // Create an retain an array to hold the servers
    servers = [[NSMutableArray alloc] init];
    imageRep = nil;
    
    // Start with a nice high-level view of the set
    region = NSMakeRect(-2.0, -1.2, 3, 2.4);
    return self;
}

- (void)awakeFromNib
{
    int i;
    
    // Create the servers
    for (i = 0; i < SERVER_COUNT; i++) {
        [self createServer];
    }
}

- (void)createServer
{
    NSPort *port1;
    NSPort *port2;
    NSArray *portArray;
    NSConnection *clientConnection;
    
    // Create two ports (one incoming, one out)
    port1 = [NSPort port];
    port2 = [NSPort port];

    // Create an NSConnection on this end
    clientConnection = [[NSConnection alloc] initWithReceivePort:port1
                sendPort:port2];
                
    [clientConnection setRootObject:self];

    portArray = [NSArray arrayWithObjects:port2, port1, nil];

    // Create a new thread and send a message in the new thread
    [NSThread detachNewThreadSelector:@selector(connectWithPorts:)
                toTarget:[MandelbrotServer class] withObject:portArray];
}

// This method will be called by the server via DO.
// anObject is really an NSProxy
- (void)addServer:(id)anObject
{
    fprintf(stderr, "added a server\n");
    [anObject setProtocolForProxy:@protocol(MandelbrotServerMethods)];
    [servers addObject:anObject];
    
    // If all the servers are created,  generate the image
    if ([servers count] == SERVER_COUNT) {
        [self refreshImage:nil];
    }
}

- (void)drawRect:(NSRect)rect
{
    NSRect bounds = [self bounds];
    
    // Draw a white background
    [[NSColor whiteColor] set];
    [NSBezierPath fillRect:bounds];
    
    // If the image is ready,  draw it.
    if (serversThatAreDone == SERVER_COUNT) {
        [imageRep draw];
    }
    
    // If the user is dragging,  show the selected rect
    if (dragging) {
        NSRect box = [self selectedRect];
        [[NSColor redColor] set];
        [NSBezierPath strokeRect:box];
    }

}

- (IBAction)refreshImage:(id)sender
{
    unsigned long rowsPerServer;
    float maxY, maxX, deltaY;
    int i;
    unsigned char *ptr;
    [progressTextField setStringValue:@"Computation starting"];
    [refreshButton setEnabled:NO];
    
    // Clear the serversThatAreDone to show that none of the servers are done
    serversThatAreDone = 0;
    NSRect bounds = [self bounds];
    int pixelsHigh = bounds.size.height;
    int pixelsWide = bounds.size.width;
    
    // The image maybe a few pixels shorter than the view.
    // Benefit:  all servers draw the same number of rows.
    int remainder = pixelsHigh % SERVER_COUNT;
    pixelsHigh = pixelsHigh - remainder;
    rowsPerServer = pixelsHigh / SERVER_COUNT;
    
    fprintf(stderr, "Image will be %d x %d\n", pixelsWide, pixelsHigh);
    [imageRep release];
    
    // Create the image rep the servers will draw on
    imageRep = [[NSBitmapImageRep alloc] 
                    initWithBitmapDataPlanes:NULL
                    pixelsWide:pixelsWide
                    pixelsHigh:pixelsHigh
                    bitsPerSample:8 
                    samplesPerPixel:3
                    hasAlpha:NO
                    isPlanar:NO
                    colorSpaceName:NSCalibratedRGBColorSpace
                    bytesPerRow:NULL 
                    bitsPerPixel:NULL];
                    
    // Get the pointer to the raw data
    ptr = [imageRep bitmapData];
    maxY = NSMaxY(region);
    maxX = NSMaxX(region);
    deltaY = region.size.height / SERVER_COUNT;
    
    // Ask each server to draw a set of rows.
    for (i = 0; i < SERVER_COUNT; i++){
        // Assign a region to the server
        [[servers objectAtIndex:i] fill:(unsigned long)ptr 
            minX:region.origin.x minY:maxY - deltaY 
            maxX:maxX maxY:maxY width:pixelsWide height:rowsPerServer];
        
        // Move down the image
        maxY = maxY - deltaY;
        
        // Move jump to next region in bitmapData
        ptr = ptr + (pixelsWide * rowsPerServer * 3);
    }
    [progressTextField setStringValue:@"Computation started"];
}

- (oneway void)serverIsDone
{
    serversThatAreDone++;
    [progressTextField setIntValue:serversThatAreDone];
    fprintf(stderr, "%d servers are done\n",serversThatAreDone);
    if (serversThatAreDone == SERVER_COUNT) {
        [progressTextField setStringValue:@"Computation complete"];
        [refreshButton setEnabled:YES];
        [self setNeedsDisplay:YES];
    }
}

- (void)mouseDown:(NSEvent *)event
{
    // Ignore drags while servers are working
    if (serversThatAreDone == SERVER_COUNT) {
        dragging = YES;
        NSPoint p = [event locationInWindow];
        downPoint = [self convertPoint:p  fromView:nil];
        currentPoint = downPoint;
    }
}
- (void)mouseDragged:(NSEvent *)event
{
    if (dragging) {
        NSPoint p = [event locationInWindow];
        currentPoint = [self convertPoint:p  fromView:nil];
        [self setNeedsDisplay:YES];
    }
}
- (void)mouseUp:(NSEvent *)event
{
    NSRect r, bounds;
    NSRect newRegion;
    if (dragging) {
        dragging = NO;
        NSPoint p = [event locationInWindow];
        currentPoint = [self convertPoint:p  fromView:nil];
        bounds = [self bounds];
        r = [self selectedRect];
        
        // Calculate newRegion as if in the unit square
        newRegion.origin.x = r.origin.x / bounds.size.width;
        newRegion.origin.y = r.origin.y / bounds.size.height;
        newRegion.size.width = r.size.width /bounds.size.width;
        newRegion.size.height = r.size.height / bounds.size.height;

        // Scale to region's size
        newRegion.origin.x = region.origin.x + newRegion.origin.x * region.size.width;
        newRegion.origin.y = region.origin.y + newRegion.origin.y * region.size.height;
        newRegion.size.width = region.size.width * newRegion.size.width;
        newRegion.size.height = region.size.height * newRegion.size.height;
        region = newRegion;
        [self refreshImage:nil];
    }
}

- (NSRect)selectedRect
{
    float minX = MIN(downPoint.x, currentPoint.x);
    float maxX = MAX(downPoint.x, currentPoint.x);
    float minY = MIN(downPoint.y, currentPoint.y);
    float maxY = MAX(downPoint.y, currentPoint.y);

    return NSMakeRect(minX, minY, maxX-minX,  maxY-minY);
}

@end
