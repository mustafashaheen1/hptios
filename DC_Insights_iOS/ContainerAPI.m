//
//  Container.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/11/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "ContainerAPI.h"
#import "Container.h"
#import "DBManager.h"
#import "PaginationCallsClass.h"

@implementation ContainerAPI

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

#pragma mark - CallToServer

/// Call Containers

- (void)containerCallWithBlock:(void (^)(BOOL isSuccess, NSArray *array, NSError *error))block {
    if (PAGINATE_SYNC_API) {
        PaginationCallsClass *paginate = [[PaginationCallsClass alloc] init];
        paginate.minimumNumberOfCalls = minimumNumberForCalls;
        paginate.limit = limitPerPage;
        paginate.pageNo = initialPageNo;
        paginate.apiCallString = Containers;
        paginate.apiCallFilePath = containerFilePath;
        [paginate callWithBlock:^(BOOL isSuccess, NSArray *array, NSError *error) {
            if (error) {
                if (block) {
                    block(NO, nil, nil);
                }
            } else {
                self.sqlRowArray = [self getContainersFromArray:array];
                if (block) {
                    block(YES, nil, nil);
                }
            }
        }];
    } else {
        NSDictionary *localStoreCallParamaters = [self paramtersFortheGETCall];
        if ([localStoreCallParamaters count] > 0) {
            [[AFAppDotNetAPIClient sharedClient] getPath:Containers parameters:localStoreCallParamaters success:^(AFHTTPRequestOperation *operation, id JSON) {
                id JSONLocal;
                BOOL successWrite= [self writeDataToFile:containerFilePath withContents:JSON];
                if (successWrite) {
                    JSONLocal = [self readDataFromFile:containerFilePath];
                }
                NSLog(@"ContainerLocal %@", JSONLocal);
                self.sqlRowArray = [self getContainersFromArray:JSONLocal];
                if (block) {
                    block(successWrite, nil, nil);
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                if (block) {
                    block(NO, nil, nil);
                }
            }];
        }
    }
}

- (void) downloadCompleteAndItsSafeToInsertDataInToDB {
    [self insertRowDataForDB:self.sqlRowArray];
}

-(void) saveApiResponseArray:(NSMutableArray *)array {
    self.sqlRowArray = [self getContainersFromArray:array];
    [self downloadCompleteAndItsSafeToInsertDataInToDB];
}


#pragma mark - Parse Methods

- (NSArray *) getContainersFromArray :(NSArray *) containerArrayBeforeProcessing {
    NSMutableArray *containerMutable = [[NSMutableArray alloc] init];
    if (containerArrayBeforeProcessing) {
        for (NSDictionary *containerDictionary in containerArrayBeforeProcessing) {
            Container *container = [self setAttributesFromMap:containerDictionary];
            [containerMutable addObject:container];
        }
    }
    return [containerMutable copy];
}

- (Container *)setAttributesFromMap:(NSDictionary*)dataMap {
    Container *container = [[Container alloc] init];
    if (dataMap) {
        container.name = [self parseStringFromJson:dataMap key:@"name"];
        container.displayName = [self parseStringFromJson:dataMap key:@"display"];
        container.containerID = [self parseIntegerFromJson:dataMap key:@"id"];
        container.parentID = [self parseIntegerFromJson:dataMap key:@"parent_id"];
        container.programID = [self parseIntegerFromJson:dataMap key:@"program_id"];
        container.picture_required = [self parseBoolFromJson:dataMap key:@"picture_required"];
        container.ratingPreProcessed = [self parseArrayFromJson:dataMap key:@"rating_conditions"];
        NSArray *ratingsFromContainers = [self parseArrayFromJson:dataMap key:@"rating_conditions"];
        NSMutableArray *ratingsArrayLocal = [[NSMutableArray alloc] init];
        if ([ratingsFromContainers count] > 0) {
            for (int i=0; i < [ratingsFromContainers count]; i++) {\
                Rating *rating = [[Rating alloc] init];
                OptionalSettings *optionalSettings = [[OptionalSettings alloc] init];
                PictureAndDefectThresholds *thresholds = [[PictureAndDefectThresholds alloc]init];
                rating.ratingID = [self parseIntegerFromJson:[ratingsFromContainers objectAtIndex:i] key:@"rating_id"];
                rating.optionalSettingsPreProcessed = [self parseDictFromJson:[ratingsFromContainers objectAtIndex:i] key:@"optional_settings"];
                optionalSettings.optional = [self parseBoolFromJson:[self parseDictFromJson:[ratingsFromContainers objectAtIndex:i] key:@"optional_settings"] key:@"optional"];
                optionalSettings.persistent = [self parseBoolFromJson:[self parseDictFromJson:[ratingsFromContainers objectAtIndex:i] key:@"optional_settings"] key:@"persistent"];
                optionalSettings.picture = [self parseBoolFromJson:[self parseDictFromJson:[ratingsFromContainers objectAtIndex:i] key:@"optional_settings"] key:@"picture"];
                optionalSettings.defects = [self parseBoolFromJson:[self parseDictFromJson:[ratingsFromContainers objectAtIndex:i] key:@"optional_settings"] key:@"defects"];
                optionalSettings.scannable = [self parseBoolFromJson:[self parseDictFromJson:[ratingsFromContainers objectAtIndex:i] key:@"optional_settings"] key:@"scannable"];
                optionalSettings.rating = [self parseBoolFromJson:[self parseDictFromJson:[ratingsFromContainers objectAtIndex:i] key:@"optional_settings"] key:@"rating"];
                rating.optionalSettings = optionalSettings;
                rating.thresholdsPreProcessed = [self parseDictFromJson:[ratingsFromContainers objectAtIndex:i] key:@"thresholds"];
                thresholds.picture = [self parseIntegerFromJson:[self parseDictFromJson:[ratingsFromContainers objectAtIndex:i] key:@"thresholds"] key:@"picture"];
                thresholds.defects = [self parseIntegerFromJson:[self parseDictFromJson:[ratingsFromContainers objectAtIndex:i] key:@"thresholds"] key:@"defects"];
                rating.pictureAndDefectThresholds = thresholds;
                [ratingsArrayLocal addObject:rating];
            }
        }
        container.ratingConditionsArray = [ratingsArrayLocal copy];
    }
    return container;
}

#pragma mark - SQL Methods

+ (NSString *) getTableCreateStatmentForContainer {
    NSString *sql =[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@", TBL_CONTAINERS];
    sql = [sql stringByAppendingString:@" ("];
    sql = [sql stringByAppendingFormat:@"%@ %@ %@,",COL_ID, SQLITE_TYPE_INTEGER, SQLITE_TYPE_PRIMARY_KEY];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_PROGRAM_ID, SQLITE_TYPE_INTEGER];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_PARENT_ID, SQLITE_TYPE_INTEGER];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_NAME, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_DISPLAY_NAME, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@",COL_PIC_REQUIRED, SQLITE_TYPE_INTEGER];
    sql = [sql stringByAppendingString:@")"];
    return sql;
}

