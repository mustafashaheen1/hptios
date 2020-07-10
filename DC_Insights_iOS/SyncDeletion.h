//
//  SyncDeletionLog.h
//  Insights
//
//  Created by Vineet Pareek on 29/08/2016.
//  Copyright © 2016 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCBaseEntity.h"

@interface SyncDeletion : DCBaseEntity

@property (nonatomic, assign) NSInteger resource_id;
@property (nonatomic, strong) NSString *resource;
@property (nonatomic, strong) NSString *deleted_at;

@end
