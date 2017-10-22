/*
compile with
cc -g -Wall -framework Security -framework CoreFoundation \
               -o add_item add_item.m
*/

#import <Security/Security.h>
#import <CoreFoundation/CoreFoundation.h>
#include <stdio.h> // for printf()

int main (int argc, const char * argv[]) {
    SecKeychainAttribute attributes[2];
    SecKeychainAttributeList list;
    SecKeychainItemRef item;
    OSStatus status;

    attributes[0].tag = kSecAccountItemAttr;
    attributes[0].data = "fooz";
    attributes[0].length = 4;
    
    attributes[1].tag = kSecDescriptionItemAttr;
    attributes[1].data = "No Girls Allowed";
    attributes[1].length = 16;

    list.count = 2;
    list.attr = attributes;

    status = SecKeychainItemCreateFromContent(
                        kSecGenericPasswordItemClass, &list, 
                        5, "budda", NULL,NULL,&item);
    if (status != 0) {
        printf("Error creating new item: %d\n", 
                            (int)status);
    }
    return(0);
}