+ (NSString *) getTableCreateStatmentForContainerRatingConditions {
    NSString *sql =[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@", TBL_CONTAINER_RATING_CONDITIONS];
    sql = [sql stringByAppendingString:@" ("];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_CONTAINER_ID,SQLITE_TYPE_INTEGER];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_PROGRAM_ID, SQLITE_TYPE_INTEGER];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_RATING_ID, SQLITE_TYPE_INTEGER];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_THRESHOLDS, SQLITE_TYPE_BLOB];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_OPTIONAL_SETTINGS, SQLITE_TYPE_BLOB];
    sql = [sql stringByAppendingFormat:@"UNIQUE(%@,%@) ON CONFLICT REPLACE",COL_CONTAINER_ID, COL_RATING_ID];
    sql = [sql stringByAppendingString:@")"];
    return sql;
}

#pragma mark - SQL Insert Methods

- (void) insertRowDataForDB: (NSArray *) containerArray {
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_INSIGHTS_DATA];
    [database open];
    for (int i=0; i < [containerArray count]; i++) {
        Container *container = [containerArray objectAtIndex:i];
        BOOL containersUpdateResponse = [database executeUpdate:@"insert or replace into CONTAINERS (id, program_id, parent_id, name, picture_required, display) values (?,?,?,?,?,?)", [NSString stringWithFormat:@"%ld", (long)container.containerID], [NSString stringWithFormat:@"%ld", (long)container.programID], [NSString stringWithFormat:@"%d", container.parentID], container.name, [NSString stringWithFormat:@"%d", container.picture_required], container.displayName];
        //NSLog(@"ContainerApi.m - TBL_CONTAINERS Insert or replace response - %d", containersUpdateResponse);
        for (Rating *rating in container.ratingConditionsArray) {
            NSData *dataOptionalSettings = [NSKeyedArchiver archivedDataWithRootObject:rating.optionalSettingsPreProcessed];
            NSData *dataThresholds = [NSKeyedArchiver archivedDataWithRootObject:rating.thresholdsPreProcessed];
            BOOL containersRatingsUpdateResponse = [database executeUpdate:@"insert or replace into CONTAINER_RATINGS_CONDITIONS (container_id, program_id, rating_id, thresholds, optional_settings) values (?,?,?,?,?)", [NSString stringWithFormat:@"%ld", (long)container.containerID], [NSString stringWithFormat:@"%ld", (long)container.programID], [NSString stringWithFormat:@"%d", rating.ratingID], dataThresholds, dataOptionalSettings];
            //NSLog(@"ContainerApi.m - TBL_CONTAINER_RATINGS_CONDITIONS Insert or replace response - %d", containersRatingsUpdateResponse);
        }
    }
    [database close];
}

@end
