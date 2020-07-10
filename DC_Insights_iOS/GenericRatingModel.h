//
//  GenericRatingModel.h
//  Insights
//
//  Created by Vineet on 10/1/18.
//  Copyright © 2018 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GenericRatingModel

@end

@interface GenericRatingModel : NSObject

@property (nonatomic, strong) NSArray *combo_items;

@end

