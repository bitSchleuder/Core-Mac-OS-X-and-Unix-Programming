// dumpem.m -- poke inside the keychain

/*
compile with:
cc -g -Wall -framework Security -framework CoreFoundation \
                                         -o dumpem dumpem.m
*/

#import <Security/Security.h>
#import <CoreFoundation/CoreFoundation.h>

#import <stdlib.h>        // for EXIT_SUCCESS
#import <stdio.h>         // for printf() and friends
#import <string.h>        // for strncpy

// given a carbon-style 4-byte character identifier,
// make a C string that can be given to printf

const char *fourByteCodeString (UInt32 code)
{
    // sick-o hack to quickly assign an identifier
    // into a character buffer
    typedef union theCheat {
        UInt32 theCode;
        char theString[4];
    } theCheat;

    static char string[5];

    ((theCheat*)string)->theCode = code;
    string[4] = '\0';

    return (string);

} // fourByteCodeString

void showList (SecKeychainAttributeList list)
{
    char buffer[1024];
    SecKeychainAttribute attr;

    int i;

    for (i = 0; i < list.count; i++) {

       attr = list.attr[i];

       if (attr.length < 1024) {
               // make a copy of the data so we can stick on
               // a trailing zero byte
               strncpy (buffer, attr.data, attr.length);
               buffer[attr.length] = '\0';

          printf ("\t%d: '%s' = \"%s\"\n", 
                  i, fourByteCodeString(attr.tag), buffer);
       } else {
          printf ("attribute %d is more than 1K\n", i);
       }
    }

} // showList

void dumpItem (SecKeychainItemRef item)
{
    UInt32 length;
    char *password;
    SecKeychainAttribute attributes[8];
    SecKeychainAttributeList list;
    OSStatus status;

    // list the attributes you wish to read
    attributes[0].tag = kSecAccountItemAttr;
    attributes[1].tag = kSecDescriptionItemAttr;
    attributes[2].tag = kSecLabelItemAttr;
    attributes[3].tag = kSecModDateItemAttr;
 
    list.count = 4;
    list.attr = attributes;

    status = SecKeychainItemCopyContent (item, NULL, &list, &length, 
                                         (void **)&password);

    // use this version if you don't really want the password,
    // but just want to peek at the attributes
    //status = SecKeychainItemCopyContent (item, NULL, &list, NULL, NULL);
    
    // make it clear that this is the beginning of a new
    // keychain item
    printf("\n\n");
    if (status == noErr) {
        if (password != NULL) {

            // copy the password into a buffer so we can attach a
            // trailing zero byte in order to be able to print
            // it out with printf
            char passwordBuffer[1024];

            if (length > 1023) {
                length = 1023; // save room for trailing \0
            }
            strncpy (passwordBuffer, password, length);

            passwordBuffer[length] = '\0';
            printf ("Password = %s\n", passwordBuffer);
        }
        showList (list);

        SecKeychainItemFreeContent (&list, password);

    } else {
        printf("Error = %d\n", (int)status);
    }

} // dumpItem

// Jaguar is missing SecACL.h.  Here is the prototype of the
// function we need from there.
extern OSStatus SecACLCopySimpleContents(SecACLRef acl,
                                       CFArrayRef *applicationList,
                                      CFStringRef *description,
                CSSM_ACL_KEYCHAIN_PROMPT_SELECTOR *promptSelector);

void showAccess (SecAccessRef accessRef)
{
    int count, i;
    CFArrayRef aclList;
    CFArrayRef applicationList;
    SecACLRef acl;
    CFStringRef description;
    CSSM_ACL_KEYCHAIN_PROMPT_SELECTOR promptSelector;
    SecTrustedApplicationRef application;
    CFDataRef appData;

    // Get a list of access lists
    SecAccessCopyACLList(accessRef, &aclList);
    count = CFArrayGetCount(aclList);
    printf("%d access control lists\n", count);
    for (i = 0; i < count; i++) {
        char buffer[256];
  
        acl = (SecACLRef)CFArrayGetValueAtIndex(aclList, i);

        // Get the list of trusted applications
        SecACLCopySimpleContents(acl, &applicationList, 
                            &description, &promptSelector);

        CFStringGetCString(description, buffer, 
                                     256, kCFStringEncodingASCII);
        CFRelease(description);

        // Does the apps on this list require the user
        // to type in the keychain passphrase?
        if (promptSelector.flags && 
                 CSSM_ACL_KEYCHAIN_PROMPT_REQUIRE_PASSPHRASE) {
            printf("\t%d: ACL %s - Requires passphrase\n", 
                                             i, buffer);
        } else {
            printf("\t%d: ACL %s - Does not require passphrase\n",
                                             i, buffer);
        }
        // Sometimes there is no application list at all
        if (applicationList == NULL) {
            printf("\t\tNo application list\n");
            continue;
        }
        int j, appCount;
        appCount = CFArrayGetCount(applicationList);
        printf("\t\t%d trusted applications\n", appCount);
        for (j = 0; j < appCount; j++) {
            application = (SecTrustedApplicationRef)
                  CFArrayGetValueAtIndex(applicationList, j);
      
            // Get the app data for the trusted application
            // (this is usually the path to the app)
            SecTrustedApplicationCopyData(application, &appData);
            printf("\t\t%s\n",CFDataGetBytePtr(appData));
            CFRelease(appData);
        }
        CFRelease(applicationList);
    }
    CFRelease(aclList);
}


int main (int argc, char *argv[])
{
    SecKeychainSearchRef search;
    SecKeychainItemRef item;
    SecKeychainAttributeList list;
    SecKeychainAttribute attribute;
    OSErr result;
    int i = 0;

    // create an attribute list with just one attribute specified
    // (You will want to change these to match a user name that you
    //  have on your key chain)
    attribute.tag = kSecAccountItemAttr;
    attribute.length = 12;
    attribute.data = "bignerdranch";

    list.count = 1;
    list.attr = &attribute;

    result = SecKeychainSearchCreateFromAttributes 
                 (NULL, kSecGenericPasswordItemClass,
                  &list, &search);

    if (result != noErr) {
        printf ("status %d from "
                "SecKeychainSearchCreateFromAttributes\n",
                result);
    }
    while (SecKeychainSearchCopyNext (search, &item) == noErr) {
	dumpItem (item);
	// Get the SecAccess
        SecAccessRef access;
        SecKeychainItemCopyAccess(item, &access);
        showAccess(access);
        CFRelease(access);
        CFRelease (item);
        i++;
    }

    printf ("%d items found\n", i);
    CFRelease (search);

    return (EXIT_SUCCESS);

} // main&#13;
