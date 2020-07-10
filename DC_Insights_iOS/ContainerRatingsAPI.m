//
//  ContainerRatingsAPI.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/27/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "ContainerRatingsAPI.h"
#import "DBManager.h"
#import "Rating.h"
#import "PaginationCallsClass.h"

@implementation ContainerRatingsAPI

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

/// Call Containers Ratings

- (void)containerRatingsCallWithBlock:(void (^)(BOOL isSuccess, NSArray *array, NSError *error))block {
    if (PAGINATE_SYNC_API) {
        PaginationCallsClass *paginate = [[PaginationCallsClass alloc] init];
        paginate.minimumNumberOfCalls = minimumNumberForCalls;
        paginate.limit = limitPerPage;
        paginate.pageNo = initialPageNo;
        paginate.apiCallString = ContainersRatings;
        paginate.apiCallFilePath = containerRatingsFilePath;
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
            [[AFAppDotNetAPIClient sharedClient] getPath:ContainersRatings parameters:localStoreCallParamaters success:^(AFHTTPRequestOperation *operation, id JSON) {
                id JSONLocal;
                BOOL successWrite= [self writeDataToFile:containerRatingsFilePath withContents:JSON];
                if (successWrite) {
                    JSONLocal = [self readDataFromFile:containerRatingsFilePath];
                }
                NSLog(@"ContainerRatingsLocal %@", JSONLocal);
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
            Rating *rating = [self setAttributesFromMap:containerDictionary];
            [containerMutable addObject:rating];
        }
    }
    return [containerMutable copy];
}

- (Rating *)setAttributesFromMap:(NSDictionary*)dataMap {
    Rating *rating = [[Rating alloc] init];
    if (dataMap) {
        rating.containerID = [self parseIntegerFromJson:dataMap key:@"id"];
        rating.defect_family_id = [self parseIntegerFromJson:dataMap key:@"defect_family_id"];
        rating.container_id = [self parseIntegerFromJson:dataMap key:@"container_id"];
        rating.order_position = [self parseIntegerFromJson:dataMap key:@"order_position"];
        rating.ratingID = [self parseIntegerFromJson:dataMap key:@"rating_id"];
        rating.defects = [[self parseArrayFromJson:dataMap key:@"defects"] copy];
    }
    return rating;
}

#pragma mark - SQL Methods

+ (NSString *) getTableCreateStatmentForContainerRatings {
    NSString *sql =[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@", TBL_CONTAINER_RATINGS];
    sql = [sql stringByAppendingString:@" ("];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_CONTAINER_ID,SQLITE_TYPE_INTEGER];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_RATING_ID,SQLITE_TYPE_INTEGER];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_DEFECT_FAMILY_ID,SQLITE_TYPE_INTEGER];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_DEFECTS,SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_ORDER_POSITION,SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"UNIQUE(%@,%@) ON CONFLICT REPLACE",COL_CONTAINER_ID, COL_RATING_ID];
    sql = [sql stringByAppendingString:@")"];
    return sql;
}

- (void) insertRowDataForDB: (NSArray *) containerArray {
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_INSIGHTS_DATA];
    [database open];
    for (int i=0; i < [containerArray count]; i++) {
        Rating *rating = [containerArray objectAtIndex:i];
        NSData *dataDefects = [NSKeyedArchiver archivedDataWithRootObject:rating.defects];
        BOOL response = [database executeUpdate:@"insert or replace into CONTAINER_RATINGS (container_id, rating_id, defect_family_id, defects, order_position) values (?,?,?,?,?)", [NSString stringWithFormat:@"%ld", (long)rating.container_id], [NSString stringWithFormat:@"%ld", (long)rating.ratingID], [NSString stringWithFormat:@"%ld", (long)rating.defect_family_id], dataDefects, [NSString stringWithFormat:@"%ld", (long)rating.order_position]];
         //NSLog(@"ContainerRatingsApi.m - TBL_STORE Insert or replace response - %d", response);
    }
    [database close];
}

@end
