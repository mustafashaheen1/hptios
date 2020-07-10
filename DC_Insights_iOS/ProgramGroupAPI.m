//
//  ProgramGroupAPI.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/27/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "ProgramGroupAPI.h"
#import "DBManager.h"
#import "ProgramGroup.h"
#import "Rating.h"
#import "PictureAndDefectThresholds.h"
#import "PaginationCallsClass.h"
#import "RatingJSONModel.h"

@implementation ProgramGroupAPI

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

/// Call Programs Groups

- (void)programsGroupsCallWithBlock:(void (^)(BOOL isSuccess, NSArray *array, NSError *error))block {
    if (PAGINATE_SYNC_API) {
        PaginationCallsClass *paginate = [[PaginationCallsClass alloc] init];
        paginate.minimumNumberOfCalls = minimumNumberForCalls;
        paginate.limit = limitPerPage;
        paginate.pageNo = initialPageNo;
        paginate.apiCallString = ProgramsGroups;
        paginate.apiCallFilePath = ProgramsGroupsFilePath;
        [paginate callWithBlock:^(BOOL isSuccess, NSArray *array, NSError *error) {
            if (error) {
                if (block) {
                    block(NO, nil, nil);
                }
            } else {
                self.programArray = [self getProgramsFromArray:array];
                if (block) {
                    block(YES, nil, nil);
                }
            }
        }];
    } else {
        NSDictionary *localStoreCallParamaters = [self paramtersFortheGETCall];
        if ([localStoreCallParamaters count] > 0) {
            [[AFAppDotNetAPIClient sharedClient] getPath:ProgramsGroups parameters:localStoreCallParamaters success:^(AFHTTPRequestOperation *operation, id JSON) {
                id JSONLocal;
                BOOL successWrite= [self writeDataToFile:ProgramsFilePath withContents:JSON];
                if (successWrite) {
                    JSONLocal = [self readDataFromFile:ProgramsFilePath];
                }
                NSLog(@"ProgramGroupLocal %@", JSONLocal);
                self.programArray = [self getProgramsFromArray:JSONLocal];
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
    [self insertRowDataForDB:self.programArray];
}

-(void) saveApiResponseArray:(NSMutableArray *)array {
    self.programArray = [self getProgramsFromArray:array];
    [self downloadCompleteAndItsSafeToInsertDataInToDB];
}

#pragma mark - Parse Methods

- (NSArray *) getProgramsFromArray :(NSArray *) programArrayBeforeProcessing {
    NSMutableArray *programMutable = [[NSMutableArray alloc] init];
    if (programArrayBeforeProcessing) {
        for (NSDictionary *programDictionary in programArrayBeforeProcessing) {
            ProgramGroup *programGroup = [self setAttributesFromMap:programDictionary];
            [programMutable addObject:programGroup];
        }
    }
    return [programMutable copy];
}

- (ProgramGroup *)setAttributesFromMap:(NSDictionary*)dataMap {
    ProgramGroup *programGroup = [[ProgramGroup alloc] init];
    
    if (dataMap) {
        programGroup.audit_count = [self parseIntegerFromJson:dataMap key:@"audit_count"];
        programGroup.inspectionMinimumId = [self parseIntegerFromJson:dataMap key:@"inspection_minimum_id"];
        programGroup.programGroupID = [self parseIntegerFromJson:dataMap key:@"id"];
        programGroup.name = [self parseStringFromJson:dataMap key:@"name"];
        programGroup.program_id = [self parseIntegerFromJson:dataMap key:@"program_id"];
        programGroup.ratingsPreProcessed = [self parseArrayFromJson:dataMap key:@"ratings"];
        programGroup.containers = [self parseArrayFromJson:dataMap key:@"containers"];
        
        //audit_count_data
        NSDictionary* auditCountDataObject =[self parseDictFromJson:dataMap key:@"audit_count_data"];
        programGroup.audit_count_data = auditCountDataObject;
        NSMutableArray *ratingsMutableArray = [[NSMutableArray alloc] init];
        NSArray *ratingsFromProgramGroups = [self parseArrayFromJson:dataMap key:@"ratings"];
        //NSString *stringByAppendingRatingString = @"";
        if ([ratingsFromProgramGroups count] > 0) {
            for (int i=0; i < [ratingsFromProgramGroups count]; i++) {
                Rating *rating = [[Rating alloc] init];
                OptionalSettings *optionalSettings = [[OptionalSettings alloc] init];
                PictureAndDefectThresholds *thresholds = [[PictureAndDefectThresholds alloc]init];
                rating.defect_family_id = [self parseIntegerFromJson:[ratingsFromProgramGroups objectAtIndex:i] key:@"defect_family_id"];
                if (rating.defect_family_id == -1) {
                    rating.defect_family_id = 0;
                }
                rating.defects = [[self parseArrayFromJson:[ratingsFromProgramGroups objectAtIndex:i] key:@"defects"] copy];
                rating.ratingID = [self parseIntegerFromJson:[ratingsFromProgramGroups objectAtIndex:i] key:@"id"];
                rating.order_position = [self parseIntegerFromJson:[ratingsFromProgramGroups objectAtIndex:i] key:@"order_position"];
                rating.default_star = [self parseIntegerFromJson:[ratingsFromProgramGroups objectAtIndex:i] key:@"default_star"]; //default_star
                rating.optionalSettingsPreProcessed = [self parseDictFromJson:[ratingsFromProgramGroups objectAtIndex:i] key:@"optional_settings"];
                optionalSettings.optional = [self parseBoolFromJson:[self parseDictFromJson:[ratingsFromProgramGroups objectAtIndex:i] key:@"optional_settings"] key:@"optional"];
                optionalSettings.persistent = [self parseBoolFromJson:[self parseDictFromJson:[ratingsFromProgramGroups objectAtIndex:i] key:@"optional_settings"] key:@"persistent"];
                optionalSettings.picture = [self parseBoolFromJson:[self parseDictFromJson:[ratingsFromProgramGroups objectAtIndex:i] key:@"optional_settings"] key:@"picture"];
                optionalSettings.defects = [self parseBoolFromJson:[self parseDictFromJson:[ratingsFromProgramGroups objectAtIndex:i] key:@"optional_settings"] key:@"defects"];
                optionalSettings.scannable = [self parseBoolFromJson:[self parseDictFromJson:[ratingsFromProgramGroups objectAtIndex:i] key:@"optional_settings"] key:@"scannable"];
                optionalSettings.rating = [self parseBoolFromJson:[self parseDictFromJson:[ratingsFromProgramGroups objectAtIndex:i] key:@"optional_settings"] key:@"rating"];
                rating.optionalSettings = optionalSettings;
                thresholds.picture = [self parseIntegerFromJson:[self parseDictFromJson:[ratingsFromProgramGroups objectAtIndex:i] key:@"thresholds"] key:@"picture"];
                thresholds.defects = [self parseIntegerFromJson:[self parseDictFromJson:[ratingsFromProgramGroups objectAtIndex:i] key:@"thresholds"] key:@"defects"];
                rating.thresholdsPreProcessed = [self parseDictFromJson:[ratingsFromProgramGroups objectAtIndex:i] key:@"thresholds"];
                rating.pictureAndDefectThresholds = thresholds;
                [ratingsMutableArray addObject:rating];
            }
//            for (int i=0; i < [ratingsFromProgramGroups count]; i++) {
//                RatingJSONModel *ratingJSONModel = [[RatingJSONModel alloc] init];
//                OptionalSettings *optionalSettings = [[OptionalSettings alloc] init];
//                PictureAndDefectThresholds *thresholds = [[PictureAndDefectThresholds alloc]init];
//                int defectFamilyIdLocal = [self parseIntegerFromJson:[ratingsFromProgramGroups objectAtIndex:i] key:@"defect_family_id"];
//                ratingJSONModel.defect_family_id = [NSString stringWithFormat:@"%d", defectFamilyIdLocal];
//                if (defectFamilyIdLocal < 0) {
//                    ratingJSONModel.defect_family_id = @"0";
//                }
//                ratingJSONModel.defects = [[self parseArrayFromJson:[ratingsFromProgramGroups objectAtIndex:i] key:@"defects"] copy];
//                ratingJSONModel.ratingID = [self parseIntegerFromJson:[ratingsFromProgramGroups objectAtIndex:i] key:@"id"];
//                ratingJSONModel.order_position = [self parseIntegerFromJson:[ratingsFromProgramGroups objectAtIndex:i] key:@"order_position"];
//                optionalSettings.optional = [self parseBoolFromJson:[self parseDictFromJson:[ratingsFromProgramGroups objectAtIndex:i] key:@"optional_settings"] key:@"optional"];
//                optionalSettings.persistent = [self parseBoolFromJson:[self parseDictFromJson:[ratingsFromProgramGroups objectAtIndex:i] key:@"optional_settings"] key:@"persistent"];
//                optionalSettings.picture = [self parseBoolFromJson:[self parseDictFromJson:[ratingsFromProgramGroups objectAtIndex:i] key:@"optional_settings"] key:@"picture"];
//                optionalSettings.defects = [self parseBoolFromJson:[self parseDictFromJson:[ratingsFromProgramGroups objectAtIndex:i] key:@"optional_settings"] key:@"defects"];
//                optionalSettings.scannable = [self parseBoolFromJson:[self parseDictFromJson:[ratingsFromProgramGroups objectAtIndex:i] key:@"optional_settings"] key:@"scannable"];
//                ratingJSONModel.optionalSettings = optionalSettings;
//                thresholds.picture = [self parseIntegerFromJson:[self parseDictFromJson:[ratingsFromProgramGroups objectAtIndex:i] key:@"thresholds"] key:@"picture"];
//                thresholds.defects = [self parseIntegerFromJson:[self parseDictFromJson:[ratingsFromProgramGroups objectAtIndex:i] key:@"thresholds"] key:@"defects"];
//                ratingJSONModel.pictureAndDefectThresholds = thresholds;
//                NSString *ratingChangedToString = [ratingJSONModel toJSONString];
//                stringByAppendingRatingString = [stringByAppendingRatingString stringByAppendingString:ratingChangedToString];
//                if (i != [ratingsFromProgramGroups count]-1) {
//                    stringByAppendingRatingString = [stringByAppendingRatingString stringByAppendingString:parseIdentifier];
//                }
//            }
        }
        programGroup.ratings = [ratingsMutableArray copy];
    }
    return programGroup;
}


#pragma mark - SQL Methods

+ (NSString *) getTableCreateStatmentForProgramsGroups {
    NSString *sql =[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@", TBL_GROUPS];
    sql = [sql stringByAppendingString:@" ("];
    sql = [sql stringByAppendingFormat:@"%@ %@ %@,",COL_ID, SQLITE_TYPE_TEXT,SQLITE_TYPE_PRIMARY_KEY];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_GROUP_ID, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_NAME, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_INSPECTION_MINIMUMS_ID, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_AUDIT_COUNT, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_RATINGS, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_AUDIT_COUNT_DATA, SQLITE_TYPE_BLOB];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_CONTAINERS, SQLITE_TYPE_BLOB];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_RATINGS_ID_ARRAY, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@",COL_PROGRAM_ID, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingString:@")"];
    return sql;
}

+ (NSString *) getTableCreateStatmentForProgramsGroupsRatings {
    NSString *sql =[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@", TBL_GROUP_RATINGS];
    sql = [sql stringByAppendingString:@" ("];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_ID, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_GROUP_ID, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_DEFAULT_STAR, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_ORDER_POSITION, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_DEFECT_FAMILY_ID, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_DEFECTS, SQLITE_TYPE_BLOB];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_OPTIONAL_SETTINGS, SQLITE_TYPE_BLOB];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_THRESHOLDS, SQLITE_TYPE_BLOB];
    sql = [sql stringByAppendingFormat:@"UNIQUE(%@,%@) ON CONFLICT REPLACE",COL_ID, COL_GROUP_ID];
    sql = [sql stringByAppendingString:@")"];
    return sql;
}

