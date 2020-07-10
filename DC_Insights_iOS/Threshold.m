//
//  Threshold.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/24/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "Threshold.h"

@implementation Threshold

@synthesize accept_with_issues;
@synthesize name;
@synthesize reject;
@synthesize order_position;

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

@end
