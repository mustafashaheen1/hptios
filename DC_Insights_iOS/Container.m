//
//  Container.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/23/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "Container.h"
#import "Rating.h"

@implementation Container

@synthesize containerID;
@synthesize programID;
@synthesize parentID;
@synthesize name;
@synthesize picture_required;
@synthesize ratingsFromUI;
@synthesize displayName;

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        self.containerID = 0;
        self.programID = 0;
        self.parentID = 0;
        self.name = @"";
        self.programVersionNumber = 0;
        self.picture_required = NO;
        self.containerProgramName = @"";
        self.ratingsFromUI = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) addRating:(Rating *) ratingLocal {
    [self.ratingsFromUI addObject:ratingLocal];
}

- (BOOL)isEqual:(id)object {
    Container *copy = (Container *) object;
    if(self.containerID == copy.containerID) {
        return true;
    }
    else
        return false;
}

- (NSUInteger)hash {
    const NSUInteger prime = 31;
    NSUInteger result = 1;
    NSInteger copy = self.containerID;
    result = prime * result + copy;
    return result;
}



/*------------------------------------------------------------------------------
 Get All The Ratings
 -----------------------------------------------------------------------------*/

- (NSArray *) getAllRatings {
    NSMutableArray *ratingsLocal = [[NSMutableArray alloc] init];
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_INSIGHTS_DATA];
    FMResultSet *results;
    [database open];
    results = [database executeQuery:[self retrieveDataFromDBForRatings]];
    while ([results next]) {
        Rating *rating = [[Rating alloc] init];
        rating.ratingID = [results intForColumn:COL_ID];
        rating.name = [results stringForColumn:COL_NAME];
        rating.type = [results stringForColumn:COL_TYPE];
        rating.order_data_field = [results stringForColumn:COL_ORDER_DATA_FIELD];
        rating.displayName = [results stringForColumn:COL_DISPLAY_NAME];
        rating.is_numeric = [results intForColumn:COL_IS_NUMERIC];
        NSDictionary *contentDict = [NSKeyedUnarchiver unarchiveObjectWithData:[results dataForColumn:COL_CONTENT]];
        Content *content = [[Content alloc] init];
        TextRatingModel *textRatingModel;
        BooleanRatingModel *booleanRatingModel;
        NumericRatingModel *numericRatingModel;
        PriceRatingModel *priceRatingModel;
        ComboRatingModel *comboRatingModel;
        NSMutableArray *starRatingsLocal = [[NSMutableArray alloc] init];
        if ([rating.type isEqualToString:STAR_RATING]) {
            NSArray *starRatingsPreProcessed = [self parseArrayFromJson:contentDict key:@"star_items"];
            for (NSDictionary *star in starRatingsPreProcessed) {
                StarRatingModel *starRatingModel = [[StarRatingModel alloc] init];
                starRatingModel.description = [self parseStringFromJson:star key:@"description"];
                starRatingModel.starRatingID = [self parseIntegerFromJson:star key:@"id"];
                starRatingModel.image_id = [self parseIntegerFromJson:star key:@"image_id"];
                starRatingModel.image_url = [self parseStringFromJson:star key:@"image_url"];
                starRatingModel.label = [self parseStringFromJson:star key:@"label"];
                [starRatingsLocal addObject:starRatingModel];
            }
        } else if ([rating.type isEqualToString:COMBO_BOX_RATING]) {
            comboRatingModel = [[ComboRatingModel alloc] init];
            comboRatingModel.comboItems = [self parseArrayFromJson:contentDict key:@"combo_items"];
        } else if ([rating.type isEqualToString:NUMERIC_RATING]) {
            numericRatingModel = [[NumericRatingModel alloc] init];
            numericRatingModel.max_value = [self parseDoubleFromJson:contentDict key:@"max_value"];
            numericRatingModel.min_value = [self parseDoubleFromJson:contentDict key:@"min_value"];
            numericRatingModel.numeric_type = [self parseStringFromJson:contentDict key:@"numeric_type"];
            numericRatingModel.units = [self parseArrayFromJson:contentDict key:@"units"];
        } else if ([rating.type isEqualToString:PRICE_RATING]) {
            priceRatingModel = [[PriceRatingModel alloc] init];
            priceRatingModel.price_items = [self parseArrayFromJson:contentDict key:@"price_items"];
        } else if ([rating.type isEqualToString:TEXT_RATING]) {
            textRatingModel = [[TextRatingModel alloc] init];
            textRatingModel.text = [self parseStringFromJson:contentDict key:@"content"];
        } else if ([rating.type isEqualToString:BOOLEAN_RATING]) {
            booleanRatingModel = [[BooleanRatingModel alloc] init];
            booleanRatingModel.boolChoice = [self parseBoolFromJson:contentDict key:@"content"];
        }
        content.star_items = starRatingsLocal;
        content.comboRatingModel = comboRatingModel;
        content.priceRatingModel = priceRatingModel;
        content.numericRatingModel = numericRatingModel;
        content.booleanRatingModel = booleanRatingModel;
        content.textRatingModel = textRatingModel;
        rating.content = content;
        [rating populateThresholdsForRating:self.containerID withProgramId:self.programID withDatabase:database];
        rating.order_position = [results intForColumn:@"order_position"];

        rating.order_position = [results intForColumn:COL_ORDER_POSITION];
        rating.defect_family_id = [results intForColumn:COL_DEFECT_FAMILY_ID];
        rating.order_position = [results intForColumn:COL_ORDER_POSITION];

        NSArray *defectsArray = [NSKeyedUnarchiver unarchiveObjectWithData:[results dataForColumn:COL_DEFECTS]];
        rating.defectsIdList = [defectsArray mutableCopy];
        [ratingsLocal addObject:rating];
    }
    NSArray *sortedRatings = [self getRatingsInSortedOrder:ratingsLocal];    
    [database close];
    return sortedRatings;
}

