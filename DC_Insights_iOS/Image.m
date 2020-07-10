//
//  Image.m
//  DC_Insights_iOS
//
//  Created by Vineet Pareek on 4/24/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "Image.h"
#import "AFNetworking.h"
#import "AFImageRequestOperation.h"
#import "UIImage+Resize.h"
#import "UIImageView+AFNetworking.h"
#import "NSData+Base64.h"
#import "UIImageView+WebCache.h"

#define squareShapedSize 320

@implementation Image

- (id)init
{
    self = [super init];
    if (self) {
        self.path = @"";
        self.deviceUrl = @"";
        self.remoteUrl = @"";
        self.submitted = NO;
        self.auditIdForContainer = @"";
    }
    return self;
}

// save image at deviceUrl
- (void) saveImageToDevice:(UIImage *)imageBitmap{
    UIImage *image;
    image = [imageBitmap squareImageWithImage:imageBitmap scaledToSize:CGSizeMake(squareShapedSize, squareShapedSize)];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", self.deviceUrl]];
    [UIImageJPEGRepresentation(image, 0.5) writeToFile:imagePath atomically:YES];
}

// get base64 of image
- (NSString *) getBase64EncodedImageFromDevice {
    UIImage* image = [self getImageFromDeviceUrl];
    if(image){
		NSData *dataObj = UIImagePNGRepresentation(image);
		return [dataObj base64Encoding];
	} else {
		return @"";
	}
}

//- (NSString *) getBase64EncodedImageFromDeviceForTextFile {
//    NSFileManager *fm = [NSFileManager defaultManager];
//    NSString *documents_dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    NSString *db_path = [documents_dir stringByAppendingPathComponent:[NSString stringWithFormat:@"test.txt"]];
//    NSString *string = @"VGVzdCB0aGUgc2VjdXJpdHkgaXNzdWUu";
//    NSData* cData = [string dataUsingEncoding:NSUTF8StringEncoding];
//    return [cData base64EncodedString];
//}

- (UIImage*) getImageFromDeviceUrl {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imageFilePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", self.deviceUrl]];
    UIImage *image = [UIImage imageWithContentsOfFile:imageFilePath];
    return image;
}


- (UIImage *)getImageFromRemoteUrl {
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:self.remoteUrl]];
    UIImageView *bitmapImageView = [[UIImageView alloc] init];
    [bitmapImageView setImageWithURLRequest:urlRequest placeholderImage:nil
                                     success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                         self.imageBitmap = image;
                                         [self saveImageToDevice:image];
                                     }
                                     failure:nil];
    
    return self.imageBitmap;
}

- (void) getImageFromRemoteUrlWithBlock:(void (^)(BOOL isReceived))success {
    //    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:self.remoteUrl]];
    //    UIImageView *bitmapImageView = [[UIImageView alloc] init];
    //    [bitmapImageView setImageWithURLRequest:urlRequest placeholderImage:nil
    //                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
    //                                        //self.imageBitmap = image;
    //                                        [self saveImageToDevice:image];
    //                                        success(YES);
    //                                        NSLog(@"Image Downloaded: %@",self.remoteUrl);
    //                                    }
    //                                    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
    //                                        success(YES);
    //                                        NSLog(@"Image Download Failed: %@ \n %@ %@",self.remoteUrl, error.localizedDescription, request.URL);
    //                                    }];
    
    NSURL *url = [NSURL URLWithString:self.remoteUrl];
    [SDWebImageDownloader.sharedDownloader downloadImageWithURL:url
                                                        options:0
                                                       progress:^(NSInteger receivedSize, NSInteger expectedSize){
         // progression tracking code
         //NSLog(@"Downloading...");
         
     }
                                                      completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished)
     {
         if (image && finished)
         {
             //NSLog(@"COMPLETE _____.");
             [self saveImageToDevice:image];
             success(YES);
             NSLog(@"Image Downloaded: %@",self.remoteUrl);
         } else
             success(NO);
     }];
    
}

