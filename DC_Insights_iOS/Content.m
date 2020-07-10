//
//  Content.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/27/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "Content.h"

@implementation Content

@synthesize comboRatingModel;
@synthesize priceRatingModel;
@synthesize numericRatingModel;
@synthesize starRatingModel;
@synthesize booleanRatingModel;
@synthesize textRatingModel;
@synthesize locationRatingModel;
@synthesize star_items;

- (id)init
{
    self = [super init];
    if (self) {
        self.comboRatingModel = [[ComboRatingModel alloc] init];
        self.priceRatingModel = [[PriceRatingModel alloc] init];
        self.numericRatingModel = [[NumericRatingModel alloc] init];
        self.starRatingModel = [[StarRatingModel alloc] init];
        self.booleanRatingModel = [[BooleanRatingModel alloc] init];
        self.textRatingModel = [[TextRatingModel alloc] init];
        self.locationRatingModel = [[LocationRatingModel alloc] init];
        self.star_items = [[NSArray alloc] init];
        self.combo_items = [[NSMutableArray alloc]init];
    }
    return self;
}

+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}


@end
