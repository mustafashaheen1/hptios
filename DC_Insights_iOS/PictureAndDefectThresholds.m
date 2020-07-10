//
//  PictureAndDefectThresholds.m
//  DC_Insights_iOS
//
//  Created by Vineet Pareek on 5/20/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "PictureAndDefectThresholds.h"

@implementation PictureAndDefectThresholds

- (id)init
{
    self = [super init];
    if (self) {
        self.picture = 0;
        self.defects = 0;
    }
    return self;
}

@end
