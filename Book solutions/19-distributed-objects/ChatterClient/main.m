#import <Cocoa/Cocoa.h>

int main(int argc, const char *argv[])
{
    if ([NSHost respondsToSelector:@selector(_fixNSHostLeak)]) {
        [NSHost _fixNSHostLeak];
    }
    if ([NSSocketPort respondsToSelector:
                             @selector(_fixNSSocketPortLeak)]) {
        [NSSocketPort _fixNSSocketPortLeak];
    }    
    return NSApplicationMain(argc, argv);
}
