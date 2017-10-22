//
//  MandelbrotServer.h
//  Mandelbrotter
//
//  Created by Aaron Hillegass on Sat Oct 19 2002.
//  Copyright (c) 2002 Big Nerd Ranch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MandelbrotProtocols.h"
#define LOOP 150
#define LIMIT 128

@interface MandelbrotServer : NSObject <MandelbrotServerMethods> {
    // This is a proxy that represents the view
    id client;
}
- (id)initWithClient:(id)obj;


@end