- (void) deleteImageFromDevice:(NSString*)imageName {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", self.deviceUrl]];
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    if (success) {
        NSLog(@"image deleted");
    }
    //delete file in the file path
}

-(void)updatePathWithNewTransactionId:(NSString*)newTransactionId oldTransactionId:(NSString*)oldTransactionId{
    //replace in Path
    NSRange lastComma = [self.path rangeOfString:oldTransactionId options:NSBackwardsSearch];
    
    if(lastComma.location != NSNotFound) {
        NSString* newPath = [self.path stringByReplacingCharactersInRange:lastComma
                                                             withString:newTransactionId];
        if(newPath)
            self.path = newPath;
    }
}

-(void)updateRemoteUrlWithNewTransactionId:(NSString*)newTransactionId oldTransactionId:(NSString*)oldTransactionId{
    NSRange lastComma = [self.remoteUrl rangeOfString:oldTransactionId options:NSBackwardsSearch];
    
    if(lastComma.location != NSNotFound) {
        NSString* newRemoteUrl = [self.remoteUrl stringByReplacingCharactersInRange:lastComma
                                                               withString:newTransactionId];
        if(newRemoteUrl)
            self.remoteUrl = newRemoteUrl;
    }
}

-(void)updateImagePosition:(int)position {
    NSString* imageNumber = [self getImageNumberInRemoteUrl];
    if([imageNumber intValue] != position){
        NSString* newImageName = [NSString stringWithFormat:@"%d.jpg",position];
        [self updateImageNameInRemoteUrl:newImageName];
        [self updateImageNameInPath:newImageName];
        UIImage *image1 = [self getImageFromDeviceUrl];
       // NSString *tempUrl = self.deviceUrl;
        newImageName = [NSString stringWithFormat:@"%d",position];
        [self updateImageNameInDeviceUrl:newImageName];
       // UIImage *image2 = [self getImageFromDeviceUrl];
        [self saveImageToDevice:image1];
        //NSString *temp = self.deviceUrl;
        //self.deviceUrl = tempUrl;
        //[self saveImageToDevice:image2];
        //self.deviceUrl = temp;
    }
}

-(void)updateImageNameInRemoteUrl:(NSString*)newName {
    NSMutableArray<NSString*> *imageNameComponents = [[self.remoteUrl componentsSeparatedByString:@"/"] mutableCopy];
    [imageNameComponents setObject:newName atIndexedSubscript:imageNameComponents.count-1];
    NSString * newUrl = [[imageNameComponents valueForKey:@"description"] componentsJoinedByString:@"/"];
    self.remoteUrl = newUrl;
}

-(void)updateImageNameInPath:(NSString*)newName {
    NSMutableArray<NSString*> *imageNameComponents = [[self.path componentsSeparatedByString:@"/"] mutableCopy];
    [imageNameComponents setObject:newName atIndexedSubscript:imageNameComponents.count-1];
    NSString * newUrl = [[imageNameComponents valueForKey:@"description"] componentsJoinedByString:@"/"];
    self.path = newUrl;
}

-(void)updateImageNameInDeviceUrl:(NSString*)newName {
    NSMutableArray<NSString*> *imageNameComponents = [[self.deviceUrl componentsSeparatedByString:@"_"] mutableCopy];
    [imageNameComponents setObject:newName atIndexedSubscript:imageNameComponents.count-1];
    NSString * newUrl = [[imageNameComponents valueForKey:@"description"] componentsJoinedByString:@"_"];
    self.deviceUrl = newUrl;
}
-(NSString*)getImageNumberInRemoteUrl {
    if(self.remoteUrl){
        NSArray<NSString*> *imageNameComponents = [self.remoteUrl componentsSeparatedByString:@"/"];
        NSString* imageName = [imageNameComponents lastObject];
        NSArray<NSString*> *numberComponents = [imageName componentsSeparatedByString:@"."];
        NSString* imageNumber = [numberComponents objectAtIndex:0];
        return imageNumber;
    }
    return @"";
}

@end
