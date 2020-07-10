//
//  TblCompletedAudits.m
//  Insights
//
//  Created by Vineet Pareek on 25/5/17.
//  Copyright © 2017 Yottamark. All rights reserved.
//

#import "TblCompletedAudits.h"
#import "AppDataDBHelper.h"
#import "FMDatabase.h"
#import "DBConstants.h"
#import "Constants.h"
#import "DBManager.h"
#import "ImageArray.h"

@implementation TblCompletedAudits

+(int)getPendingImagesCount {
    int totalImagesToUpload=0;
    NSString *queryAllOfflineRatings = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%@'", TBL_COMPLETED_AUDITS, COL_IMAGE_SUBMITTED, CONST_FALSE];
    FMDatabase *databaseOfflineRatings = [[DBManager sharedDBManager] openDatabase:DB_OFFLINE_DATA];
    FMResultSet *resultsGroupRatings;
    [databaseOfflineRatings open];
    resultsGroupRatings = [databaseOfflineRatings executeQuery:queryAllOfflineRatings];
    NSMutableArray* containerImages = [[NSMutableArray alloc]init];
    NSMutableDictionary* auditIdAndImagesMap = [[NSMutableDictionary alloc]init];
    while ([resultsGroupRatings next]) {
        NSString *ratings = [resultsGroupRatings stringForColumn:COL_AUDIT_IMAGE];
        NSError* err = nil;
        ImageArray* audit = [[ImageArray alloc] initWithString:ratings error:&err];
        NSMutableArray *totalsThatNeedTobeSubmitted = [[NSMutableArray alloc] init];
        NSMutableArray <Image> *imagesMutableArrayToBeSubmitted = (NSMutableArray <Image>*)totalsThatNeedTobeSubmitted;
        for (Image *image in audit.images) {
            if (!image.submitted) {
                [imagesMutableArrayToBeSubmitted addObject:image];
                BOOL isContainerImage = [image.path rangeOfString:@"/CONTAINER"].location != NSNotFound;
                if(isContainerImage && ![containerImages containsObject:image.path]){
                    [containerImages addObject:image.path];
                    totalImagesToUpload++;
                }else if(isContainerImage && [containerImages containsObject:image.path]){
                    
                }else
                    totalImagesToUpload++;
            }
        }
    }
    return totalImagesToUpload;
}
//TODO: refactor query to handle the count
+(int) getPendingAuditsCount {
    NSString *queryAllOfflineRatings = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%@'", TBL_COMPLETED_AUDITS, COL_DATA_SUBMITTED, CONST_FALSE];
    FMDatabase *databaseOfflineRatings = [[DBManager sharedDBManager] openDatabase:DB_OFFLINE_DATA];
    FMResultSet *resultsGroupRatings;
    [databaseOfflineRatings open];
    resultsGroupRatings = [databaseOfflineRatings executeQuery:queryAllOfflineRatings];
    int auditsToBeUploadedCount = 0;
    while ([resultsGroupRatings next]) {
        auditsToBeUploadedCount++;
    }
    [databaseOfflineRatings close];
    return auditsToBeUploadedCount;
}

+(BOOL) isUploadNeeded {
    __block BOOL auditsToBeUploaded = NO;
    __block BOOL auditImagesToBeUploaded = NO;
    int pendingAuditsToUpload = 0;
    int pendingImagesToUpload = 0;
    NSString *queryAllOfflineRatings = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%@'", TBL_COMPLETED_AUDITS, COL_DATA_SUBMITTED, CONST_FALSE];
    NSString *queryAllOfflineRatingsImages = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%@'", TBL_COMPLETED_AUDITS, COL_IMAGE_SUBMITTED, CONST_FALSE];
    FMDatabase *databaseOfflineRatings = [[DBManager sharedDBManager] openDatabase:DB_OFFLINE_DATA];
    FMResultSet *resultsGroupRatings;
    FMResultSet *resultsGroupRatingsImages;
    [databaseOfflineRatings open];
    resultsGroupRatings = [databaseOfflineRatings executeQuery:queryAllOfflineRatings];
    resultsGroupRatingsImages = [databaseOfflineRatings executeQuery:queryAllOfflineRatingsImages];
    int auditsToBeUploadedCount = 0;
    while ([resultsGroupRatings next]) {
        auditsToBeUploadedCount++;
        auditsToBeUploaded = YES;
        pendingAuditsToUpload++;
    }
    while ([resultsGroupRatingsImages next]) {
        auditsToBeUploadedCount++;
        auditImagesToBeUploaded = YES;
        pendingImagesToUpload++;
    }
    [databaseOfflineRatings close];
    if (auditsToBeUploaded || auditImagesToBeUploaded) {
        return YES;
    } else {
        return NO;
    }
}

+(void) deleteSubmittedRows{
    NSString *queryAllOfflineRatings = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@='%@' AND %@='%@'", TBL_COMPLETED_AUDITS, COL_DATA_SUBMITTED, CONST_TRUE, COL_IMAGE_SUBMITTED, CONST_TRUE];
    FMDatabase *databaseOfflineRatings = [[DBManager sharedDBManager] openDatabase:DB_OFFLINE_DATA];
    [databaseOfflineRatings open];
    [databaseOfflineRatings executeUpdate:queryAllOfflineRatings];
    [databaseOfflineRatings close];
}




@end
