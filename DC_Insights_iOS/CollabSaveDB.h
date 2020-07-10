//
//  CollabSaveDB.h
//  Insights
//
//  Created by Vineet on 11/15/17.
//  Copyright © 2017 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CollaborativeAPISaveRequest.h"

//interface for managing upload queue - updates are saved here and queued for upload
@interface CollabSaveDB : NSObject

-(void)saveRequest:(CollaborativeAPISaveRequest*)jsonRequest withURL:(NSString*)url;
+(BOOL) isUploadNeeded;
+ (NSString *) getTableCreateStatment;
@end
