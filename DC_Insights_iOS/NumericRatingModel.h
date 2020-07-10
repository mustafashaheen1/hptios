//
//  NumericRatingModel.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/27/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "DCBaseEntity.h"
#import "JSONModel.h"

@interface NumericRatingModel : JSONModel

@property (nonatomic, assign) NSInteger number;
@property (nonatomic, assign) double max_value;
@property (nonatomic, assign) double min_value;
@property (nonatomic, strong) NSString *numeric_type;
@property (nonatomic, strong) NSArray *units;

@end
