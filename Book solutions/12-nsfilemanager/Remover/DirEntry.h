#import <Foundation/Foundation.h>

@interface DirEntry : NSObject {
    NSDictionary *attributes;
    DirEntry *parent;
    NSString *filename;
}
// Returns an array containing the DirEntrys in the directory p
+ (NSMutableArray *)entriesAtPath:(NSString *)p 
                       withParent:(DirEntry *)d;

// The init method is only used by entriesAtPath:withParent:
- (id)initWithFilename:(NSString *)fn parent:(DirEntry *)p;

// fullPath is the full path,  filename is just the filename
- (NSString *)fullPath;
- (NSString *)filename;

// Returns an array of the components of the path that make up 
// the DirEntry's fullPath.
- (NSMutableArray *)components;

- (BOOL)isDirectory;

- (DirEntry *)parent;
- (NSArray *)children;

@end
