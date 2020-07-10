//
//  ComboRatingModel.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/27/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "ComboRatingModel.h"

@implementation ComboRatingModel

@synthesize comboItems;

- (id)init
{
    self = [super init];
    if (self) {
        self.comboItems = [[NSArray alloc] init];
    }
    return self;
}


@end
