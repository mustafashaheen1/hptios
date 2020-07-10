//
//  Rating.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/27/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "DCBaseEntity.h"
#import "Content.h"
#import "OptionalSettings.h"
#import "Defect.h"
#import "PictureAndDefectThresholds.h"
#import "QualityManual.h"

@protocol Rating
@end

@interface Rating : JSONModel

@property (nonatomic, assign) int id;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, assign) NSInteger ratingID;
@property (nonatomic, assign) NSInteger groupRatingID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *display;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *order_data_field;
@property (nonatomic, strong) Content *content;
@property (nonatomic, strong) NSDictionary *contentPreProcessed;
@property (nonatomic, assign) NSInteger container_id;
@property (nonatomic, assign) NSInteger defect_family_id;
@property (nonatomic, strong) NSMutableArray *defects;
@property (nonatomic, strong) NSMutableArray *defectsIdList;
@property (nonatomic, assign) NSInteger containerID;
@property (nonatomic, assign) NSInteger order_position;
@property (nonatomic, strong) OptionalSettings *optionalSettings;
@property (nonatomic, strong) NSDictionary *optionalSettingsPreProcessed;
@property (nonatomic, strong) NSDictionary *thresholdsPreProcessed;
@property (nonatomic, strong) NSArray *options;
@property (nonatomic, strong) NSMutableArray *defectsFromUI;
@property (nonatomic, strong) NSString *ratingAnswerFromUI;
@property (nonatomic, strong) NSArray *defectsFromDefectAPI;
@property (nonatomic, strong) PictureAndDefectThresholds *pictureAndDefectThresholds;
@property (nonatomic, assign) NSInteger default_star;
@property (nonatomic,strong) NSString* value;
@property (nonatomic,assign) double average;
@property (nonatomic,assign) NSInteger productId;
@property (nonatomic, assign) BOOL is_numeric;


- (NSArray *) getAllDefects;
- (void) addDefect:(Defect *) defect;
- (void) populateThresholdsForRating:(int) containerId withProgramId: (int) programId withDatabase: (FMDatabase *) database;
- (NSArray *) getDefectsInSortedOrder: (NSArray *) sortRatingsArray;
- (QualityManual*)getQualityManual;
- (NSArray*) getGlobalThresholds:(int) defectFamilyId withDatabase:(FMDatabase *) databaseLocal;
- (NSArray*) getSeverityTotals:(int) defectFamilyId withDatabase:(FMDatabase *) databaseLocal;
-(int) getDefectFamilyId:(NSInteger) productId withGroupId:(NSInteger) groupId withRatingId:(NSInteger) ratingId withDatabase:(FMDatabase *) databaseLocal;
@end
