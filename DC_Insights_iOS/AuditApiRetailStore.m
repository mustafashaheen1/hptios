//
//  AuditApiRetailStore.m
//  Insights
//
//  Created by Shyam Ashok on 9/2/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "AuditApiRetailStore.h"

@implementation AuditApiRetailStore

- (id)init
{
    self = [super init];
    if (self) {
        self.address = @"";
        self.name = @"";
        self.zip = @"";
        self.latitude = @"000000";
        self.longitude = @"000000";
    }
    return self;
}


@end
