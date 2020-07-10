//
//  DefectFamiliesAPI.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/27/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "DefectFamiliesAPI.h"
#import "DBManager.h"
#import "DefectFamilies.h"
#import "PaginationCallsClass.h"

@implementation DefectFamiliesAPI

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

/// Call Defects Families

- (void)defectsFamiliesCallWithBlock:(void (^)(BOOL isSuccess, NSArray *array, NSError *error))block {
    if (PAGINATE_SYNC_API) {
        PaginationCallsClass *paginate = [[PaginationCallsClass alloc] init];
        paginate.minimumNumberOfCalls = minimumNumberForCalls;
        paginate.limit = limitPerPage;
        paginate.pageNo = initialPageNo;
        paginate.apiCallString = DefectsFamilies;
        paginate.apiCallFilePath = defectsFamiliesFilePath;
        [paginate callWithBlock:^(BOOL isSuccess, NSArray *array, NSError *error) {
            if (error) {
                if (block) {
                    block(NO, nil, nil);
                }
            } else {
                self.defectsArray = [self getDefectsFromArray:array];
                if (block) {
                    block(YES, nil, nil);
                }
            }
        }];
    } else {
        NSDictionary *localStoreCallParamaters = [self paramtersFortheGETCall];
        if ([localStoreCallParamaters count] > 0) {
            [[AFAppDotNetAPIClient sharedClient] getPath:DefectsFamilies parameters:localStoreCallParamaters success:^(AFHTTPRequestOperation *operation, id JSON) {
                id JSONLocal;
                BOOL successWrite= [self writeDataToFile:defectsFamiliesFilePath withContents:JSON];
                if (successWrite) {
                    JSONLocal = [self readDataFromFile:defectsFamiliesFilePath];
                }
                NSLog(@"JSONLocal %@", JSONLocal);
                self.defectsArray = [self getDefectsFromArray:JSONLocal];
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
    [self insertRowDataForDB:self.defectsArray];
}

-(void) saveApiResponseArray:(NSMutableArray *)array {
    self.defectsArray = [self getDefectsFromArray:array];
    [self downloadCompleteAndItsSafeToInsertDataInToDB];
}

#pragma mark - Parse Methods

- (NSArray *) getDefectsFromArray :(NSArray *) defectArrayBeforeProcessing {
    NSMutableArray *defectMutable = [[NSMutableArray alloc] init];
    if (defectArrayBeforeProcessing) {
        for (NSDictionary *containerDictionary in defectArrayBeforeProcessing) {
            DefectFamilies *defectFamilies = [self setAttributesFromMap:containerDictionary];
            [defectMutable addObject:defectFamilies];
        }
    }
    return [defectMutable copy];
}


- (DefectFamilies *)setAttributesFromMap:(NSDictionary*)dataMap {
    DefectFamilies *defectFamilies = [[DefectFamilies alloc] init];
    if (dataMap) {
        defectFamilies.description = [self parseStringFromJson:dataMap key:@"description"];
        defectFamilies.display = [self parseStringFromJson:dataMap key:@"display"];
        defectFamilies.defectID = [self parseIntegerFromJson:dataMap key:@"id"];
        defectFamilies.name = [self parseStringFromJson:dataMap key:@"name"];
        defectFamilies.variety_id = [self parseIntegerFromJson:dataMap key:@"variety_id"];
        defectFamilies.total = [self parseIntegerFromJson:dataMap key:@"total"];
        defectFamilies.acceptWithIssuesTotal = [self parseIntegerFromJson:dataMap key:@"accept_issues_total"];
        defectFamilies.defectsArray = [self parseArrayFromJson:dataMap key:@"defects"];
        defectFamilies.defectsArrayPreProcessed = [dataMap objectForKey:@"defects"];
        defectFamilies.qualityManualPreProcessed = [self parseDictFromJson:dataMap key:@"quality_manual"];
        defectFamilies.severityTotals = [self parseArrayFromJson:dataMap key:@"severity_totals"];
    }
    return defectFamilies;
}


#pragma mark - SQL Methods

+ (NSString *) getTableCreateStatmentForDefectsFamilies {
    NSString *sql =[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@", TBL_DEFECT_FAMILIES];
    sql = [sql stringByAppendingString:@" ("];
    sql = [sql stringByAppendingFormat:@"%@ %@ %@,",COL_ID, SQLITE_TYPE_INTEGER,SQLITE_TYPE_PRIMARY_KEY];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_NAME, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_DISPLAY_NAME, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_DESCRIPTION, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_TOTAL, SQLITE_TYPE_INTEGER];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_ACCEPT_ISSUES_TOTAL, SQLITE_TYPE_INTEGER];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_DEFECTS, SQLITE_TYPE_BLOB];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_SEVERITY_TOTALS, SQLITE_TYPE_BLOB];
    sql = [sql stringByAppendingFormat:@"%@ %@",COL_QUALITY_MANUAL_CONTENT, SQLITE_TYPE_BLOB];
    
    sql = [sql stringByAppendingString:@")"];
    return sql;
}

#pragma mark - SQL Insert Methods

//- (NSArray *) insertRowDataForDB: (NSArray *) defectsArray {
//    NSMutableArray *sqlRowArray = [[NSMutableArray alloc] init];
//    if ([defectsArray count] > 0) {
//        for (int i=0; i < [defectsArray count]; i++) {
//            DefectFamilies *defectFamilies = [defectsArray objectAtIndex:i];
//            NSData *dataDefects = [NSKeyedArchiver archivedDataWithRootObject:defectFamilies.defectsArrayPreProcessed];
//            NSString *sql =[NSString stringWithFormat:@"INSERT INTO %@", TBL_DEFECT_FAMILIES];
//            sql = [sql stringByAppendingString:@" ("];
//            sql = [sql stringByAppendingFormat:@"%@,%@,%@,%@,%@,%@", COL_ID, COL_NAME, COL_DISPLAY_NAME, COL_DESCRIPTION, COL_TOTAL, COL_DEFECTS];
//            sql = [sql stringByAppendingString:@")"];
//            sql = [sql stringByAppendingString:@" VALUES "];
//            sql = [sql stringByAppendingString:@"("];
//            sql = [sql stringByAppendingFormat:@"%d,'%@','%@','%@',%d,'%@'", defectFamilies.defectID, defectFamilies.name, defectFamilies.display, defectFamilies.description, defectFamilies.total, dataDefects];
//            sql = [sql stringByAppendingString:@");"];
//            [sqlRowArray addObject:sql];
//        }
//    }
//    return [sqlRowArray copy];
//}

- (void) insertRowDataForDB: (NSArray *) defectsArray {
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_INSIGHTS_DATA];
    [database open];
    for (int i=0; i < [defectsArray count]; i++) {
        DefectFamilies *defectFamilies = [defectsArray objectAtIndex:i];
        NSData *dataDefects = [NSKeyedArchiver archivedDataWithRootObject:defectFamilies.defectsArrayPreProcessed];
        NSString *defectId = [NSString stringWithFormat:@"%d", defectFamilies.defectID];
        NSString *total = [NSString stringWithFormat:@"%d", defectFamilies.total];
        NSString *acceptWithIssuesTotal = [NSString stringWithFormat:@"%d", defectFamilies.acceptWithIssuesTotal];
        NSData *qualityManual =[NSKeyedArchiver archivedDataWithRootObject:defectFamilies.qualityManualPreProcessed];
        NSData *severityTotals = [NSKeyedArchiver archivedDataWithRootObject:defectFamilies.severityTotals];
        BOOL response = [database executeUpdate:@"insert or replace into DEFECT_FAMILIES (id, name, display, description, total, accept_issues_total, defects,quality_manual_content, severity_totals) values (?,?,?,?,?,?,?,?,?)", defectId, defectFamilies.name, defectFamilies.display, defectFamilies.description, total, acceptWithIssuesTotal, dataDefects,qualityManual, severityTotals];
        NSLog(@"DefectFamiliesApi.m - TBL_DEFECT_FAMILIES Insert or replace response - %d", response);
    }
    [database close];
}



@end
