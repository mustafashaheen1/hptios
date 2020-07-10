//
//  CollabSyncManager.h
//  Insights
//
//  Created by Vineet on 11/15/17.
//  Copyright © 2017 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CollaborativeAPIListRequest.h"
#import "CollaborativeAPISaveRequest.h"

@interface CollabSyncManager : NSObject

-(void) getPOStatus:(CollaborativeAPIListRequest*)apiRequest
          withBlock:(void (^)(NSArray* productList, NSError *error))block;
-(void)saveStatus:(int)status forProducts:(NSArray*)productNumbers inPO:(NSString*)poNumber
  withPostRequest:(CollaborativeAPISaveRequest*)postRequest toURL:(NSString*)url;
@end
