//
//  Program.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/23/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "Program.h"
#import "Container.h"
#import "ProgramGroup.h"
#import "Rating.h"

@implementation Program

@synthesize storeIds;
@synthesize active;
@synthesize start_date;
@synthesize end_date;
@synthesize programID;
@synthesize name;
@synthesize version;
@synthesize end_datePreProcessed;
@synthesize start_datePreProcessed;

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    Program *copy = (Program *) object;
    if (self == copy)
        return true;
    if (![super isEqual:copy])
        return false;
    if ([self class] != [copy class])
        return false;
    if(self.programID == copy.programID) {
        return true;
    }
    else
        return false;
}

- (NSUInteger)hash {
    const NSUInteger prime = 31;
    NSUInteger result = 1;
    NSInteger copy = self.programID;
    result = prime * result + copy;
    return result;
}


/*------------------------------------------------------------------------------
 Get All The Product Groups
 -----------------------------------------------------------------------------*/

- (NSArray *) getAllProductGroups {
    NSMutableArray *productGroupsLocal = [[NSMutableArray alloc] init];
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_INSIGHTS_DATA];
    FMResultSet *results;
    [database open];
    results = [database executeQuery:[self retrieveDataFromDBForProductGroups]];
    //NSLog(@"time1 %f", [[NSDate date] timeIntervalSince1970]);
    while ([results next]) {
        ProgramGroup *programGroup = [[ProgramGroup alloc] init];
        programGroup.programGroupID = [results intForColumn:COL_ID];
        programGroup.name = [results stringForColumn:COL_NAME];
        programGroup.audit_count = [results intForColumn:COL_AUDIT_COUNT];
        programGroup.inspectionMinimumId = [results intForColumn:COL_INSPECTION_MINIMUMS_ID];
        NSArray *arrayContainers;
        if ([results dataForColumn:COL_CONTAINERS]) {
            arrayContainers = [NSKeyedUnarchiver unarchiveObjectWithData:[results dataForColumn:COL_CONTAINERS]];
        }
        programGroup.containers = arrayContainers;
        //commenting out reading the audit_count_data until UI is finalized
        
        NSData* data = [results dataForColumn:COL_AUDIT_COUNT_DATA];
        NSDictionary* dict = [[NSDictionary alloc]init];
        if(data!=nil) {
        dict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        programGroup.audit_count_data = dict;
        programGroup.auditMinimumsBy = [self parseIntegerFromJson:programGroup.audit_count_data key:@"auditMinimumsBy"];
         programGroup.acceptRequired = [self parseIntegerFromJson:programGroup.audit_count_data key:@"acceptRequired"];
         programGroup.acceptRecommended = [self parseIntegerFromJson:programGroup.audit_count_data key:@"acceptRecommended"];
         programGroup.acceptIssuesRequired = [self parseIntegerFromJson:programGroup.audit_count_data key:@"acceptIssuesRequired"];
         programGroup.acceptIssuesRecommended = [self parseIntegerFromJson:programGroup.audit_count_data key:@"acceptIssuesRecommended"];
         programGroup.rejectRequired = [self parseIntegerFromJson:programGroup.audit_count_data key:@"rejectRequired"];
         programGroup.rejectRecommended = [self parseIntegerFromJson:programGroup.audit_count_data key:@"rejectRecommended"];
        }
        
        NSMutableArray *ratingsMutableArray = [[NSMutableArray alloc] init];
        NSArray *arrayRatings = [NSKeyedUnarchiver unarchiveObjectWithData:[results dataForColumn:COL_RATINGS]];
        for (NSDictionary *ratingsDict in arrayRatings) {
            Rating *rating = [[Rating alloc] init];
            OptionalSettings *optionalSettings = [[OptionalSettings alloc] init];
            rating.defect_family_id = [self parseIntegerFromJson:ratingsDict key:@"defect_family_id"];
            rating.defects = [[self parseArrayFromJson:ratingsDict key:@"defects"] copy];
            rating.ratingID = [self parseIntegerFromJson:ratingsDict key:@"id"];
            rating.order_position = [self parseIntegerFromJson:ratingsDict key:@"order_position"];
            optionalSettings.optional = [self parseBoolFromJson:[self parseDictFromJson:ratingsDict key:@"optional_settings"] key:@"optional"];
            optionalSettings.persistent = [self parseBoolFromJson:[self parseDictFromJson:ratingsDict key:@"optional_settings"] key:@"persistent"];
            optionalSettings.picture = [self parseBoolFromJson:[self parseDictFromJson:ratingsDict key:@"optional_settings"] key:@"picture"];
            optionalSettings.defects = [self parseBoolFromJson:[self parseDictFromJson:ratingsDict key:@"optional_settings"] key:@"defects"];
            optionalSettings.scannable = [self parseBoolFromJson:[self parseDictFromJson:ratingsDict key:@"optional_settings"] key:@"scannable"];
            optionalSettings.rating = [self parseBoolFromJson:[self parseDictFromJson:ratingsDict key:@"optional_settings"] key:@"rating"];
            rating.optionalSettings = optionalSettings;
            [ratingsMutableArray addObject:rating];
        }
        programGroup.ratings = ratingsMutableArray;
        [productGroupsLocal addObject:programGroup];
    }
    //NSLog(@"time2 %f", [[NSDate date] timeIntervalSince1970]);
    NSSet *distinctItems = [NSSet setWithArray:[productGroupsLocal copy]];
    NSArray *distinctArray = [distinctItems allObjects];
    distinctArray = [self sortListOfProductsForTheStore:distinctArray];
    //NSLog(@"fd %@", distinctArray);
    [database close];
    return distinctArray;
}

