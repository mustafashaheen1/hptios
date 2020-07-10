//
//  NumericRatingModel.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/27/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "NumericRatingModel.h"

@implementation NumericRatingModel

@synthesize number;
@synthesize max_value;
@synthesize min_value;
@synthesize numeric_type;
@synthesize units;

- (id)init
{
    self = [super init];
    if (self) {
        self.number = 0;
        self.max_value = 0;
        self.min_value = 0;
        self.numeric_type = @"";
        self.units = [[NSArray alloc] init];
    }
    return self;
}

@end
