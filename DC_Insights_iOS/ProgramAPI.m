//
//  Program.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/11/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "ProgramAPI.h"
#import "Program.h"
#import "Store.h"
#import "ProgramGroup.h"
#import "DBManager.h"
#import "User.h"
#import "PaginationCallsClass.h"

@implementation ProgramAPI

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

#pragma mark - CallToServer

/// Call Programs

- (void)programsCallWithBlock:(void (^)(BOOL isSuccess, NSArray *array, NSError *error))block {
    if (PAGINATE_SYNC_API) {
        PaginationCallsClass *paginate = [[PaginationCallsClass alloc] init];
        paginate.minimumNumberOfCalls = minimumNumberForCalls;
        paginate.limit = limitPerPage;
        paginate.pageNo = initialPageNo;
        paginate.apiCallString = Programs;
        paginate.apiCallFilePath = ProgramsFilePath;
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
            [[AFAppDotNetAPIClient sharedClient] getPath:Programs parameters:localStoreCallParamaters success:^(AFHTTPRequestOperation *operation, id JSON) {
                id JSONLocal;
                BOOL successWrite= [self writeDataToFile:ProgramsFilePath withContents:JSON];
                if (successWrite) {
                    JSONLocal = [self readDataFromFile:ProgramsFilePath];
                }
                NSLog(@"JSONLocal %@", JSONLocal);
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

- (void)programsCallForChecking:(void (^)(BOOL isSuccess, NSArray *array, NSError *error))block {
    NSDictionary *localStoreCallParamaters = [self paramtersFortheGETCall];
    if ([localStoreCallParamaters count] > 0) {
        [[AFAppDotNetAPIClient sharedClient] getPath:Programs parameters:localStoreCallParamaters success:^(AFHTTPRequestOperation *operation, id JSON) {
            NSLog(@"JSONLocal %@", JSON);
            BOOL same = [[User sharedUser] doWhatNeedsTobeDoneIfTheArrayIsEqualOrNot:[[User sharedUser] checkIfTheUserBelongsToTheTeam:[self getProgramsFromArray:JSON]]];
            if (block) {
                block(same, nil, nil);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (block) {
                block(NO, nil, nil);
            }
        }];
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
            Program *program = [self setAttributesFromMap:programDictionary];
            [programMutable addObject:program];
        }
    }
    return [programMutable copy];
}

- (Program *)setAttributesFromMap:(NSDictionary*)dataMap {
    Program *program = [[Program alloc] init];
    if (dataMap) {
        program.active = [self parseBoolFromJson:dataMap key:@"active"];
        program.end_date = [self parseDateFromJson:dataMap key:@"end_date"];
        program.end_datePreProcessed = [self parseStringFromJson:dataMap key:@"end_date"];
        program.programID = [self parseIntegerFromJson:dataMap key:@"id"];
        program.name = [self parseStringFromJson:dataMap key:@"name"];
        program.start_date = [self parseDateFromJson:dataMap key:@"start_date"];
        program.start_datePreProcessed = [self parseStringFromJson:dataMap key:@"start_date"];
        program.storeIds = [self parseArrayFromJson:dataMap key:@"store_ids"];
        program.version = [self parseIntegerFromJson:dataMap key:@"version"];
        program.distinct_products = [self parseBoolFromJson:dataMap key:@"distinct_products"];
        program.inspectionMinimumId = [self parseIntegerFromJson:dataMap key:@"inspection_minimum_id"];
        program.apply_to_all = [self getApplyToAll:dataMap];
    }
    return program;
}

#pragma mark - SQL Methods

+ (NSString *) getTableCreateStatmentForPrograms {
    NSString *sql =[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@", TBL_PROGRAMS];
    sql = [sql stringByAppendingString:@" ("];
    sql = [sql stringByAppendingFormat:@"%@ %@ %@,",COL_ID, SQLITE_TYPE_TEXT,SQLITE_TYPE_PRIMARY_KEY];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_NAME, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_INSPECTION_MINIMUMS_ID, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_START_DATE, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_END_DATE, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_STORE_IDS, SQLITE_TYPE_BLOB];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_VERSION, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_DISTINCT_PRODUCTS, SQLITE_TYPE_INTEGER];
    sql = [sql stringByAppendingFormat:@"%@ %@", COL_APPLY_TO_ALL, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingString:@")"];
    return sql;
}

#pragma mark - SQL Insert Methods

- (void) insertRowDataForDB: (NSArray *) programArray {
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_INSIGHTS_DATA];
    [database open];
    for (int i=0; i < [programArray count]; i++) {
        Program *program = [programArray objectAtIndex:i];
        NSString *programID = [NSString stringWithFormat:@"%d", program.programID];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:program.storeIds];
        NSString* applyToAll = [program.apply_to_all toJSONString];
      //  NSLog(@"Response is:  %@", applyToAll);
        NSString *device_id = [DeviceManager getDeviceID];
               NSString *access_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"];
               NSLog(@"Device ID: %@",device_id);
               NSLog(@"Access is: %@",access_token);
        BOOL response = [database executeUpdate:@"insert or replace into PROGRAMS (id, name, INSPECTION_MIN_ID, start_date, end_date, store_ids, version, distinct_products,apply_to_all) values (?,?,?,?,?,?,?,?,?)",
                         programID,
                         program.name,
                         [NSString stringWithFormat:@"%d", program.inspectionMinimumId],
                         program.start_datePreProcessed,
                         program.end_datePreProcessed,
                         data,
                         [NSString stringWithFormat:@"%d", program.version],
                         [NSString stringWithFormat:@"%d", program.distinct_products],
                         applyToAll];
        //NSLog(@"ProgramApi.m - TBL_PROGRAMS Insert or replace response - %d", response);
    }
    [database close];
}

-(ApplyToAll*) getApplyToAll:(NSDictionary*)dataMap {
    ApplyToAll* applyToAll = [[ApplyToAll alloc] initFromJSONDictionary:dataMap];
    return applyToAll;
    
}

@end
