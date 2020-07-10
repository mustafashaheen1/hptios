//
//  CollabBackgroundUpload.m
//  Insights
//
//  Created by Vineet on 12/4/17.
//  Copyright © 2017 Yottamark. All rights reserved.
//

#import "CollabBackgroundUpload.h"
#import "Constants.h"
#import "NSUserDefaultsManager.h"
#import "DBManager.h"
#import "DBConstants.h"
#import "CollaborativeAPISaveRequest.h"
#import "AFHTTPClient.h"
#import "AFAppDotNetAPIClient.h"
#import "CollabSaveDB.h"

//TODO: merge with audits background upload using protocol implementation

@implementation CollabBackgroundUpload

-(void) startBackgroundTimer {
    if (![NSUserDefaultsManager getBOOLFromUserDeafults:colloborativeInspectionsEnabled]){
        NSLog(@"collaborative background upload disabled- cancel timer start");
        return;
    }
    
    if ([self.timer isValid]){
        NSLog(@" timer already valid - cancel timer start");
        return;
    }
    NSLog(@"collaborative background timer start");
    self.timer = [NSTimer scheduledTimerWithTimeInterval:COLLABORATIVE_BACKGROUND_UPLOAD_TIME_INTERVAL
                                                  target:self
                                                selector:@selector(startUpload)
                                                userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    [self startUpload];
}

-(void) stopBackgroundTimer {
    if([self.timer isValid])
        [self.timer invalidate];
}

-(void)startUpload {
    NSLog(@"starting collaborative background upload");
    
    if([self isBackgroundUploadInProgress]){
        NSLog(@" background upload in progress - cancel background upload");
        return;
    }
    
    if(![CollabSaveDB isUploadNeeded]){
        NSLog(@" no upload needed - cancel background upload");
        return;
    }
    [self markUploadStart];
    [self uploadOfflineDataToBackend];
}

-(BOOL)isBackgroundUploadInProgress {
    return self.isUploadInProgress;
}

-(void)markUploadStart {
    self.isUploadInProgress = YES;
}

-(void)endBackgroundUpload {
    [self markUploadEnd];
    [[UIApplication sharedApplication] endBackgroundTask:self.bgTask];
    self.bgTask = UIBackgroundTaskInvalid;
}

-(void)markUploadEnd {
    self.isUploadInProgress = NO;
}

- (void) uploadOfflineDataToBackend {
    __block BOOL auditsToBeUploaded = NO;
    NSString *queryAllOfflineRatings = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%@'", TBL_COLLABORATIVE_SAVE_REQUESTS, COL_DATA_SUBMITTED, CONST_FALSE];
    FMDatabase *databaseOfflineRatings = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
    FMResultSet *resultsGroupRatings;
    [databaseOfflineRatings open];
    resultsGroupRatings = [databaseOfflineRatings executeQuery:queryAllOfflineRatings];
    dispatch_group_t group = dispatch_group_create();
    while ([resultsGroupRatings next]) {
        auditsToBeUploaded = YES;
        NSString *url = [resultsGroupRatings stringForColumn:COL_URL];
        NSString *json = [resultsGroupRatings stringForColumn:COL_AUDIT_JSON];
        NSString *requestId =[resultsGroupRatings stringForColumn:COL_ID];
        NSError* err = nil;
        CollaborativeAPISaveRequest* request = [[CollaborativeAPISaveRequest alloc] initWithString:json error:&err];
        NSDictionary* requestPostDictionary = [request toDictionary];
        dispatch_group_enter(group);
        [self sendPost:requestPostDictionary toUrl:url withBlock:^(BOOL isSuccess, NSError *error){
            if (error) {
                DebugLog(@"| Error: %@  |", [error localizedDescription]);
            } else {
                if (isSuccess) {
                    NSString *updateStatement = [NSString stringWithFormat:@"UPDATE %@ SET %@='%@' WHERE %@='%@'", TBL_COLLABORATIVE_SAVE_REQUESTS, COL_DATA_SUBMITTED, CONST_TRUE, COL_ID, requestId];
                    NSMutableArray *createStatements = [[NSMutableArray alloc] init];
                    [createStatements addObject:updateStatement];
                    [[DBManager sharedDBManager] executeUpdateUsingFMDataBase:[createStatements copy] withDatabasePath:DB_APP_DATA];
                }
            }
            dispatch_group_leave(group);
        }];
    }
    [databaseOfflineRatings close];
}

- (void)sendPost:(NSDictionary *)auditPost toUrl:(NSString*)url withBlock:(void (^)(BOOL isSuccess, NSError *error))block  {
    if ([auditPost count] > 0) {
        [[AFAppDotNetAPIClient sharedClient] postPath:collobarativeInspectionsSave parameters:auditPost success:^(AFHTTPRequestOperation *operation, id JSON) {
            NSLog(@"Request: %@", JSON);
            if (block) {
                block(YES, nil);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (block) {
                block(false, error);
            }
        }];
    } else {
        if (block) {
            block(false, nil);
        }
    }
}

@end
