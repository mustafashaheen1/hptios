//
//  RatingJSONModel.m
//  Insights
//
//  Created by Shyam Ashok on 2/23/15.
//  Copyright (c) 2015 Yottamark. All rights reserved.
//

#import "RatingJSONModel.h"

@implementation RatingJSONModel

- (id)init
{
    self = [super init];
    if (self) {
        self.ratingID = 0;
        self.groupRatingID = 0;
        self.name = @"";
        self.displayName = @"";
        self.type = @"";
        self.order_data_field = @"";
        self.content = [[Content alloc] init];
        self.container_id = 0;
        self.defect_family_id = @"";
        self.defects = [[NSMutableArray alloc] init];
        self.defectsIdList = [[NSMutableArray alloc] init];
        self.containerID = 0;
        self.order_position = 0;
        self.optionalSettings = [[OptionalSettings alloc] init];
        self.options = [[NSArray alloc] init];
        self.defectsFromUI = [[NSMutableArray alloc] init];
        self.ratingAnswerFromUI = @"";
        self.defectsFromDefectAPI = [[NSArray alloc] init];
        self.pictureAndDefectThresholds = [[PictureAndDefectThresholds alloc] init];
    }
    return self;
}

@end
