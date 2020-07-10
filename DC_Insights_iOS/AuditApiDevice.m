//
//  AuditApiDevice.m
//  DC_Insights_iOS
//
//  Created by Vineet Pareek on 4/17/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "AuditApiDevice.h"

@implementation AuditApiDevice

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        self.version = @"";
        self.id = @"";
        self.os_name = @"";
        self.os_version = @"";
    }
    return self;
}


@end
