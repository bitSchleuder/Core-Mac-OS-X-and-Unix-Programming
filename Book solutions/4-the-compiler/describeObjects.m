// describeObjects -- variable arguments in Objective-C

/* compile with:
cc -g -Wall -o describeObjects \
   -framework Foundation describeObjects.m
*/

#import <Foundation/Foundation.h>

@interface ObjectDescriber : NSObject { }

- (void) describeObjects: (id) firstObject, ...;

@end // ObjectDescriber


@implementation ObjectDescriber

- (void) describeObjects: (id) firstObject, ...
{
    va_list args;
    id obj = firstObject;

    va_start (args, firstObject);

    while (obj) {
        NSString *string = [obj description];
        NSLog (@"the description is:\n    %@", string);
        // get the next object
        obj = va_arg (args, id);
    }

    va_end (args);

} // describeObjects

@end // ObjectDescriber


int main (int argc, char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    ObjectDescriber *describer = [[ObjectDescriber alloc] init];

    NSString *someString = @"someString";
    NSNumber *num = [NSNumber numberWithInt: 23];
    NSDate *date = [NSCalendarDate calendarDate];

    [describer describeObjects:someString, num, date, nil];
    
    [pool release];

    return (0);

} // main
