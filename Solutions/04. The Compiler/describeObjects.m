#import <Foundation/Foundation.h>

@interface SomeClass : NSObject { }

@end // SomeClass


@implementation SomeClass

- (void) describeObjects: (id) firstObject, ...
{
    va_list args;
    id obj = firstObject;

    va_start (args, firstObject);

    while (obj) {
	NSString *string = [obj description];
	NSLog (@"the description is %@", string);
	obj = va_arg (args, id);
    }

    va_end (args);

} // describeObjects

@end // SomeClass


int main (int argc, char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    SomeClass *class = [[SomeClass alloc] init];

    NSString *someString = @"someString";
    NSNumber *num = [NSNumber numberWithInt: 23];
    NSDate *date = [NSCalendarDate calendarDate];

    [class describeObjects:someString, num, date, nil];
    
    [pool release];

    return (0);

} // main
