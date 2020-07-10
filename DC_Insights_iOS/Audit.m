//
//  Audit.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/23/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "Audit.h"

@implementation Audit

- (id)init
{
    self = [super init];
    if (self) {
        self.auditData = [[AuditApiData alloc] init];
    }
    return self;
}

@end
