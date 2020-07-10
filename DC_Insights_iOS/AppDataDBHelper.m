//
//  AppDataDBHelper.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/31/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "AppDataDBHelper.h"
#import "UserAPI.h"
#import "CollabLocalUpdatesDB.h"
#import "CollabSaveDB.h"

@implementation AppDataDBHelper

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
    [createStatements addObject:[UserAPI getTableCreateStatmentForUser]];
    [createStatements addObject:[self getTableCreateStatmentForSavedAuditsTable]];
    [createStatements addObject:[self getTableCreateStatmentForSavedContainersTable]];
    [createStatements addObject:[self getTableCreateStatmentForSummary]];
    [createStatements addObject:[self getTableCreateStatmentForCollaborativeLocalUpdatesDB]];
    [createStatements addObject:[self getIndexStatementForCollaborativeLocalUpdatesDB]];
    [createStatements addObject:[self getTableCreateStatmentForCollaborativeSaveRequestsDB]];

    [[DBManager sharedDBManager] executeUpdateUsingFMDataBase:[createStatements copy] withDatabasePath:DB_APP_DATA];
}

- (void) createTablesForSavedAudits {
    NSMutableArray *createStatements = [[NSMutableArray alloc] init];
    [createStatements addObject:[self getTableCreateStatmentForSavedAuditsTable]];
    [createStatements addObject:[self getTableCreateStatmentForSavedContainersTable]];
    [createStatements addObject:[self getTableCreateStatmentForSummary]];
    [createStatements addObject:[self getTableCreateStatmentForCollaborativeLocalUpdatesDB]];
    [createStatements addObject:[self getIndexStatementForCollaborativeLocalUpdatesDB]];
    [createStatements addObject:[self getTableCreateStatmentForCollaborativeSaveRequestsDB]];
    [[DBManager sharedDBManager] executeUpdateUsingFMDataBase:[createStatements copy] withDatabasePath:DB_APP_DATA];
}

- (void) deleteAllTables {
    NSMutableArray *deleteStatements = [[NSMutableArray alloc] init];
    [deleteStatements addObject:TBL_SAVED_AUDITS];
    [deleteStatements addObject:TBL_SAVED_CONTAINERS];
    [deleteStatements addObject:TBL_SAVED_SUMMARY];
    [deleteStatements addObject:TBL_COLLABORATIVE_LOCAL_UPDATES];
    [deleteStatements addObject:TBL_COLLABORATIVE_SAVE_REQUESTS];

    [[DBManager sharedDBManager] deleteTableUsingFMDataBase:[deleteStatements copy] withDatabasePath:DB_APP_DATA];
}


- (NSString *) getTableCreateStatmentForSavedAuditsTable {
    NSString *sql =[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@", TBL_SAVED_AUDITS];
    sql = [sql stringByAppendingString:@" ("];
    sql = [sql stringByAppendingFormat:@"%@ %@ DEFAULT 0,",COL_SPLIT_GROUP_ID, SQLITE_TYPE_INTEGER];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_AUDIT_MASTER_ID, SQLITE_TYPE_INTEGER];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_AUDIT_GROUP_ID, SQLITE_TYPE_INTEGER];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_AUDIT_PRODUCT_ID, SQLITE_TYPE_INTEGER];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_PRODUCT_GROUP_ID, SQLITE_TYPE_INTEGER];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_ORDER_ID, SQLITE_TYPE_INTEGER];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_AUDIT_JSON, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_PRODUCT_NAME, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_IMAGES, SQLITE_TYPE_TEXT]; // json array of Image objects
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_INSP_STATUS, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_USERENTERED_SAMPLES, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_COUNT_OF_CASES, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_INSPECTION_COUNT_OF_CASES, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@",COL_AUDIT_COUNT, SQLITE_TYPE_INTEGER];
    sql = [sql stringByAppendingString:@")"];
    return sql;
}

- (NSString *) getTableCreateStatmentForSavedContainersTable {
    NSString *sql =[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@", TBL_SAVED_CONTAINERS];
    sql = [sql stringByAppendingString:@" ("];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_AUDIT_MASTER_ID, SQLITE_TYPE_INTEGER];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_INSPECTION_NAME, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_RATINGS, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@",COL_IMAGES, SQLITE_TYPE_TEXT]; // json array of Image objects
    sql = [sql stringByAppendingString:@")"];
    return sql;
}

- (NSString *) getTableCreateStatmentForSummary {
    NSString *sql =[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@", TBL_SAVED_SUMMARY];
    sql = [sql stringByAppendingString:@" ("];
    sql = [sql stringByAppendingFormat:@"%@ %@ DEFAULT 0,",COL_SPLIT_GROUP_ID, SQLITE_TYPE_INTEGER];
    sql = [sql stringByAppendingFormat:@"%@ %@ DEFAULT 0,",COL_NOTIFICATION_CHANGED, SQLITE_TYPE_INTEGER];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_PRODUCT_ID, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_PRODUCT_GROUP_ID, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_COUNT_OF_CASES, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_INSPECTION_COUNT_OF_CASES, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_AUDIT_MASTER_ID, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_AUDIT_GROUP_ID, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_INSPECTION_STATUS, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_USERENTERED_SAMPLES, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_USERENTERED_NOTIFICATION, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@",COL_SUMMARY, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingString:@")"];
    return sql;
}

- (NSString *) getTableCreateStatmentForCollaborativeLocalUpdatesDB {
    return [CollabLocalUpdatesDB getTableCreateStatment];
}

- (NSString *) getTableCreateStatmentForCollaborativeSaveRequestsDB {
    return [CollabSaveDB getTableCreateStatment];
}

-(NSString*) getIndexStatementForCollaborativeLocalUpdatesDB {
    NSString* sql =[NSString stringWithFormat:@"CREATE INDEX %@ ON %@ (%@, %@)", @"INDEX_ID_PO",TBL_COLLABORATIVE_LOCAL_UPDATES,COL_ORDER_PO_NUMBER,COL_PRODUCT_ID];
    return sql;
}


@end
