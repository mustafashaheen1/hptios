//
//  OptionalSettings.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/25/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "OptionalSettings.h"

@implementation OptionalSettings

@synthesize optional;
@synthesize persistent;
@synthesize picture;
@synthesize scannable;
@synthesize rating;

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        self.optional = NO;
        self.persistent = NO;
        self.picture = NO;
        self.scannable = NO;
        self.defects = NO;
        self.rating = NO;
        self.productSpecified = NO;
    }
    return self;
}

@end
