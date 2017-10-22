// objectleak.m -- leak some Cocoa objects

/* compile with
cc -Wmost -g -framework Foundation -o objectleak objectleak.m
 */

#import <Foundation/Foundation.h>

int main (int argc, char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSNumber *number;
    int i;

    for (i = 0; i < 20; i++) {
	number = [[NSNumber alloc] initWithInt: i]; // retain count of 1
	[number retain];
	[array addObject: number]; // number has retain count of 2
    }

    [array release]; // each of the numbers have retain counts of 1
    // therefore we've leaked each of the numbers

    [pool release];
    sleep (5000);
    exit (0);

} // main
