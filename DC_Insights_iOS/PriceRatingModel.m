//
//  PriceRatingModel.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/27/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "PriceRatingModel.h"

@implementation PriceRatingModel

@synthesize price_items;

- (id)init
{
    self = [super init];
    if (self) {
        self.price_items = [[NSArray alloc] init];
    }
    return self;
}

@end
