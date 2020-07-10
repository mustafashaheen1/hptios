//
//  Program.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/23/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "DCBaseEntity.h"
#import "Product.h"
#import "ProgramGroup.h"
#import "ApplyToAll.h"

@interface Program : DCBaseEntity

@property (nonatomic, assign) BOOL active;
@property (nonatomic, strong) NSDate *end_date;
@property (nonatomic, assign) NSInteger programID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDate *start_date;
@property (nonatomic, strong) NSArray *storeIds;
@property (nonatomic, assign) NSInteger version;
@property (nonatomic, strong) NSString *end_datePreProcessed;
@property (nonatomic, strong) NSString *start_datePreProcessed;
@property (nonatomic, assign) BOOL distinct_products;
@property (nonatomic, assign) NSInteger inspectionMinimumId;
@property (nonatomic, strong) ApplyToAll *apply_to_all;


- (NSArray *) getAllProductGroups;
- (NSArray *) getAllContainersFromDB;

@end
