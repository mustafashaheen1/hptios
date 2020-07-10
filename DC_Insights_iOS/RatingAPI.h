//
//  Rating.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/11/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCBaseEntity.h"

@interface RatingAPI : DCBaseEntity

@property (nonatomic, strong) NSArray *ratingsArray;

- (void)ratingsCallWithBlock:(void (^)(BOOL isSuccess, NSArray *array, NSError *error))block;
- (void) downloadCompleteAndItsSafeToInsertDataInToDB;
- (void) downloadImagesWithBlock:(void (^)(BOOL isReceived))success;

/*------------------------------------------------------------------------------
 Class Methods
 -----------------------------------------------------------------------------*/

+ (NSString *) getTableCreateStatmentForRatings;
+ (NSString *) getTableCreateStatmentForRatingImages;

@end
