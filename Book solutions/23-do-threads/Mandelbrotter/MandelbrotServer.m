//
//  MandelbrotServer.m
//  Mandelbrotter
//
//  Created by Aaron Hillegass on Sat Oct 19 2002.
//  Copyright (c) 2002 Big Nerd Ranch. All rights reserved.
//

#import "MandelbrotServer.h"

// Functions for doing complex math

_complex addComplex(_complex a, _complex b)
{
    _complex result;
    result.Real = a.Real + b.Real;
    result.Imag = a.Imag + b.Imag;
    return result;
}

_complex multiplyComplex(_complex a, _complex b)
{
    _complex result;
    result.Real = a.Real * b.Real - a.Imag * b.Imag;
    result.Imag = a.Real * b.Imag + a.Imag * b.Real;
    return result;
}

// This determines what colors go with which values.
// I've set it up for a red scheme
void gradient(int value, unsigned char *buffer) {
    unsigned char *ptr = buffer;
    value = value * 4;
    if (value > 255) 
        value = 255;
    *ptr++ = value;  // Red
    *ptr++ = 0;      // Green
    *ptr = 0;        // Blue
}

// (x, y) is the point to be dealt with
// buffer is a pointer to the three bytes that will hold 
// the resulting color
void mandlebrot(double x, double y, unsigned char *buffer) {
    int i;
    _complex z,c;
 
    c.Real = x;
    c.Imag = y;
    z.Real = 0;
    z.Imag = 0;
    
    //fprintf(stderr, "%f, %f\n", x, y);
    for (i = 0; i < LOOP; i++) {
        z = addComplex(multiplyComplex(z, z),c);
        if ( cabs(z) > LIMIT) {
            gradient(i, buffer);
            return;
        }
    }
    gradient(0, buffer);
}

@implementation MandelbrotServer

// This is called when the new thread is created
+ (void)connectWithPorts:(NSArray *)portArray
{
    NSAutoreleasePool *pool;
    MandelbrotServer *serverObject;
    NSRunLoop *runLoop;
    NSConnection *serverConnection;
    id proxy;
	
    pool = [[NSAutoreleasePool alloc] init];
	
    // This connection uses the same ports as the client connection, but
    // reversed: the client's receive is the server's send.
    serverConnection = [[NSConnection
            connectionWithReceivePort:[portArray objectAtIndex:0]
            sendPort:[portArray objectAtIndex:1]] retain];
    
    // Get a proxy for the view
    proxy = [serverConnection rootProxy];
    
    // Create a new Mandelbrot server
    serverObject = [[self alloc] initWithClient:proxy];
    
    // Everything works better if you tell the proxy its protocol
    [proxy setProtocolForProxy:@protocol(MandelbrotClientMethods)];
    
    // Tell the view to add the new server to its list
    [(id)[serverConnection rootProxy] addServer:serverObject];
    
    // The server is retained by its connection
    [serverObject release];
    
    // Start up the run loop
    runLoop = [NSRunLoop currentRunLoop];
    [runLoop run];
    [pool release];
	
    return;
}

- (id)initWithClient:(id)obj
{
    [super init];
    client = [obj retain];
    return self;
}

// Notice that buffer is an unsigned long,  even though we know it is
// an unsigned char *.  DO cleverness caused trouble,  so we sent the 
// pointer as an unsigned long.

- (oneway void)fill:(unsigned long)buffer minX:(float)minX minY:(float)minY
            maxX:(float)maxX maxY:(float)maxY
            width:(int)w height:(int)h
{
    unsigned char *ptr;
    int x, y;
    float regionH, regionW;
    float regionX, regionY;
    
    fprintf(stderr, "Server %lx: starting\n", (unsigned long)self);
    
    // What is the size of the region?
    regionW = maxX - minX;
    regionH = maxY- minY;
    
    ptr = (unsigned char *)buffer;
    
    for (y = 0; y < h; y++) {
        // Calculate where on the set this y is
        regionY = maxY - (regionH * (float)y) / (float)h;
        for (x = 0; x < w; x++) {
            // Calculate where on the set this x is
            regionX = minX + (regionW * (float)x) / (float)w;
            
            // Do the calculation and color the pixel.
            mandlebrot(regionX, regionY, ptr);
            
            // move the next pixel
            ptr += 3;
        }
    }
    fprintf(stderr, "Server %lx: done\n", (unsigned long)self);
    
    // Tell the view that our part is done
    [client serverIsDone];
}

@end
