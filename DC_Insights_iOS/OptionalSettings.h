//
//  OptionalSettings.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/25/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

@protocol OptionalSettings

@end

@interface OptionalSettings : JSONModel

@property (nonatomic, assign) BOOL optional;
@property (nonatomic, assign) BOOL persistent;
@property (nonatomic, assign) BOOL picture;
@property (nonatomic, assign) BOOL scannable;
@property (nonatomic, assign) BOOL defects;
@property (nonatomic, assign) BOOL rating;
@property (nonatomic, assign) BOOL productSpecified;

@end
