//
//  AuditsDBHelper.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 4/23/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "AuditsDBHelper.h"
#import "DBConstants.h"
#import "DBManager.h"

@implementation AuditsDBHelper

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void) createAllTables {
    //create default Api Mapping tables
    NSMutableArray *createStatements = [[NSMutableArray alloc] init];
    [createStatements addObject:[self getTableCreateStatmentForAuditsDB]];
    [createStatements addObject:[self getTableCreateStatmentForUserStores]];
    [createStatements addObject:[self getSubmittedAuditsTableCreateStatmentForAuditsDB]];
    [[DBManager sharedDBManager] executeUpdateUsingFMDataBase:[createStatements copy] withDatabasePath:DB_OFFLINE_DATA];
}

- (void) deleteAllTables {
    //    NSMutableArray *deleteStatements = [[NSMutableArray alloc] init];
    //    [deleteStatements addObject:TBL_USERS];
    //
    //    [[DBManager sharedDBManager] deleteTableUsingFMDataBase:[deleteStatements copy] withDatabasePath:DB_APP_DATA];
}


- (NSString *) getTableCreateStatmentForAuditsDB {
    NSString *sql =[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@", TBL_COMPLETED_AUDITS];
    sql = [sql stringByAppendingString:@" ("];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_ID, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_RATINGS, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_AUDIT_IMAGE, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_DATA_SUBMITTED, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_IMAGE_SUBMITTED, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@",COL_DATA_COMPLETED_TIME, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingString:@")"];
    return sql;
}

- (NSString *) getSubmittedAuditsTableCreateStatmentForAuditsDB {
    NSString *sql =[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@", TBL_SUBMITTED_AUDITS];
    sql = [sql stringByAppendingString:@" ("];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_ID, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_RATINGS, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_AUDIT_COUNT, SQLITE_TYPE_INTEGER];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_IMAGE_COUNT, SQLITE_TYPE_INTEGER];
    sql = [sql stringByAppendingFormat:@"%@ %@",COL_DATE_SUBMITTED, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingString:@")"];
    return sql;
}

- (NSString *) getTableCreateStatmentForUserStores {
    NSString *sql =[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@", TBL_USER_ENTERED_STORES];
    sql = [sql stringByAppendingString:@" ("];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_ID, SQLITE_TYPE_INTEGER];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_NAME, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_ADDRESS, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_CHAIN_NAME, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_LAT, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_LON, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_CITY, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_STATE, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@",COL_POSTCODE, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingString:@")"];
    return sql;
}



@end
