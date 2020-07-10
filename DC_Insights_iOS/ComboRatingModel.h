//
//  ComboRatingModel.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/27/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "DCBaseEntity.h"
#import "JSONModel.h"

@protocol ComboRatingModel

@end

@interface ComboRatingModel : JSONModel

@property (nonatomic, strong) NSArray *comboItems;

@end
