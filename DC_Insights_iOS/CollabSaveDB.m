//
//  CollabSaveDB.m
//  Insights
//
//  Created by Vineet on 11/15/17.
//  Copyright © 2017 Yottamark. All rights reserved.
//

#import "CollabSaveDB.h"
#import "DCBaseEntity.h"
#import "CollabBackgroundUpload.h"

@implementation CollabSaveDB

+ (NSString *) getTableCreateStatment {
    NSString *sql =[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@", TBL_COLLABORATIVE_SAVE_REQUESTS];
    sql = [sql stringByAppendingString:@" ("];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_ID, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_URL, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_AUDIT_JSON, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@",COL_DATA_SUBMITTED, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingString:@")"];
    return sql;
}

-(void)saveRequest:(CollaborativeAPISaveRequest*)jsonRequest withURL:(NSString*)url {
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
    [database open];
    
    //delete any submitted requests
     NSString *cleanupRequests = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@='%@'", TBL_COLLABORATIVE_SAVE_REQUESTS, COL_DATA_SUBMITTED, CONST_TRUE];
    [database executeUpdate:cleanupRequests];
    
    //add request
    NSString* json = [jsonRequest toJSONString];
    NSString* currentTime = [DeviceManager getCurrentTimeString];
    NSString *queryForUpdate = [NSString stringWithFormat:@"INSERT into %@ (%@,%@,%@,%@) values (%@,'%@','%@','%@')",
                                TBL_COLLABORATIVE_SAVE_REQUESTS,
                                COL_ID,COL_URL,COL_AUDIT_JSON,COL_DATA_SUBMITTED,
                                currentTime,url,json,CONST_FALSE];
    [database executeUpdate:queryForUpdate];
    [database close];
    //queue background upload request
    CollabBackgroundUpload *backgroundUpload = [[CollabBackgroundUpload alloc]init];
    [backgroundUpload startUpload];
}

+(BOOL) isUploadNeeded {
    __block BOOL auditsToBeUploaded = NO;
    int pendingAuditsToUpload = 0;
    NSString *queryAllOfflineRatings = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%@'", TBL_COLLABORATIVE_SAVE_REQUESTS, COL_DATA_SUBMITTED, CONST_FALSE];
    FMDatabase *databaseOfflineRatings = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
    FMResultSet *resultsGroupRatings;
    [databaseOfflineRatings open];
    resultsGroupRatings = [databaseOfflineRatings executeQuery:queryAllOfflineRatings];
    int auditsToBeUploadedCount = 0;
    while ([resultsGroupRatings next]) {
        auditsToBeUploadedCount++;
        auditsToBeUploaded = YES;
        pendingAuditsToUpload++;
    }
    [databaseOfflineRatings close];
    if (auditsToBeUploaded) {
        return YES;
    } else {
        return NO;
    }
}

-(void)clearTableData {
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
    [database open];
    
    //delete any submitted requests
    NSString *cleanupRequests = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@='%@'", TBL_COLLABORATIVE_SAVE_REQUESTS, COL_DATA_SUBMITTED, CONST_TRUE];
    [database executeUpdate:cleanupRequests];
    [database close];
}


@end
