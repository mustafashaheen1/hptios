//
//  LocationRatingModel.h
//  Insights
//
//  Created by Mustafa Shaheen on 7/3/20.
//  Copyright © 2020 Yottamark. All rights reserved.
//

#import "DCBaseEntity.h"
#import "JSONModel.h"

@protocol LocationRatingModel

@end

@interface LocationRatingModel : JSONModel
@property (nonatomic, strong) NSArray *comboItems;
@end

