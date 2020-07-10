//
//  AuditApiDuplicate.m
//  Insights
//
//  Created by Shyam Ashok on 9/3/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "AuditApiDuplicate.h"

@implementation AuditApiDuplicate

- (id)init
{
    self = [super init];
    if (self) {
        self.value = NO;
        self.count = 0;
    }
    return self;
}


@end
