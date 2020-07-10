//
//  Threshold.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/24/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "DCBaseEntity.h"

@interface Threshold : DCBaseEntity

@property (nonatomic, assign) NSInteger accept_with_issues;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSInteger order_position;
@property (nonatomic, assign) NSInteger reject;

@end
