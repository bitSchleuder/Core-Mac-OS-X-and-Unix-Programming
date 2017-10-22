// stolen from mailing list.  Haven't tested yet.

#import <Carbon/Aliases.h>
NSString* ResolveAliasPath(NSString* path)
{
    CFStringRef resolvedPath = nil;
    CFURLRef    url = CFURLCreateWithFileSystemPath(NULL /*allocator*/,
						    (CFStringRef)path, kCFURLPOSIXPathStyle, NO /*isDirectory*/);
    if (url != NULL) {
	FSRef fsRef;
	if (CFURLGetFSRef(url, &fsRef)) {
	    Boolean targetIsFolder, wasAliased;
	    if (FSResolveAliasFile (&fsRef, true /*resolveAliasChains*/,
				    &targetIsFolder, &wasAliased) == noErr && wasAliased) {
		CFURLRef resolvedurl = CFURLCreateFromFSRef(NULL
/*allocator*/, &fsRef);
		if (resolvedurl != NULL) {
		    resolvedPath = CFURLCopyFileSystemPath(resolvedurl,
							   kCFURLPOSIXPathStyle);
		    CFRelease(resolvedurl);
		}
	    }
	}
	CFRelease(url);
    }
    return resolvedPath != nil ? [(NSString*)resolvedPath autorelease] :
	path;
}

BOOL isAliasFile(const NSString* inPath)
{
    BOOL result = NO;

    // Get an FSRef from the path
    FSRef fsRef;
    OSStatus err = FSPathMakeRef([inPath fileSystemRepresentation],
				 &fsRef, NULL);
    if (err == noErr)
    {
	// Get the FinderInfo for the file
	FSCatalogInfo catalogInfo;
	err = FSGetCatalogInfo(& fsRef, kFSCatInfoFinderInfo,
			       &catalogInfo, NULL, NULL, NULL);
	if (err == noErr)
	{
	    // Check the isAlias bit
	    FileInfo* info = (FileInfo*)&catalogInfo.finderInfo;
	    result = (info->finderFlags & kIsAlias) != 0;
	}
    }

    return result;
}

