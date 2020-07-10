//
//  CollabSyncManager.m
//  Insights
//
//  Created by Vineet on 11/15/17.
//  Copyright © 2017 Yottamark. All rights reserved.
//

#import "CollabSyncManager.h"
#import "JSONHTTPClient.h"
#import "DeviceManager.h"
#import "Constants.h"
#import "CollabSaveDB.h"
#import "CollabListDB.h"
#import "SyncManager.h"
#import "CollaborativeAPIResponse.h"
#import "CollabLocalUpdatesDB.h"

@implementation CollabSyncManager

-(void) getPOStatus:(CollaborativeAPIListRequest*)apiRequest
          withBlock:(void (^)(NSArray* productList, NSError *error))block{
    
    apiRequest.auth_token =[[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"];
    apiRequest.device_id =[DeviceManager getDeviceID];
    NSString* request =[apiRequest toJSONString];
    NSString* url = [self getUrlForPath:collobarativeInspectionsList];
    NSLog(@"Collaborative /api/list: Request %@", [apiRequest toJSONString]);
    [JSONHTTPClient setTimeoutInSeconds:5];
    [[JSONHTTPClient requestHeaders] setValue:@"application/json" forKey:@"Content-Type"];
    [JSONHTTPClient postJSONFromURLWithString:url bodyString:request completion:^(id json, JSONModelError *err) {
        NSLog(@"Collaborative /api/list Remote Response %@", json);
        if(err) {
            if (block) {
                NSLog(@"Response %@", err);
                [self postConnectionErrorNotification];
                //get local updates array
                NSArray<CollaborativeAPIResponse*>* listOfProductFromLocal = [self getLocalUpdates];
                block(listOfProductFromLocal, err);
            }
        }else{
            NSArray* array = (NSArray*)json;
            
            //save JSON array to listPREF (backup)
            CollabListDB *listDBManager = [[CollabListDB alloc]init];
            [listDBManager saveList:array];
            
            //convert remote response to array
            NSMutableArray<CollaborativeAPIResponse*>* listOfProductFromServer = [CollaborativeAPIResponse parseJSONArrayToModelArray:array];
            
            //get local updates array
            NSArray<CollaborativeAPIResponse*>* listOfProductFromLocal = [self getLocalUpdates];
            //if no local updates then return server response
            if(!listOfProductFromLocal || [listOfProductFromLocal count]<=0){
                block(listOfProductFromServer,nil);
                return;
            }
            
            //create merged array based on the newest status
            NSMutableArray<CollaborativeAPIResponse*>* mergedProductArray = [self mergeLocalUpdates:listOfProductFromLocal withRemoteStatus:listOfProductFromServer];
            //return array
            block(mergedProductArray,nil);
        }
    }];
}

-(void)postConnectionErrorNotification {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:NOTIFICATION_COLLABORATIVE_CONNECTION_ERROR
     object:self];
}

-(NSArray<CollaborativeAPIResponse*>*)getLocalUpdates {
    CollabLocalUpdatesDB *localUpdatesDB = [[CollabLocalUpdatesDB alloc]init];
    NSArray<CollaborativeAPIResponse*>* listOfProductFromLocal = [localUpdatesDB getStatus];
    return listOfProductFromLocal;
}

-(NSMutableArray*) mergeLocalUpdates:(NSArray*)localArray withRemoteStatus:(NSArray*)remoteArray {
    NSMutableArray<CollaborativeAPIResponse*>* mergedProductArray = [[NSMutableArray alloc]init];
    if(localArray && [localArray count]>0){
        for(CollaborativeAPIResponse* productServer in remoteArray){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"po==%@ AND product_id==%d",productServer.po,productServer.product_id];
            NSArray *results = [localArray filteredArrayUsingPredicate:predicate];
            if([results count]>0){
                CollaborativeAPIResponse* product = [results objectAtIndex:0];
                if(product && product.status>productServer.status)
                    [mergedProductArray addObject:product];
                else
                    [mergedProductArray addObject:productServer];
            }else
                [mergedProductArray addObject:productServer];
        }
    }
    return mergedProductArray;
}
/*
-(void)saveStatus:(int)status forProduct:(int)productId inPO:(NSString*)poNumber
  withPostRequest:(CollaborativeAPISaveRequest*)postRequest toURL:(NSString*)url{
    //write update in localStatusPREF
    //save post request in queue
    CollabLocalUpdatesDB *localUpdateDB = [[CollabLocalUpdatesDB alloc]init];
    [localUpdateDB saveStatus:status forProduct:productId inPO:poNumber];
    
    CollabSaveDB *saveRequestsDB = [[CollabSaveDB alloc]init];
    [saveRequestsDB saveRequest:postRequest withURL:url];
}
*/
-(void)saveStatus:(int)status forProducts:(NSArray*)productNumbers inPO:(NSString*)poNumber
                   withPostRequest:(CollaborativeAPISaveRequest*)postRequest toURL:(NSString*)url{
    //write update in localStatusPREF
    //save post request in queue
    CollabLocalUpdatesDB *localUpdateDB = [[CollabLocalUpdatesDB alloc]init];
    if([productNumbers count]==1){
        int productId = [[productNumbers objectAtIndex:0] intValue];
        [localUpdateDB saveStatus:status forProduct:productId inPO:poNumber];
    }
    else
        [localUpdateDB saveStatus:status forProducts:productNumbers inPO:poNumber];
    
    CollabSaveDB *saveRequestsDB = [[CollabSaveDB alloc]init];
    [saveRequestsDB saveRequest:postRequest withURL:url];
}

-(NSString*)getUrlForPath:(NSString*)path{
    NSString *endPoint =[SyncManager getPortalEndpoint];
    NSString* url = [NSString stringWithFormat:@"%@%@",
                     endPoint,
                     path];
    return url;
}

@end
