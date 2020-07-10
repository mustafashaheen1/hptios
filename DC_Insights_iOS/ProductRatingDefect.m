//
//  ProductRatingDefect.m
//  Insights
//
//  Created by Vineet Pareek on 23/1/17.
//  Copyright © 2017 Yottamark. All rights reserved.
//

#import "ProductRatingDefect.h"

@implementation ProductRatingDefect

- (id)init
{
    self = [super init];
    if (self) {
        self.rating_id = 0;
        self.defect_family_id = 0;
    }
    return self;
}

@end
