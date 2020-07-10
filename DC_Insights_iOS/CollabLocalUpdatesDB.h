//
//  CollabLocalUpdatesDB.h
//  Insights
//
//  Created by Vineet on 11/16/17.
//  Copyright © 2017 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CollaborativeAPIResponse.h"

//save the local updates here
@interface CollabLocalUpdatesDB : NSObject

-(void)saveStatus:(int)status forProduct:(int)productId inPO:(NSString*)poNumber;
-(void)saveStatus:(int)status forProducts:(NSArray*)productIds inPO:(NSString*)poNumber;
-(NSArray<CollaborativeAPIResponse*>*) getStatus;
+(void)cleanupInspectionsForPO:(NSString*)poNumber;
+(void)cleanupInspectionsForGRN:(NSString*)grn;
+ (NSString *) getTableCreateStatment;
@end
