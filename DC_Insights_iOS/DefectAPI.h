//
//  DefectAPI.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/22/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "DCBaseEntity.h"

@interface DefectAPI : DCBaseEntity

@property (nonatomic, retain) NSArray *defectsArray;

- (void)defectsCallWithBlock:(void (^)(BOOL isSuccess, NSArray *array, NSError *error))block;
- (void) downloadCompleteAndItsSafeToInsertDataInToDB;

/*------------------------------------------------------------------------------
 Class Methods
 -----------------------------------------------------------------------------*/

+ (NSString *) getTableCreateStatmentForDefects;
+ (NSString *) getTableCreateStatmentForDefectsImages;
+ (void) downloadImagesWithBlock:(void (^)(BOOL isReceived))success;
+ (BOOL) needsUpdate: (NSString *) imageUpdatedDate;
+ (NSString *) getModifiedUrl: (NSString *) url;

@end
