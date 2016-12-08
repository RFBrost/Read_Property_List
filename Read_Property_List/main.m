//
//  main.m
//  Read_Property_List
//
//  Created by Robert Brost on 01/18/16.
//  Copyright © 2016 RFBrost. All rights reserved.
//

#include <CoreFoundation/CoreFoundation.h>
#import <Cocoa/Cocoa.h>

    
#define kNumKids        2
#define kNumBytesInPic 10
#define kNumPets        2


//----------------------------------------- Prototypes --------------------------------------------------

CFDictionaryRef CreateMyDictionary (void);

CFPropertyListRef CreateMyPropertyListFromFile (CFURLRef fileURL);

void WriteMyPropertyListToFile (CFPropertyListRef propertyList, CFURLRef fileURL);

//------------------------------------------ Main () -----------------------------------------------------

int main(int argc, const char * argv[]) {
    
    NSLog(@"Starting Main");
    
    NSLog(@"Creating dictionary");

    // Construct a complex dictionary object;
    CFPropertyListRef propertyList = CreateMyDictionary ();
    
    NSLog(@"Creating URL");
        
    // Create a URL specifying the file to hold the XML data.
    CFURLRef fileURL = CFURLCreateWithFileSystemPath (kCFAllocatorDefault,
                                                     CFSTR("test.plist"),      // file path name
                                                     kCFURLPOSIXPathStyle,   // interpret as POSIX path
                                                     false);                 // is it a directory?
    NSLog(@"Write out property list");
    
    // Write the property list to the file.
    WriteMyPropertyListToFile (propertyList, fileURL);
    CFRelease (propertyList);
    
     NSLog(@"Read in property list");
        
    // Recreate the property list from the file.
    propertyList = CreateMyPropertyListFromFile (fileURL);
        
    // Release objects we created.
    if (propertyList)
    {
        NSLog(@"Do propertyList release");
        CFRelease(propertyList);
    }
    if (fileURL)
    {
        NSLog(@"Do fileURL release");
        CFRelease(fileURL);
    }
    
    return 0;
    }

//------------------------------------------ CreateMyDictionary (void) -------------------------------------

    CFDictionaryRef CreateMyDictionary(void) {
        
         NSLog(@"Starting CreateMyFakeDictionary");
        
        // Create a dictionary that will hold the data.
        CFMutableDictionaryRef dict = CFDictionaryCreateMutable(kCFAllocatorDefault, 0,
                                                                &kCFTypeDictionaryKeyCallBacks,
                                                                &kCFTypeDictionaryValueCallBacks);
        
        /*
         Put various items into the dictionary.
         Values are retained as they are placed into the dictionary, so any values
         that are created can be released after being added to the dictionary.
         */
        
        CFDictionarySetValue(dict, CFSTR("Name"), CFSTR("John Doe"));
        
        CFDictionarySetValue(dict, CFSTR("City of Birth"), CFSTR("Springfield"));
        
        int yearOfBirth = 1965;
        CFNumberRef num = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &yearOfBirth);
        CFDictionarySetValue(dict, CFSTR("Year Of Birth"), num);
        CFRelease(num);
        
        CFStringRef kidsNames[kNumKids];
        // Define some Kid data.
        kidsNames[0] = CFSTR("John");
        kidsNames[1] = CFSTR("Kyra");
        CFArrayRef array = CFArrayCreate(kCFAllocatorDefault,
                                         (const void **)kidsNames,
                                         kNumKids,
                                         &kCFTypeArrayCallBacks);
        CFDictionarySetValue(dict, CFSTR("Kids Names"), array);
        CFRelease(array);
        
        CFStringRef petsNames[kNumPets];
        // Define some Pet data.
        petsNames[0] = CFSTR("Sam");
        petsNames[1] = CFSTR("Scraps");
        CFArrayRef array2 = CFArrayCreate(kCFAllocatorDefault,
                                         (const void **)petsNames,
                                         kNumPets,
                                         &kCFTypeArrayCallBacks);
        CFDictionarySetValue(dict, CFSTR("Pets Names"), array2);
        CFRelease(array2);

  /*
        array = CFArrayCreate(kCFAllocatorDefault, NULL, 0, &kCFTypeArrayCallBacks);
        CFDictionarySetValue(dict, CFSTR("Pets Names"), array);
        CFRelease(array);
   */
        
        // Fake data to stand in for a picture of John Doe.
        const unsigned char pic[kNumBytesInPic] = {0x3c, 0x42, 0x81,
            0xa5, 0x81, 0xa5, 0x99, 0x81, 0x42, 0x3c};
        CFDataRef data = CFDataCreate(kCFAllocatorDefault, pic, kNumBytesInPic);
        CFDictionarySetValue(dict, CFSTR("Picture"), data);
        CFRelease(data);
        
        return dict;
    }

//----------------- WriteMyPropertyListToFile (CFPropertyListRef propertyList, CFURLRef fileURL) ----

    void WriteMyPropertyListToFile(CFPropertyListRef propertyList, CFURLRef fileURL) {
        
        // Convert the property list into XML data
        CFErrorRef  myError;
        CFIndex     myErrorIndex;
        
        NSLog(@"Starting WriteMyPropertyListToFile");
        
        CFDataRef xmlData = CFPropertyListCreateData(
                                    kCFAllocatorDefault, propertyList, kCFPropertyListXMLFormat_v1_0, 0, &myError);
        if (xmlData == nil && myError)
        {
            myErrorIndex = CFErrorGetCode (myError);
            NSLog(@"myErrorIndex = %ld", myErrorIndex);
        }
        
        NSLog(@"About to Write Data & Properties to Resource");
        
        // Handle any errors
        
        // Write the XML data to the file.
        SInt32 errorCode;
        Boolean status = CFURLWriteDataAndPropertiesToResource(
                                                               fileURL, xmlData, NULL, &errorCode);
        
        if (!status) {
            
            NSLog(@"We got an error!");
            
            // Handle the error.
        }
        
        if (xmlData)
        {
            NSLog(@"Do xmlData release");
            CFRelease(xmlData);
        }
        if (myError)
        {
            NSLog(@"Do myError release");
            CFRelease(myError);
        }
    }

//-------------------------- CreateMyPropertyListFromFile (CFURLRef fileURL) -----------------------------

    CFPropertyListRef CreateMyPropertyListFromFile(CFURLRef fileURL) {
        
        // Read the XML file
        CFDataRef   resourceData;
        SInt32      errorCode;
        CFIndex     myErrorIndex;
        
        NSLog(@"Starting CreateMyPropertyListFromFile");
        
        Boolean status = CFURLCreateDataAndPropertiesFromResource(
                                                                  kCFAllocatorDefault, fileURL, &resourceData,
                                                                  NULL, NULL, &errorCode);
        
        if (!status) {
            // Handle the error
            NSLog(@"We got an error!");
        }
        
        // Reconstitute the dictionary using the XML data
        CFErrorRef          myError;
        CFPropertyListRef   propertyList = CFPropertyListCreateWithData(
                                                                      kCFAllocatorDefault, resourceData, kCFPropertyListImmutable, NULL, &myError);
        
        // Handle any errors
        if (propertyList == nil && myError)
        {
            myErrorIndex = CFErrorGetCode (myError);
            NSLog(@"myErrorIndex = %ld", myErrorIndex);
            CFRelease(myError);
        }

        if (resourceData)
        {
            NSLog(@"Do resourceData release");
            CFRelease(resourceData);
        }
         return propertyList;
    }
