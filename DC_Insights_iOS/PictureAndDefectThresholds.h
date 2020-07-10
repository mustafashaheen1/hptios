//
//  PictureAndDefectThresholds.h
//  DC_Insights_iOS
//
//  Created by Vineet Pareek on 5/20/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "JSONModel.h"

@protocol PictureAndDefectThresholds
@end

@interface PictureAndDefectThresholds : JSONModel

@property (nonatomic, assign) NSInteger picture;
@property (nonatomic, assign) NSInteger defects;

@end
