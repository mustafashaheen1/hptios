//
//  AuditApiLocation.m
//  DC_Insights_iOS
//
//  Created by Vineet Pareek on 4/17/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "AuditApiLocation.h"

@implementation AuditApiLocation

- (id)init
{
    self = [super init];
    if (self) {
        self.store = [[AuditApiStore alloc] init];
        self.latitude = @"000000";
        self.longitude = @"00000";
        self.gpsMessage = @"NoGPS";
    }
    return self;
}

@end
