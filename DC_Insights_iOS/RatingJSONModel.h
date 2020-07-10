//
//  RatingJSONModel.h
//  Insights
//
//  Created by Shyam Ashok on 2/23/15.
//  Copyright (c) 2015 Yottamark. All rights reserved.
//

#import "JSONModel.h"
#import "OptionalSettings.h"
#import "PictureAndDefectThresholds.h"
#import "Content.h"

@protocol RatingJSONModel
@end

@interface RatingJSONModel : JSONModel

@property (nonatomic, assign) NSInteger ratingID;
@property (nonatomic, assign) NSInteger groupRatingID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *order_data_field;
@property (nonatomic, strong) Content *content;
@property (nonatomic, assign) NSInteger container_id;
@property (nonatomic, strong) NSString *defect_family_id;
@property (nonatomic, strong) NSMutableArray *defects;
@property (nonatomic, strong) NSMutableArray *defectsIdList;
@property (nonatomic, assign) NSInteger containerID;
@property (nonatomic, assign) NSInteger order_position;
@property (nonatomic, strong) OptionalSettings *optionalSettings;
@property (nonatomic, strong) NSArray *options;
@property (nonatomic, strong) NSMutableArray *defectsFromUI;
@property (nonatomic, strong) NSString *ratingAnswerFromUI;
@property (nonatomic, strong) NSArray *defectsFromDefectAPI;
@property (nonatomic, strong) PictureAndDefectThresholds *pictureAndDefectThresholds;

@end
