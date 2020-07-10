//
//  PriceRatingModel.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/27/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "DCBaseEntity.h"
#import "JSONModel.h"

@interface PriceRatingModel : JSONModel

@property (nonatomic, strong) NSArray *price_items;

@end
