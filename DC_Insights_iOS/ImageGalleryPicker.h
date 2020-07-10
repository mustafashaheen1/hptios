//
//  ImageGalleryPicker.h
//  Insights
//
//  Created by Vineet Pareek on 1/3/17.
//  Copyright © 2017 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AGImagePickerController.h"

@interface ImageGalleryPicker : NSObject

@property (nonatomic, strong) AGImagePickerController *imagePickerController;

-(AGImagePickerController*)getImageGalleryPicker;
+ (ImageGalleryPicker *) sharedPicker;

@end
