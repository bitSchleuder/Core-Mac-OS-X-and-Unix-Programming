#import "DirEntry.h"

@implementation DirEntry

+ (NSMutableArray *)entriesAtPath:(NSString *)p 
                       withParent:(DirEntry *)d
{
    int max, k;
    DirEntry *newEntry;
    NSString *currentFilename;
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *filenames;
    NSMutableArray *result = [NSMutableArray array];
    NSLog(@"reading %@", p);
    filenames = [manager directoryContentsAtPath:p];

    // Was the filemanager unable to read the directory at the path?
    if (filenames == nil) {
        NSLog(@"Unable to read %@", p);
        return result;
    }
    max = [filenames count];
    for (k = 0; k < max; k++) {
        currentFilename = [filenames objectAtIndex:k];
        newEntry = [[DirEntry alloc] initWithFilename:currentFilename
                                               parent:d];
        [result addObject:newEntry];
        [newEntry release];
    }
    return result;
}

- (id)initWithFilename:(NSString *)fn parent:(DirEntry *)p
{
    [super init];

    // No need to retain parent
    parent = p;
    filename = [fn copy];
    return self;
}

// Get the array of components using recursion
- (NSMutableArray *)components
{
    NSMutableArray *result;
    if (!parent) {
        result = [NSMutableArray array];

        // Add an empty string at the beginning of the 
        // array to represent the "/" entry.
        [result addObject:@"/"];
    } else {
        result = [parent components];
    }
    [result addObject:[self filename]];
    return result;
}

// Take advantage of the components method to create the fullPath
- (NSString *)fullPath
{
    return [NSString pathWithComponents:[self components]];
} 

- (NSString *)filename
{
    return filename;
}

- (BOOL)isDirectory
{
    // Is this the first time we have been asked?
    if (!attributes) {
        NSString *path = [self fullPath];
        attributes = [[NSFileManager defaultManager] 
                                 fileAttributesAtPath:path
                                         traverseLink:YES];
        [attributes retain];
    }
    return [[attributes fileType] isEqual:NSFileTypeDirectory];
}

- (NSArray *)children
{
    NSString *path = [self fullPath];
    return [DirEntry entriesAtPath:path withParent:self];
}

- (DirEntry *)parent
{
    return parent;
}

- (void)dealloc
{
    [attributes release];
    [filename release];
    [super dealloc];
}

@end
