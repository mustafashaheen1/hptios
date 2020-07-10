//
//  Image.h
//  DC_Insights_iOS
//
//  Created by Vineet Pareek on 4/24/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "JSONModel.h"

@protocol Image
@end

@interface Image : JSONModel

@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *deviceUrl;
@property (nonatomic, strong) NSString * remoteUrl;
@property (nonatomic, strong) NSString<Ignore> * imageType; // PRODUCT or CONTAINER
@property (nonatomic, strong) UIImage<Ignore> *imageBitmap;
@property (nonatomic, assign) BOOL submitted;
@property (nonatomic, strong) NSString *auditIdForContainer;

- (void) saveImageToDevice:(UIImage*)imageBitmap;
- (NSString *) getBase64EncodedImageFromDevice;
- (UIImage*) getImageFromDeviceUrl;
- (UIImage *)getImageFromRemoteUrl;
- (void) deleteImageFromDevice:(NSString*)imageName;
//- (NSString *) getBase64EncodedImageFromDeviceForTextFile;
- (void) getImageFromRemoteUrlWithBlock:(void (^)(BOOL isReceived))success;
-(void)updatePathWithNewTransactionId:(NSString*)newTransactionId oldTransactionId:(NSString*)oldTransactionId;
-(void)updateRemoteUrlWithNewTransactionId:(NSString*)newTransactionId oldTransactionId:(NSString*)oldTransactionId;
-(void)updateImagePosition:(int)position;

@end
