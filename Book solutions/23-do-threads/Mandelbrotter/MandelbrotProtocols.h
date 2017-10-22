#include <Cocoa/Cocoa.h>

// There are two protocols:  
//    one the MandelbrotServer conforms to
//    another the MandelbrotView conforms to

@protocol MandelbrotServerMethods

- (oneway void)fill:(unsigned long)buffer 	
        minX:(float)minX minY:(float)minY 
        maxX:(float)maxX maxY:(float)maxY 
        width:(int)w height:(int)h;
@end

@protocol MandelbrotClientMethods
- (oneway void)serverIsDone;
- (void)addServer:(id)newServer;
@end