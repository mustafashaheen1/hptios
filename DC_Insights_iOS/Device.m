//
//  Device.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/5/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "Device.h"

#define UPDATE_METHOD_AUTO "Auto";
#define UPDATE_METHOD_MANUAL "Manual";
#define UPDATE_METHOD_FORCED "Force";

#define DEVICE_ENABLED "Enabled";
#define DEVICE_DISABLED "Disabled";

@implementation Device

@synthesize deviceID;
@synthesize deviceEnabled;
@synthesize updateMethod;

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        self.deviceID = @"";
        self.deviceEnabled = NO;
        self.updateMethod = @"";
    }
    return self;
}

@end