- (NSArray *) sortListOfProductsForTheStore: (NSArray *) groupsArray {
    NSArray *sortedArray = [[NSArray alloc] init];
    if ([groupsArray count] > 0) {
        //NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"programGroupID" ascending:YES];
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
        NSArray *sortDescriptors = @[sort];
        sortedArray = [groupsArray sortedArrayUsingDescriptors:sortDescriptors];
    }
    return sortedArray;
}

/*------------------------------------------------------------------------------
 Get All The Containers From the DB
 -----------------------------------------------------------------------------*/

- (NSArray *) getAllContainersFromDB {
    NSMutableArray *containersLocal = [[NSMutableArray alloc] init];
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_INSIGHTS_DATA];
    FMResultSet *results;
    [database open];
    results = [database executeQuery:[self retrieveDataFromDBForContainers]];
    while ([results next]) {
        Container *container = [[Container alloc] init];
        container.name = [results stringForColumn:@"name"];
        container.containerID = [results intForColumn:@"id"];
        container.parentID = [results intForColumn:@"parent_id"];
        container.programID = [results intForColumn:@"program_id"];
        container.picture_required = [results boolForColumn:@"picture_required"];
        container.displayName = [results stringForColumn:@"display"];
        container.containerProgramName = self.name;
        container.programVersionNumber = self.version;
        container.isProgramDistinctProducts = self.distinct_products;
        if (self.programID == container.programID) {
            [containersLocal addObject:container];
        }
    }
    [database close];
    return containersLocal;
}

#pragma mark - SQL Retrieve Data Methods
    
- (NSString *) retrieveDataFromDBForContainers {
    NSString *retrieveStatement = [NSString stringWithFormat:@"SELECT * FROM %@", TBL_CONTAINERS];
    return retrieveStatement;
}

- (NSString *) retrieveDataFromDBForProductGroups {
    NSArray *selectColumns = [NSArray arrayWithObjects:@"", nil];
    NSArray *tables = [NSArray arrayWithObjects:TBL_PRODUCTS, TBL_GROUPS, nil];
    NSArray *joinCriteria = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%@.%@", TBL_PRODUCTS, COL_PROGRAM_ID], [NSString stringWithFormat:@"%@.%@", TBL_GROUPS, COL_PROGRAM_ID], nil];
    NSString *where = [NSString stringWithFormat:@"%@.%@=%d", TBL_GROUPS, COL_PROGRAM_ID, self.programID];
    NSString *retrieveStatement = [[DBManager sharedDBManager] buildInnerJoinQuery:selectColumns withTables:tables withJoinCriteria:joinCriteria andWhereClause:where];
    NSString *retrieveStatement2 = [NSString stringWithFormat:@"SELECT * FROM %@", TBL_GROUPS];
    return retrieveStatement2;
}

@end
