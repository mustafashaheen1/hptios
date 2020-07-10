//
//  DCInspectionEntity.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/18/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "DCBaseEntity.h"

@interface DCInspectionEntity : DCBaseEntity

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *major;
@property (nonatomic, strong) NSString *medium;
@property (nonatomic, strong) NSString *minor;

@end
