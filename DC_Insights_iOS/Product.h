//
//  DCProduct.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/19/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QualityManual.h"
#import "DCBaseEntity.h"
#import "Rating.h"
#import "SavedAudit.h"
#import "ProductRatingDefect.h"

@interface Product : DCBaseEntity<NSCopying>

@property (nonatomic, strong) NSString *commodity;
@property (nonatomic, assign) NSInteger group_id;
@property (nonatomic, assign) NSInteger insights_product;
@property (nonatomic, strong) NSArray *plus;
@property (nonatomic, strong) NSArray *upcs;
@property (nonatomic, strong) NSArray *skus;
@property (nonatomic, strong) NSArray *containers;
@property (nonatomic, assign) NSInteger product_id;
@property (nonatomic, assign) NSInteger auditsCount;
@property (nonatomic, assign) NSInteger countOfCases;
@property (nonatomic, strong) NSString *product_name;
@property (nonatomic, strong) NSString *program_version;
@property (nonatomic, assign) NSInteger program_id;
@property (nonatomic, assign) NSInteger require_hm_code;
@property (nonatomic, strong) NSString *variety;
@property (nonatomic, strong) QualityManual *qualityManual;
@property (nonatomic, strong) NSDictionary *qualityManualPreProcessed;
@property (nonatomic, strong) NSMutableArray *ratingsFromUI;
@property (nonatomic, strong) NSMutableArray<QualityManual*> *qualityManuals;
@property (nonatomic,assign) BOOL isFlagged;
@property (nonatomic, strong) NSMutableArray *allFlaggedProductMessages;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *score;
@property (nonatomic, strong) NSArray *subProductsArray;
@property (nonatomic, strong) NSArray *ratings;
@property (nonatomic, strong) NSString *selectedSku;
@property (nonatomic, strong) SavedAudit *savedAudit;
@property (nonatomic, strong) NSArray* rating_defects;
@property (nonatomic, assign) NSInteger daysRemaining;
@property (nonatomic, assign) NSInteger daysRemainingMax;

- (NSArray *) getAllRatings;
- (void) addRating:(Rating *) rating;
-(Product*)getCopy;
-(id) mutableCopyWithZone: (NSZone *) zone;
-(NSInteger)getDefectFamilyIdForRating:(NSInteger)ratingId;
@end
