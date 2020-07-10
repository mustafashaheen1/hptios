//
//  Container.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/23/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "DCBaseEntity.h"
#import "Defect.h"
#import "Rating.h"

@interface Container : DCBaseEntity

@property (nonatomic, assign) NSInteger containerID;
@property (nonatomic, assign) NSInteger programID;
@property (nonatomic, assign) NSInteger parentID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *containerProgramName;
@property (nonatomic, assign) BOOL picture_required;
@property (nonatomic, strong) NSMutableArray *ratings;
@property (nonatomic, strong) NSMutableArray *ratingsFromUI;
@property (nonatomic, strong) NSArray *ratingPreProcessed;
@property (nonatomic, strong) NSArray *ratingConditionsArray;
@property (nonatomic, assign) float programVersionNumber;
@property (nonatomic, assign) float isProgramDistinctProducts;

- (Defect *)setDefectAttributesFromMap:(NSString *)defectID;
- (NSArray *) getAllRatings;
- (void) addRating:(Rating *) rating;

- (BOOL)isEqual:(id)object;
- (NSUInteger)hash;
+ (NSString *) getContainerNameFromContainerId: (NSString *) containerIDLocal;

@end
