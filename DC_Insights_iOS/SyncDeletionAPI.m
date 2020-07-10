//
//  SyncDeletionAPI.m
//  Insights
//
//  Created by Vineet Pareek on 29/08/2016.
//  Copyright © 2016 Yottamark. All rights reserved.
//

#import "SyncDeletionAPI.h"
#import "DBManager.h"
#import "PaginationCallsClass.h"
#import "SyncDeletion.h"
#import "DBConstants.h"

@implementation SyncDeletionAPI


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

- (void)deletionLogsCallWithBlock:(void (^)(BOOL isSuccess, NSArray *array, NSError *error))block {
    if (PAGINATE_SYNC_API) {
        PaginationCallsClass *paginate = [[PaginationCallsClass alloc] init];
        paginate.minimumNumberOfCalls = minimumNumberForCalls;
        paginate.limit = limitPerPage;
        paginate.pageNo = initialPageNo;
        paginate.apiCallString = DeletionLog;
        paginate.apiCallFilePath = DeletionLogsPath;
        [paginate callWithBlock:^(BOOL isSuccess, NSArray *array, NSError *error) {
            if (error) {
                if (block) {
                    block(NO, nil, nil);
                }
            } else {
                self.deletionArray = [self getDeletionLogsFromArray:array];
                if (block) {
                    block(YES, nil, nil);
                }
            }
        }];
    } else {
        NSDictionary *localStoreCallParamaters = [self paramtersFortheGETCall];
        if ([localStoreCallParamaters count] > 0) {
            [[AFAppDotNetAPIClient sharedClient] getPath:DeletionLog parameters:localStoreCallParamaters success:^(AFHTTPRequestOperation *operation, id JSON) {
                id JSONLocal;
                BOOL successWrite= [self writeDataToFile:DeletionLogsPath withContents:JSON];
                if (successWrite) {
                    JSONLocal = [self readDataFromFile:DeletionLogsPath];
                }
                NSLog(@"JSONLocal %@", JSONLocal);
                self.deletionArray = [self getDeletionLogsFromArray:JSONLocal];
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
    //[self insertRowDataForDB:self.deletionArray];
}

-(void) saveApiResponseArray:(NSMutableArray *)array {
    self.deletionArray = [self getDeletionLogsFromArray:array];
    [self downloadCompleteAndItsSafeToInsertDataInToDB];
}

#pragma mark - Parse Methods

- (NSArray *) getDeletionLogsFromArray :(NSArray *) arrayBeforeProcessing {
    NSMutableArray *deletionMutable = [[NSMutableArray alloc] init];
    if (arrayBeforeProcessing) {
        for (NSDictionary *deletionDictionary in arrayBeforeProcessing) {
            SyncDeletion *deletion = [self setAttributesFromMap:deletionDictionary];
            [deletionMutable addObject:deletion];
        }
    }
    return [deletionMutable copy];
}

- (SyncDeletion *)setAttributesFromMap:(NSDictionary*)dataMap {
    SyncDeletion *deletion = [[SyncDeletion alloc] init];
    if (dataMap) {;
        deletion.resource = [self parseStringFromJson:dataMap key:@"resource"];
        deletion.deleted_at = [self parseStringFromJson:dataMap key:@"deleted_at"];
        deletion.resource_id = [self parseIntegerFromJson:dataMap key:@"resource_id"];
        
    }
    return deletion;
}

-(void) groupAndDeleteResources {
    //parse json and group resource_ids by resource in hashmap
    //key = name of resource //value = array of resource ids
    NSMutableDictionary<NSString*,NSMutableArray*> *resourceAndDeletionIdsMap = [[NSMutableDictionary alloc]init];
    for(SyncDeletion *deletion in self.deletionArray){
        NSString* resource = deletion.resource;
        NSInteger resource_id = deletion.resource_id;
        NSMutableArray* listOfIds = [[NSMutableArray alloc]init];
        if([resourceAndDeletionIdsMap objectForKey:resource]){
            listOfIds =[resourceAndDeletionIdsMap objectForKey:resource];
        }
        [listOfIds addObject:[NSNumber numberWithInteger:resource_id]];
        [resourceAndDeletionIdsMap setObject:listOfIds forKey:resource];
    }
    //delete the Insights DB rows corresponding to the ids in the hashmap
    NSArray* listOfResources = [resourceAndDeletionIdsMap allKeys];
    for(NSString* resourceToDelete in listOfResources){
        NSMutableArray* array = [resourceAndDeletionIdsMap objectForKey:resourceToDelete];
        NSString *listOfIdString = [array componentsJoinedByString:@","];
        if([resourceToDelete isEqualToString:@"containers"]){
            [self deleteFromTable:TBL_CONTAINERS resourceIds:listOfIdString];
        }else if([resourceToDelete isEqualToString:@"containers/ratings"]){
            [self deleteFromTable:TBL_CONTAINER_RATINGS resourceIds:listOfIdString];
        }else if([resourceToDelete isEqualToString:@"defect_families"]){
            [self deleteFromTable:TBL_DEFECT_FAMILIES resourceIds:listOfIdString];
        }else if([resourceToDelete isEqualToString:@"defects"]){
            [self deleteFromTable:TBL_DEFECT_FAMILY_DEFECTS resourceIds:listOfIdString];
        }else if([resourceToDelete isEqualToString:@"programs"]){
            [self deleteFromTable:TBL_PROGRAMS resourceIds:listOfIdString];
        }else if([resourceToDelete isEqualToString:@"programs/products"]){
            [self deleteFromTable:TBL_PRODUCTS resourceIds:listOfIdString];
        }else if([resourceToDelete isEqualToString:@"groups"]){
            [self deleteFromTable:TBL_GROUPS resourceIds:listOfIdString];
        }else if([resourceToDelete isEqualToString:@"ratings"]){
            [self deleteFromTable:TBL_RATINGS resourceIds:listOfIdString];
        }else if([resourceToDelete isEqualToString:@"stores"]){
            [self deleteFromTable:TBL_STORES resourceIds:listOfIdString];
        }
    }
}

-(void) deleteFromTable:(NSString*)tableName resourceIds:(NSString*)resIds{
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_INSIGHTS_DATA];
    [database open];
    NSString *deleteQuery = [NSString stringWithFormat:@"Delete from %@ where id in (%@)",tableName,resIds];
    if([tableName isEqualToString:TBL_CONTAINER_RATINGS])
        deleteQuery =[NSString stringWithFormat:@"Delete from %@ where %@ in (%@)",tableName,COL_RATING_ID,resIds];
    [database executeUpdate:deleteQuery];
    [database close];
}


@end
