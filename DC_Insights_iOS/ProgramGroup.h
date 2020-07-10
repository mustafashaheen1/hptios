//
//  ProgramGroup.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/25/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCBaseEntity.h"
#import "JSONModel.h"
#import "RatingJSONModel.h"

@interface ProgramGroup : DCBaseEntity<NSCopying>

@property (nonatomic, assign) NSInteger audit_count;
@property (nonatomic, assign) NSInteger programGroupID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSInteger inspectionMinimumId;
@property (nonatomic, assign) NSInteger program_id;
@property (nonatomic, strong) NSArray *containers;
@property (nonatomic, strong) NSArray *ratings;
@property (nonatomic, strong) NSArray *ratingsPreProcessed;
@property (nonatomic, strong) NSArray *products;
@property (nonatomic, strong) NSArray *savedAudits;
//audit_count_data
@property (nonatomic, strong) NSDictionary *audit_count_data;
@property (nonatomic, assign) NSInteger auditMinimumsBy;
@property (nonatomic, assign) NSInteger acceptRequired;
@property (nonatomic, assign) NSInteger acceptRecommended;
@property (nonatomic, assign) NSInteger acceptIssuesRequired;
@property (nonatomic, assign) NSInteger acceptIssuesRecommended;
@property (nonatomic, assign) NSInteger rejectRequired;
@property (nonatomic, assign) NSInteger rejectRecommended;

- (NSArray *) getAllProducts;
- (BOOL)isEqual:(id)object;
- (NSUInteger)hash;
-(id) mutableCopyWithZone:(NSZone *)zone;

@end
