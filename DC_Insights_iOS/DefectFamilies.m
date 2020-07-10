//
//  DefectFamilies.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/27/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "DefectFamilies.h"

@implementation DefectFamilies

@synthesize defectID;
@synthesize description;
@synthesize display;
@synthesize name;
@synthesize defectsArray;
@synthesize variety_id;
@synthesize total;
@synthesize displayName;
@synthesize acceptWithIssuesTotal;
@synthesize severityTotals;

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (Threshold *)setThresholdAttributesFromMap:(NSDictionary *)datamap {
    Threshold *threshold = [[Threshold alloc] init];
    if (datamap) {
        threshold.name = [self parseStringFromJson:datamap key:@"name"];
        threshold.accept_with_issues = [self parseIntegerFromJson:datamap key:@"accept_with_issues"];
        threshold.reject = [self parseIntegerFromJson:datamap key:@"reject"];
        threshold.order_position = [self parseIntegerFromJson:datamap key:@"order_position"];
    }
    return threshold;
}

@end
