//
//  Defect.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/22/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "Defect.h"

@implementation Defect

@synthesize defectID;
@synthesize coverage_type;
@synthesize description;
@synthesize display;
@synthesize image_smaller;
@synthesize image_updated;
@synthesize image_url;
@synthesize name;
@synthesize order_position;
@synthesize thresholdsArray;
@synthesize thresholdsArrayBeforeProcessing;
@synthesize isSetFromUI;
@synthesize displayName;
@synthesize defectGroupID;
@synthesize defectGroupName;
@synthesize thresholdTotal;
@synthesize thresholdAcceptWithIssues;
#pragma mark - Initialization

- (BOOL)isEqual:(id)object {
    Defect *copy = (Defect *) object;
    if(self.defectID == copy.defectID) {
        return true;
    }
    else
        return false;
}

- (NSUInteger)hash {
    const NSUInteger prime = 31;
    NSUInteger result = 1;
    NSInteger copy = self.defectID;
    result = prime * result + copy;
    return result;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.severities = [[NSMutableArray alloc] init];
        self.isSetFromUI = NO;
        self.defectGroupName = @"";
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

- (Image *) returnImageIfThereIsOne {
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_INSIGHTS_DATA];
    FMResultSet *results;
    Image *image;
    [database open];
    results = [database executeQuery:[self retrieveImagesFromDBForDefects]];
    while ([results next]) {
        if (self.defectID == [results intForColumn:COL_ID]) {
            image = [[Image alloc] init];
            image.deviceUrl = [results stringForColumn:COL_DEVICE_URL];
        }
    }
    [database close];
    return image;
}

#pragma mark - SQL Retrieve Data Methods

- (NSString *) retrieveImagesFromDBForDefects {
    NSString *retrieveStatement = [NSString stringWithFormat:@"SELECT * FROM %@", TBL_DEFECT_IMAGES];
    return retrieveStatement;
}

@end
