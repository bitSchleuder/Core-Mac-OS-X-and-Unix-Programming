/* scf-dump.m -- show all the live entries from the 
 *               SystemConfiguration.framework
 */

/* compile with:
cc -g -Wall -framework Foundation -framework SystemConfiguration \
   -o scf-dump scf-dump.m
*/

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

/* a little utility function to NSLog information, but without the
 * leading noise information like the current time and process ID
 */

void LogIt (NSString *format, ...)
{
    va_list args;
    va_start (args, format);

    NSString *string;
    // the string format stuff will expand %@, which regular v*printf
    // won't do
    string = [[NSString alloc] initWithFormat: format  arguments:args];

    va_end (args);

    printf ("%s\n", [string cString]);

    [string release];

} // LogIt

// print the contents of a dictionary (string keys, string values)

void dumpDictionary (NSDictionary *dictionary)
{
    NSArray *keys;
    NSArray *values;
    int i;

    keys = [dictionary allKeys];
    values = [dictionary objectsForKeys:keys  notFoundMarker:nil];

    for (i = 0; i < [keys count]; i++) {
        LogIt (@"    %@ : %@", [keys objectAtIndex:i],
               [values objectAtIndex:i]);
    }

} // dumpDictionary

int main (int argc, const char *argv[]) 
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    // make a connection to the configd

    SCDynamicStoreRef store;
    SCDynamicStoreContext context = {
        0, NULL, NULL, NULL, NULL
    };

    store = SCDynamicStoreCreate (NULL,                 // allocator
                                  SCSTR("SCF Dumper"),  // name
                                  NULL,                 // callback
                                  &context);            // DynStore context
    if (store == NULL) {
        NSLog (@"oops!  can't SCDynamicStoreCreate");
        goto bailout;
    }

    // get a list of all the keys.  the .* regexp will match everything
    CFArrayRef keys;
    keys = SCDynamicStoreCopyKeyList (store, SCSTR(".*"));

    if (keys == NULL) {
        NSLog (@"oops!  can't SCDynamicStoreCopyKeyList");
        goto bailout;
    }

    // walk the set of keys.  It returns a CFArrayRef, which is 
    // toll-free-bridged to an NSArray, so we can use the 
    // NSArray enumerator

    CFStringRef key;

    NSEnumerator *enumerator;
    enumerator = [((NSArray*)keys) objectEnumerator];

    while ((key = (CFStringRef)[enumerator nextObject])) {

        LogIt (@"key is %@", key);

        // get the value from configd
        CFPropertyListRef value;
        value = SCDynamicStoreCopyValue (store, key);

        // some values are keys, others are dictionaries withricher
        // result values
        if ([(id)value isKindOfClass:[NSDictionary class]]) {
            dumpDictionary ((NSDictionary *) value);
        } else {
            LogIt (@"    %@", (id)value);
        }
        LogIt (@"\n");
    }

bailout:
    [pool release];

    return (EXIT_SUCCESS);

} // main
