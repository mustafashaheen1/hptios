//
//  InspectionMinimumsAPI.m
//  Insights
//
//  Created by Vineet on 2/27/18.
//  Copyright © 2018 Yottamark. All rights reserved.
//

#import "InspectionMinimumsAPI.h"
#import "PaginationCallsClass.h"
#import "JSONModel.h"


@implementation InspectionMinimumsAPI

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void) downloadCompleteAndItsSafeToInsertDataInToDB {
    [self insertRowDataForDB:self.inspectionMinimumsArray];
}

-(void) saveApiResponseArray:(NSMutableArray *)array {
    self.inspectionMinimumsArray = [self getInspectionMinimumsFromArray:array];
    [self downloadCompleteAndItsSafeToInsertDataInToDB];
}

#pragma mark - Parse Methods

- (NSArray *) getInspectionMinimumsFromArray :(NSMutableArray *) arrayBeforeProcessing {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    if (arrayBeforeProcessing) {
        for (NSMutableDictionary *dataMap in arrayBeforeProcessing) {
            NSMutableDictionary *dataMap2 = [dataMap mutableCopy];
            if([[dataMap2 valueForKey:@"rating_id"] isKindOfClass:[NSNull class]]){
                [dataMap2 removeObjectForKey:@"rating_id"];
                [dataMap2 setValue:[NSNumber numberWithInt:-1] forKey:@"rating_id"];
            }
            NSError *jsonParsingError;
            InspectionMinimums *inspectionMin = [[InspectionMinimums alloc] initWithDictionary:dataMap2 error:&jsonParsingError];
            //InspectionMinimums *inspectionMin = [self setAttributesFromMap:dataMap];
            [array addObject:inspectionMin];
        }
    }
    return [array copy];
}

#pragma mark - SQL Methods

+ (NSString *) getTableCreateStatment{
    NSString *sql =[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@", TBL_INSPECTION_MINIMUMS];
    sql = [sql stringByAppendingString:@" ("];
    sql = [sql stringByAppendingFormat:@"%@ %@ %@,",COL_ID, SQLITE_TYPE_TEXT,SQLITE_TYPE_PRIMARY_KEY];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_INSPECTION_MINIMUMS, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@",COL_INSPECTION_MINIMUMS_RATING_ID, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingString:@")"];
    return sql;
}

#pragma mark - SQL Insert Methods

- (void) insertRowDataForDB: (NSArray *) dataArray {
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_INSIGHTS_DATA];
    [database open];
    for (int i=0; i < [dataArray count]; i++) {
        InspectionMinimums *inspMin = [dataArray objectAtIndex:i];
        NSString *minId = [NSString stringWithFormat:@"%d", inspMin.id];
        NSString *minRatingId = [NSString stringWithFormat:@"%d", inspMin.rating_id];
        NSString *json = [inspMin toJSONString];
       [database executeUpdate:@"insert or replace into INSPECTION_MINIMUMS (id,INSPECTION_MINIMUMS,INSPECTION_MINIMUMS_RATING_ID) values (?,?,?)", minId,json,minRatingId];
    }
    [database close];
}

-(InspectionMinimums*)getMinimumInspectionForGroup:(int)productGroupId {
    InspectionMinimums* inspectionMinimum = [[InspectionMinimums alloc]init];
    //read from /groups
    NSString *queryAuditCount = [NSString stringWithFormat:@"SELECT %@ FROM %@ WHERE %@=%@", COL_INSPECTION_MINIMUMS_ID, TBL_GROUPS, COL_ID, [NSString stringWithFormat:@"%d", productGroupId]];
    FMDatabase *databaseGroupRatings = [[DBManager sharedDBManager] openDatabase:DB_INSIGHTS_DATA];
    FMResultSet *resultsGroupRatings;
    [databaseGroupRatings open];
    resultsGroupRatings = [databaseGroupRatings executeQuery:queryAuditCount];
    int inspectionMinimumId = -1;
    while ([resultsGroupRatings next]) {
        inspectionMinimumId = [resultsGroupRatings intForColumn:COL_INSPECTION_MINIMUMS_ID];
    }
    
    //read from /programs
    if(inspectionMinimumId<=0){
        int programId = [NSUserDefaultsManager getIntegerFromUserDeafults:SelectedProgramId];
        NSString *queryAuditCount = [NSString stringWithFormat:@"SELECT %@ FROM %@ WHERE %@=%@", COL_INSPECTION_MINIMUMS_ID, TBL_PROGRAMS, COL_ID, [NSString stringWithFormat:@"%d", programId]];
        FMDatabase *databaseGroupRatings = [[DBManager sharedDBManager] openDatabase:DB_INSIGHTS_DATA];
        FMResultSet *resultsGroupRatings;
        [databaseGroupRatings open];
        resultsGroupRatings = [databaseGroupRatings executeQuery:queryAuditCount];
        while ([resultsGroupRatings next]) {
            inspectionMinimumId = [resultsGroupRatings intForColumn:COL_INSPECTION_MINIMUMS_ID];
        }
    }
    
    //parse the minimums array and store in self
    
    if(inspectionMinimumId>0){
        NSString *queryAuditCount = [NSString stringWithFormat:@"SELECT %@ FROM %@ WHERE %@=%@", COL_INSPECTION_MINIMUMS, TBL_INSPECTION_MINIMUMS, COL_ID, [NSString stringWithFormat:@"%d", inspectionMinimumId]];
        FMDatabase *databaseGroupRatings = [[DBManager sharedDBManager] openDatabase:DB_INSIGHTS_DATA];
        FMResultSet *resultsGroupRatings;
        [databaseGroupRatings open];
        resultsGroupRatings = [databaseGroupRatings executeQuery:queryAuditCount];
        while ([resultsGroupRatings next]) {
            NSString* json = [resultsGroupRatings stringForColumn:COL_INSPECTION_MINIMUMS];
            NSError *error;
            inspectionMinimum = [[InspectionMinimums alloc]initWithString:json error:&error];
        }
    }
    return inspectionMinimum;
}

@end
