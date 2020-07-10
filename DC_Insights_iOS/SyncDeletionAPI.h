//
//  SyncDeletionAPI.h
//  Insights
//
//  Created by Vineet Pareek on 29/08/2016.
//  Copyright © 2016 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCBaseEntity.h"

@interface SyncDeletionAPI : DCBaseEntity

@property (nonatomic, strong) NSArray *deletionArray;

- (void)deletionLogsCallWithBlock:(void (^)(BOOL isSuccess, NSArray *array, NSError *error))block;
- (void) downloadCompleteAndItsSafeToInsertDataInToDB;
//- (void)deletionLogsCallForChecking:(void (^)(BOOL isSuccess, NSArray *array, NSError *error))block;
-(void) groupAndDeleteResources;

@end
