//
//  SyncDeletionLog.m
//  Insights
//
//  Created by Vineet Pareek on 29/08/2016.
//  Copyright © 2016 Yottamark. All rights reserved.
//

#import "SyncDeletion.h"

@implementation SyncDeletion


@synthesize deleted_at;
@synthesize resource;
@synthesize resource_id;

- (id)init
{
    self = [super init];
    if (self) {
        self.deleted_at = @"";
        self.resource_id=0;
        self.resource=@"";
    }
    return self;
}


@end
