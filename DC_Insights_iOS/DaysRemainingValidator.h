//
// Created by Vineet on 7/9/18.
// Copyright (c) 2018 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Rating.h"
#import "Product.h"

@interface DaysRemainingValidator : NSObject

@property (nonatomic, strong) Rating* dateRating;
@property (nonatomic, strong) Product* product;
-(id) initWithRating:(Rating*)rating withProduct:(Product*)product;

-(BOOL) isCheckRequiredForRating;
-(BOOL) isValidForMinimumDays;
-(BOOL) isValidForMaximumDays;
-(NSString*)getDateRange;


@end
