//
//  PendingAudits.m
//  Insights
//
//  Created by Shyam Ashok on 9/17/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "PendingAudits.h"

@implementation PendingAudits

- (id)init
{
    self = [super init];
    if (self) {
        self.auditMasterId = @"";
        self.auditCount = 0;
        self.imageCount = 0;
        self.dateCompleted = @"";
    }
    return self;
}

@end
