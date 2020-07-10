//
//  ImageGalleryPicker.m
//  Insights
//
//  Created by Vineet Pareek on 1/3/17.
//  Copyright © 2017 Yottamark. All rights reserved.
//

#import "ImageGalleryPicker.h"

static ImageGalleryPicker *_imageGalleryPicker = nil;

// destroys sharedInstance after main exits.. REQUIRED for unit tests
// to work correclty, otherwse the FIRST shared object gets used for ALL
// tests, resulting in KVO problems

__attribute__((destructor)) static void destroy_singleton() {
    @autoreleasepool {
        _imageGalleryPicker = nil;
    }
}

@implementation ImageGalleryPicker

+ (ImageGalleryPicker *) sharedPicker
{
    if (_imageGalleryPicker == nil)
        [ImageGalleryPicker initialize] ;
    
    return _imageGalleryPicker ;
}

/*------------------------------------------------------------------------------
 Singleton Methods.. Generic to any Singleton
 -----------------------------------------------------------------------------*/
#pragma mark - Singleton Methods

+ (void)initialize
{
    if (_imageGalleryPicker == nil)
        _imageGalleryPicker = [[self alloc] init];
}

- (AGImagePickerController*) getImageGalleryPicker {
    if(!self.imagePickerController)
        self.imagePickerController = [[AGImagePickerController alloc]init];
    
    return self.imagePickerController;
}


@end
