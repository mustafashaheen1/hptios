//
//  LocationRatingModel.m
//  Insights
//
//  Created by Mustafa Shaheen on 7/3/20.
//  Copyright © 2020 Yottamark. All rights reserved.
//

#import "LocationRatingModel.h"

@implementation LocationRatingModel
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
