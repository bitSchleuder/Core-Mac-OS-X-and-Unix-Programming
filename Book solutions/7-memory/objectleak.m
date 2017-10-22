// objectleak.m -- leak some Cocoa objects

/* compile with:
cc -g -Wall -framework Foundation -o objectleak objectleak.m
*/

#import <Foundation/Foundation.h>

int main (int argc, char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSNumber *number;
    int i;

    for (i = 0; i < 20; i++) {
        // alloc creates an object with a retain count of 1
        number = [[NSNumber alloc] initWithInt: i];
        [array addObject: number]; // number has retain count of 2
    }

    [array release]; // each of the numbers have retain counts of 1

    [pool release];

    return (0);

} // main
