//
//  BooleanRatingModel.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/27/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "BooleanRatingModel.h"

@implementation BooleanRatingModel

@synthesize boolChoice;

- (id)init
{
    self = [super init];
    if (self) {
        self.boolChoice = NO;
    }
    return self;
}

@end
