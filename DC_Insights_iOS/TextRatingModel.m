//
//  TextRatingModel.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/27/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "TextRatingModel.h"

@implementation TextRatingModel

@synthesize text;

- (id)init
{
    self = [super init];
    if (self) {
        self.text = [[NSString alloc] init];
    }
    return self;
}

@end
