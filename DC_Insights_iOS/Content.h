//
//  Content.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/27/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "DCBaseEntity.h"
#import "ComboRatingModel.h"
#import "PriceRatingModel.h"
#import "NumericRatingModel.h"
#import "StarRatingModel.h"
#import "BooleanRatingModel.h"
#import "TextRatingModel.h"
#import "LocationRatingModel.h"
#import "JSONModel.h"
#import "GenericRatingModel.h"

@protocol Content
@end
#import "DateRatingModel.h"

@interface Content : JSONModel

@property (nonatomic, strong) ComboRatingModel *comboRatingModel;
@property (nonatomic, strong) PriceRatingModel *priceRatingModel;
@property (nonatomic, strong) NumericRatingModel *numericRatingModel;
@property (nonatomic, strong) StarRatingModel *starRatingModel;
@property (nonatomic, strong) BooleanRatingModel *booleanRatingModel;
@property (nonatomic, strong) TextRatingModel *textRatingModel;
@property (nonatomic, strong) LocationRatingModel *locationRatingModel;
@property (nonatomic, strong) DateRatingModel *dateRatingModel;
@property (nonatomic, strong) NSArray *star_items;

//for JSONModel
@property (nonatomic, strong) NSMutableArray *combo_items;


@end
