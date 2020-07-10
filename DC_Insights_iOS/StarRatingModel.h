//
//  StarRatingModel.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/27/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "DCBaseEntity.h"
#import "JSONModel.h"

@interface StarRatingModel : JSONModel

@property (nonatomic, strong) NSString *description;
@property (nonatomic, assign) NSInteger starRatingID;
@property (nonatomic, assign) NSInteger image_id;
@property (nonatomic, strong) NSString *image_url;
@property (nonatomic, strong) NSString *label;

@end
