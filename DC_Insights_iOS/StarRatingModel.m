//
//  StarRatingModel.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/27/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "StarRatingModel.h"

@implementation StarRatingModel

@synthesize description;
@synthesize starRatingID;
@synthesize image_id;
@synthesize image_url;
@synthesize label;

- (id)init
{
    self = [super init];
    if (self) {
        self.description = @"";
        self.starRatingID = 0;
        self.image_id = 0;
        self.image_url = @"";
        self.label = @"";
    }
    return self;
}

@end
