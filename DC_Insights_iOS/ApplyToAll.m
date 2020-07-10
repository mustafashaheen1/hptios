//
//  ApplyToAll.m
//  Insights
//
//  Created by Vineet on 9/26/18.
//  Copyright © 2018 Yottamark. All rights reserved.
//

#import "ApplyToAll.h"
#import "ParseJsonUtil.h"

@implementation ApplyToAll

-(ApplyToAll*) initFromJSONDictionary:(NSDictionary*)dataMap {
    NSDictionary* applyToAllString = [ParseJsonUtil parseDictFromJson:dataMap key:@"apply_to_all"];
    NSError *error;
    NSArray* ratingsDict = [ParseJsonUtil parseArrayFromJson:[ParseJsonUtil parseDictFromJson:dataMap key:@"apply_to_all"] key:@"ratings"];
   // ApplyToAll* applyToAll = [[ApplyToAll alloc] initWithString:applyToAllString error:&error];
    ApplyToAll* applyToAll = [[ApplyToAll alloc] initWithDictionary:applyToAllString error:&error];
   
    [applyToAll.ratings removeAllObjects];
    for(NSDictionary *rating in ratingsDict){
        Rating *tempRating = [self setAttributesFromMap:rating];
        [applyToAll.ratings addObject:tempRating];
    }
    self.active = applyToAll.active;
    self.ratings = applyToAll.ratings;
    return self;
}

-(ApplyToAll*) initFromJSONString:(NSString*)data {
    NSError *error;
    ApplyToAll* applyToAll = [[ApplyToAll alloc] initWithString:data error:&error];
    self.active = applyToAll.active;
    self.ratings = applyToAll.ratings;
  
    return self;
}
         
         - (Rating *)setAttributesFromMap:(NSDictionary*)dataMap {
             Rating *rating = [[Rating alloc] init];
             if (dataMap) {
                 rating.description = [ParseJsonUtil parseStringFromJson:dataMap key:@"description"];
                 rating.ratingID = [ParseJsonUtil parseIntegerFromJson:dataMap key:@"id"];
                 rating.name = [ParseJsonUtil parseStringFromJson:dataMap key:@"name"];
                 rating.displayName = [ParseJsonUtil parseStringFromJson:dataMap key:@"display"];
                 rating.type = [ParseJsonUtil parseStringFromJson:dataMap key:@"type"];
                 rating.contentPreProcessed = [ParseJsonUtil parseDictFromJson:dataMap key:@"content"];
                 rating.order_data_field = [ParseJsonUtil parseStringFromJson:dataMap key:@"order_data_field"];
                 rating.defects = [[ParseJsonUtil parseArrayFromJson:dataMap key:@"defects"] mutableCopy];
                 rating.is_numeric = [ParseJsonUtil parseIntegerFromJson:dataMap key:@"is_numeric"];
                 Content *content = [[Content alloc] init];
                 TextRatingModel *textRatingModel;
                 BooleanRatingModel *booleanRatingModel;
                 NumericRatingModel *numericRatingModel;
                 PriceRatingModel *priceRatingModel;
                 ComboRatingModel *comboRatingModel;
                 DateRatingModel *dateRatingModel;
                 NSMutableArray *starRatingsLocal = [[NSMutableArray alloc] init];
                 if ([[ParseJsonUtil parseStringFromJson:dataMap key:@"type"] isEqualToString:STAR_RATING]) {
                     NSArray *starRatingsPreProcessed = [ParseJsonUtil parseArrayFromJson:[ParseJsonUtil parseDictFromJson:dataMap key:@"content"] key:@"star_items"];
                     for (NSDictionary *star in starRatingsPreProcessed) {
                         StarRatingModel *starRatingModel = [[StarRatingModel alloc] init];
                         starRatingModel.description = [ParseJsonUtil parseStringFromJson:star key:@"description"];
                         starRatingModel.starRatingID = [ParseJsonUtil parseIntegerFromJson:star key:@"id"];
                         starRatingModel.image_id = [ParseJsonUtil parseIntegerFromJson:star key:@"image_id"];
                         starRatingModel.image_url = [ParseJsonUtil parseStringFromJson:star key:@"image_url"];
                         starRatingModel.label = [ParseJsonUtil parseStringFromJson:star key:@"label"];
                         [starRatingsLocal addObject:starRatingModel];
                     }
                 } else if ([[ParseJsonUtil parseStringFromJson:dataMap key:@"type"] isEqualToString:COMBO_BOX_RATING]) {
                     comboRatingModel = [[ComboRatingModel alloc] init];
                     comboRatingModel.comboItems = [ParseJsonUtil parseArrayFromJson:[ParseJsonUtil parseDictFromJson:dataMap key:@"content"] key:@"combo_items"];
                 } else if ([[ParseJsonUtil parseStringFromJson:dataMap key:@"type"] isEqualToString:NUMERIC_RATING]) {
                     numericRatingModel = [[NumericRatingModel alloc] init];
                     numericRatingModel.max_value = [ParseJsonUtil parseDoubleFromJson:[ParseJsonUtil parseDictFromJson:dataMap key:@"content"] key:@"max_value"];
                     numericRatingModel.min_value = [ParseJsonUtil parseDoubleFromJson:[ParseJsonUtil parseDictFromJson:dataMap key:@"content"] key:@"min_value"];
                     numericRatingModel.numeric_type = [ParseJsonUtil parseStringFromJson:[ParseJsonUtil parseDictFromJson:dataMap key:@"content"] key:@"numeric_type"];
                     numericRatingModel.units = [ParseJsonUtil parseArrayFromJson:[ParseJsonUtil parseDictFromJson:dataMap key:@"content"] key:@"units"];
                 } else if ([[ParseJsonUtil parseStringFromJson:dataMap key:@"type"] isEqualToString:PRICE_RATING]) {
                     priceRatingModel = [[PriceRatingModel alloc] init];
                     priceRatingModel.price_items = [ParseJsonUtil parseArrayFromJson:[ParseJsonUtil parseDictFromJson:dataMap key:@"content"] key:@"price_items"];
                 } else if ([[ParseJsonUtil parseStringFromJson:dataMap key:@"type"] isEqualToString:TEXT_RATING]) {
                     textRatingModel = [[TextRatingModel alloc] init];
                     textRatingModel.text = @"";//[self parseStringFromJson:[self parseDictFromJson:dataMap key:@"content"] key:@""];
                 } else if ([[ParseJsonUtil parseStringFromJson:dataMap key:@"type"] isEqualToString:BOOLEAN_RATING]) {
                     booleanRatingModel = [[BooleanRatingModel alloc] init];
                     booleanRatingModel.boolChoice = NO;//[self parseStringFromJson:[self parseDictFromJson:dataMap key:@"content"] key:@""];
                 }else if ([[ParseJsonUtil parseStringFromJson:dataMap key:@"type"] isEqualToString:DATE_RATING]) {
                     dateRatingModel = [[DateRatingModel alloc] init];
                 }
                 content.star_items = starRatingsLocal;
                 content.comboRatingModel = comboRatingModel;
                 content.priceRatingModel = priceRatingModel;
                 content.numericRatingModel = numericRatingModel;
                 content.booleanRatingModel = booleanRatingModel;
                 content.textRatingModel = textRatingModel;
                 content.dateRatingModel = dateRatingModel;
                 rating.content = content;
             }
             return rating;
         }
@end