#pragma mark - SQL Insert Methods

- (void) insertRowDataForDB: (NSArray *) programArray {
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_INSIGHTS_DATA];
    [database open];
    for (int i=0; i < [programArray count]; i++) {
        ProgramGroup *programGroup = [programArray objectAtIndex:i];
        NSData *dataContainers;
        if ([programGroup.containers count] > 0) {
            dataContainers = [NSKeyedArchiver archivedDataWithRootObject:programGroup.containers];
        }
        NSData *dataRatings = [NSKeyedArchiver archivedDataWithRootObject:programGroup.ratingsPreProcessed];
        NSData *audit_count_data = [NSKeyedArchiver archivedDataWithRootObject:programGroup.audit_count_data];
        //avoid creating duplicate rows 
//        [database executeUpdate:@"insert into GROUPS (id, name, audit_count, program_id, ratings, containers,audit_count_data) values (?,?,?,?,?,?,?)", [NSString stringWithFormat:@"%d", programGroup.programGroupID], programGroup.name, [NSString stringWithFormat:@"%d", programGroup.audit_count], [NSString stringWithFormat:@"%d", programGroup.program_id], dataRatings, dataContainers,audit_count_data];
        NSMutableArray *ratingIdsArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < [programGroup.ratings count]; i++) {
            Rating *rating = [programGroup.ratings objectAtIndex:i];
            NSString *ratingString = [NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"%d", rating.ratingID]];
            ratingString = [ratingString stringByAppendingString:@","];
            ratingString = [ratingString stringByAppendingString:[NSString stringWithFormat:@"%d", rating.defect_family_id]];
            [ratingIdsArray addObject:ratingString];
        }
        NSData *dataRatingsIdArray = [NSKeyedArchiver archivedDataWithRootObject:ratingIdsArray];
        BOOL groupsResponse = [database executeUpdate:@"insert or replace into GROUPS (id, name, INSPECTION_MIN_ID,audit_count, program_id, ratings, ratingIdsArray,containers,audit_count_data) values (?,?,?,?,?,?,?,?,?)", [NSString stringWithFormat:@"%d", programGroup.programGroupID], programGroup.name, [NSString stringWithFormat:@"%d", programGroup.inspectionMinimumId], [NSString stringWithFormat:@"%d", programGroup.audit_count], [NSString stringWithFormat:@"%d", programGroup.program_id], dataRatings, dataRatingsIdArray,dataContainers,audit_count_data];
        //NSLog(@"ProgramGroupApi.m - TBL_GROUPS Insert or replace response - %d", groupsResponse);

        //delete the existing ratings for this groupID - to avoid duplicate ratings/mismatch during incremental sync
        NSString* groupId = [NSString stringWithFormat:@"%d", (int)programGroup.programGroupID];
        NSString *deleteQuery = [NSString stringWithFormat:@"Delete from %@ where %@='%@'",TBL_GROUP_RATINGS,COL_GROUP_ID,groupId];
        [database executeUpdate:deleteQuery];
        
        for (int i = 0; i < [programGroup.ratings count]; i++) {
            Rating *rating = [programGroup.ratings objectAtIndex:i];
            NSData *dataDefects = [NSKeyedArchiver archivedDataWithRootObject:rating.defects];
            NSData *dataOptionalSettings = [NSKeyedArchiver archivedDataWithRootObject:rating.optionalSettingsPreProcessed];
            NSData *dataThresholds = [NSKeyedArchiver archivedDataWithRootObject:rating.thresholdsPreProcessed];
            BOOL groupRatingsResponse =[database executeUpdate:@"insert or replace into GROUP_RATINGS (id, group_id, default_star, order_position, defect_family_id, defects, optional_settings, thresholds) values (?,?,?,?,?,?,?,?)", [NSString stringWithFormat:@"%d", rating.ratingID], [NSString stringWithFormat:@"%d", programGroup.programGroupID], [NSString stringWithFormat:@"%d", rating.default_star] , [NSString stringWithFormat:@"%d", rating.order_position], [NSString stringWithFormat:@"%d", rating.defect_family_id], dataDefects, dataOptionalSettings, dataThresholds];
            //NSLog(@"ProgramGroupApi.m - TBL_GROUP_RATINGS Insert or replace response - %d", groupRatingsResponse);
        }
    }
    [database close];
}

@end
