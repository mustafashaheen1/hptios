//
//  ProductRatingDefect.h
//  Insights
//
//  Created by Vineet Pareek on 23/1/17.
//  Copyright © 2017 Yottamark. All rights reserved.
//

#import "JSONModel.h"

@interface ProductRatingDefect : JSONModel

@property (nonatomic, assign) NSInteger rating_id;
@property (nonatomic, assign) NSInteger defect_family_id;

@end