- (NSArray *) getRatingsInSortedOrder: (NSArray *) sortRatingsArray {
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"order_position" ascending:YES];
    NSArray *sortDescriptors = @[sort];
    NSArray *sortedArray = [sortRatingsArray sortedArrayUsingDescriptors:sortDescriptors];
    return sortedArray;
}

#pragma mark - SQL Retrieve Data Methods

- (NSString *) retrieveDataFromDBForRatings {
    NSArray *selectColumns = [NSArray arrayWithObjects:@"", nil];
    NSArray *tables = [NSArray arrayWithObjects:TBL_CONTAINER_RATINGS, TBL_RATINGS, nil];
    NSArray *joinCriteria = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%@.%@", TBL_CONTAINER_RATINGS, COL_RATING_ID], [NSString stringWithFormat:@"%@.%@", TBL_RATINGS, COL_ID], nil];
    NSString *where = [NSString stringWithFormat:@"%@.%@=%d", TBL_CONTAINER_RATINGS, COL_CONTAINER_ID, self.containerID];
    NSString *retrieveStatement = [[DBManager sharedDBManager] buildLeftJoinQuery:selectColumns withTables:tables withJoinCriteria:joinCriteria andWhereClause:where];
    //NSLog(@"retrwe %@", retrieveStatement);
    return retrieveStatement;
}

- (Defect *)setDefectAttributesFromMap:(NSString *)defectID {
    Defect *defect = [[Defect alloc] init];
    if (defectID) {
        defect.defectID = [defectID integerValue];
    }
    return defect;
}

+ (NSString *) getContainerNameFromContainerId: (NSString *) containerIDLocal {
    FMDatabase *databaseGroupRatings = [[DBManager sharedDBManager] openDatabase:DB_INSIGHTS_DATA];
    FMResultSet *results;
    [databaseGroupRatings open];
    results = [databaseGroupRatings executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE id=%@", TBL_CONTAINERS, containerIDLocal]];
    NSString *nameLocal = @"";
    while ([results next]) {
        nameLocal = [results stringForColumn:COL_DISPLAY_NAME];
    }
    [databaseGroupRatings close];
    return nameLocal;
}


@end
