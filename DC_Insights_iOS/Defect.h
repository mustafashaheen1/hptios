//
//  Defect.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/22/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "DCBaseEntity.h"
#import "Threshold.h"
#import "Severity.h"
#import "Image.h"

@interface Defect : DCBaseEntity

@property (nonatomic, strong) NSString *coverage_type;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *html_description_source;
@property (nonatomic, assign) BOOL enable_html_description;
@property (nonatomic, strong) NSString *display;
@property (nonatomic, assign) NSInteger defectID;
@property (nonatomic, assign) NSInteger defectGroupID;
@property (nonatomic, strong) NSString *image_smaller;
@property (nonatomic, strong) NSString *image_updated;
@property (nonatomic, strong) NSString *image_url;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *severityNameForSortingLater;
@property (nonatomic, strong) NSString *defectGroupName;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, assign) NSInteger order_position;
@property (nonatomic, strong) NSArray *thresholdsArray;
@property (nonatomic, strong) NSArray *thresholdsArrayBeforeProcessing;
//@property (nonatomic, strong) Severity *severity;
@property (nonatomic, assign) BOOL isSetFromUI;
@property (nonatomic, strong) NSMutableArray *severities;
@property (nonatomic, assign) float thresholdTotal;
@property (nonatomic, assign) float thresholdAcceptWithIssues;

// used for saving the values entered by user
@property (nonatomic, strong) NSString *selectedSeverity;
@property (nonatomic, assign) double selectedPercentage;
@property (nonatomic, assign) double selectedNumerator;
@property (nonatomic, assign) double selectedDenominator;

- (Threshold *)setThresholdAttributesFromMap:(NSDictionary *)datamap;
- (Image *) returnImageIfThereIsOne;

@end
