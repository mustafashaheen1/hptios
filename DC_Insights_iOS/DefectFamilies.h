//
//  DefectFamilies.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/27/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "DCBaseEntity.h"
#import "Threshold.h"
#import "QualityManual.h"

@interface DefectFamilies : DCBaseEntity

@property (nonatomic, strong) NSArray *defectsArray;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *display;
@property (nonatomic, assign) NSInteger defectID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, assign) NSInteger total;
@property (nonatomic, assign) NSInteger acceptWithIssuesTotal;
@property (nonatomic, strong) NSArray *severityTotals;
@property (nonatomic, assign) NSInteger variety_id;
@property (nonatomic, strong) NSArray *defectsArrayPreProcessed;
@property (nonatomic, strong) QualityManual *qualityManual;
@property (nonatomic, strong) NSDictionary *qualityManualPreProcessed;

@end
