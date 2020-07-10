//
//  DCProduct.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/19/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "Product.h"
#import "Rating.h"

@implementation Product

@synthesize commodity;
@synthesize group_id;
@synthesize insights_product;
@synthesize plus;
@synthesize upcs;
@synthesize product_id;
@synthesize product_name;
@synthesize program_id;
@synthesize require_hm_code;
@synthesize variety;
@synthesize qualityManual;
@synthesize qualityManualPreProcessed;
@synthesize ratingsFromUI;
@synthesize isFlagged;
@synthesize name;
@synthesize subProductsArray;

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        self.ratingsFromUI = [[NSMutableArray alloc] init];
        self.auditsCount = 0;
        self.savedAudit = [[SavedAudit alloc] init];
        self.rating_defects = [[NSMutableArray alloc]init];
        self.isFlagged = NO;
        self.allFlaggedProductMessages = [[NSMutableArray alloc]init];
        self.score = @"";
        
    }
    return self;
}

- (void) addRating:(Rating *) rating {
    [self.ratingsFromUI addObject:rating];
}

- (BOOL)isEqual:(id)object {
    Product *copy = (Product *) object;
    if (self == copy)
        return true;
    if (![super isEqual:copy])
        return false;
    if ([self class] != [copy class])
        return false;
    if(self.product_id == copy.product_id) {
        return true;
    }
    else
        return false;
}

- (NSUInteger)hash {
    const NSUInteger prime = 31;
    NSUInteger result = 1;
    NSInteger copy = self.product_id;
    result = prime * result + copy;
    return result;
}


/*------------------------------------------------------------------------------
 Get All The Ratings
 -----------------------------------------------------------------------------*/

- (NSArray *) getAllRatings {
    
    NSArray *ratingIds = [self getGroupRatingIds];
    NSMutableArray *ratingsLocal = [[NSMutableArray alloc] init];
    NSMutableArray *qualityManuals = [[NSMutableArray alloc]init];
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_INSIGHTS_DATA];
    FMResultSet *results;
    [database open];
    results = [database executeQuery:[self retrieveDataFromDBForRatings]];
    while ([results next]) {
        Rating *rating = [[Rating alloc] init];
        rating.ratingID = [results intForColumn:COL_ID];
        rating.groupRatingID = [results intForColumn:COL_GROUP_ID];
        if (![ratingIds containsObject:[NSNumber numberWithInt:rating.groupRatingID]]) {
            continue;
        }
        rating.name = [results stringForColumn:COL_NAME];
        rating.type = [results stringForColumn:COL_TYPE];
        rating.order_data_field = [results stringForColumn:COL_ORDER_DATA_FIELD];
        rating.displayName = [results stringForColumn:COL_DISPLAY_NAME];
        
        
        rating.is_numeric = [results intForColumn:COL_IS_NUMERIC];
        rating.description = [results stringForColumn:COL_DESCRIPTION];
        NSDictionary *contentDict = [NSKeyedUnarchiver unarchiveObjectWithData:[results dataForColumn:COL_CONTENT]];
        Content *content = [[Content alloc] init];
        TextRatingModel *textRatingModel;
        BooleanRatingModel *booleanRatingModel;
        NumericRatingModel *numericRatingModel;
        PriceRatingModel *priceRatingModel;
        ComboRatingModel *comboRatingModel;
        DateRatingModel *dateRatingModel;
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
            content.star_items = starRatingsLocal;
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
        }else if ([rating.type isEqualToString:DATE_RATING]) {
            dateRatingModel = [[DateRatingModel alloc] init];
            dateRatingModel.isDaysRemainingValidation = [self parseBoolFromJson:contentDict key:@"days_remaining_validation"];
        }
        content.comboRatingModel = comboRatingModel;
        content.priceRatingModel = priceRatingModel;
        content.numericRatingModel = numericRatingModel;
        content.booleanRatingModel = booleanRatingModel;
        content.textRatingModel = textRatingModel;
        content.dateRatingModel = dateRatingModel;
        rating.content = content;
        rating.order_position = [results intForColumn:COL_ORDER_POSITION];
        rating.defect_family_id = [results intForColumn:COL_DEFECT_FAMILY_ID];
        rating.default_star = [results intForColumn:COL_DEFAULT_STAR];
        rating.order_position = [results intForColumn:@"order_position"];
        
        NSDictionary *optionalSettingsDict = [NSKeyedUnarchiver unarchiveObjectWithData:[results dataForColumn:COL_OPTIONAL_SETTINGS]];
        OptionalSettings *optionalSettings = [[OptionalSettings alloc] init];
        optionalSettings.optional = [self parseBoolFromJson:optionalSettingsDict key:@"optional"];
        optionalSettings.persistent = [self parseBoolFromJson:optionalSettingsDict key:@"persistent"];
        optionalSettings.picture = [self parseBoolFromJson:optionalSettingsDict key:@"picture"];
        optionalSettings.defects = [self parseBoolFromJson:optionalSettingsDict key:@"defects"];
        optionalSettings.scannable = [self parseBoolFromJson:optionalSettingsDict key:@"scannable"];
        optionalSettings.rating = [self parseBoolFromJson:optionalSettingsDict key:@"rating"];
        optionalSettings.productSpecified = [self parseBoolFromJson:optionalSettingsDict key:@"productSpecified"];
        rating.optionalSettings = optionalSettings;
        
        NSDictionary *thresholdsDict = [NSKeyedUnarchiver unarchiveObjectWithData:[results dataForColumn:COL_THRESHOLDS]];
        PictureAndDefectThresholds *pictureAndDefectThresholdsLocal = [[PictureAndDefectThresholds alloc] init];
        pictureAndDefectThresholdsLocal.picture = [self parseIntegerFromJson:thresholdsDict key:@"picture"];
        pictureAndDefectThresholdsLocal.defects = [self parseIntegerFromJson:thresholdsDict key:@"defects"];
        rating.pictureAndDefectThresholds = pictureAndDefectThresholdsLocal;
    
        NSArray *defectsArray = [NSKeyedUnarchiver unarchiveObjectWithData:[results dataForColumn:COL_DEFECTS]];
        rating.defectsIdList = [defectsArray mutableCopy];
        //select the defects based on the product//
        //if(rating.optionalSettings.productSpecified) //isProductSpecific
       // {
            rating.defect_family_id = [self getDefectFamilyIdForRating:rating.ratingID];
            if(rating.defect_family_id>0)
                rating.defectsIdList = [self getDefectsForDefectFamily:rating.defect_family_id];
        
        //}
        //populate the QualityManuals
        if(rating.defect_family_id>0){
            QualityManual *qualityManualForRating = [self getQualityManualForDefectFamily:rating.defect_family_id];
            if(qualityManualForRating)
                [qualityManuals addObject:qualityManualForRating];
        }
        if(program_id == 1){
            if(([rating.order_data_field isEqualToString:@"QuantityOfCases"]) && (rating.order_position == 1)){
                rating.order_data_field = @"QuantityOfItems";
        }
        }
        [ratingsLocal addObject:rating];
    }
    [database close];
    NSArray *sortedRatings = [self getRatingsInSortedOrder:ratingsLocal];
    self.ratings = sortedRatings;
    self.qualityManuals = qualityManuals;//all manuals for all ratings
    return sortedRatings;
}

//if product-specific then get the list of defects from the products
-(NSInteger)getDefectFamilyIdForRating:(NSInteger)ratingId{
    //go to TBL_PRODUCTS and search for defect_family_id based on product_id/rating_id
    NSInteger defectFamilyId = 0;
    if(self.rating_defects && [self.rating_defects count]>0){
        //need to parse out the individual array objects
        for(NSDictionary* ratingDefectObject in self.rating_defects){
         ProductRatingDefect *productRatingDefect = [[ProductRatingDefect alloc] initWithDictionary:ratingDefectObject error:nil];
            if(productRatingDefect.rating_id == ratingId){
                defectFamilyId = productRatingDefect.defect_family_id;
            }
        }
    }
    return defectFamilyId;
}

//get to TBL_DEFECT_FAMILY and get the list of defects for above defect_family_id
-(NSMutableArray*)getDefectsForDefectFamily:(NSInteger)defectFamilyId{
    NSMutableArray* defectIds = [[NSMutableArray alloc]init];
    NSString *retrieveStatement = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%d", TBL_DEFECT_FAMILIES, COL_ID,(int)defectFamilyId];
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_INSIGHTS_DATA];
    FMResultSet *results;
    [database open];
    results = [database executeQuery:retrieveStatement];
    while ([results next]) {
        defectIds = [NSKeyedUnarchiver unarchiveObjectWithData:[results dataForColumn:COL_DEFECTS]];
    }
    [database close];
    return defectIds;
}

-(QualityManual*)getQualityManualForDefectFamily:(NSInteger)defectFamilyId{
    NSDictionary* qualityManualContent = [[NSDictionary alloc]init];
    QualityManual *qualityManual = nil;
    NSString *retrieveStatement = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%d", TBL_DEFECT_FAMILIES, COL_ID,(int)defectFamilyId];
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_INSIGHTS_DATA];
    FMResultSet *results;
    [database open];
    results = [database executeQuery:retrieveStatement];
    while ([results next]) {
        qualityManualContent = [NSKeyedUnarchiver unarchiveObjectWithData:[results dataForColumn:COL_QUALITY_MANUAL_CONTENT]];
        if(qualityManualContent){
            qualityManual = [[QualityManual alloc] init];
            qualityManual.pdf = [self parseStringFromJson:qualityManualContent key:@"pdf"];
            qualityManual.html = [self parseStringFromJson:qualityManualContent key:@"html"];
            qualityManual.updated_at = [self parseStringFromJson:qualityManualContent key:@"updated_at"];
        }
    }
    [database close];
    if(!qualityManual.pdf && !qualityManual.html)
        return nil;
    
    return qualityManual;
}

- (NSArray *) getRatingsInSortedOrder: (NSArray *) sortRatingsArray {
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"order_position" ascending:YES];
    NSArray *sortDescriptors = @[sort];
    NSArray *sortedArray = [sortRatingsArray sortedArrayUsingDescriptors:sortDescriptors];
    return sortedArray;
}

- (NSArray *) getGroupRatingIds {
    NSMutableArray *ratingIds = [[NSMutableArray alloc] init];
    FMDatabase *databaseGroupRatings = [[DBManager sharedDBManager] openDatabase:DB_INSIGHTS_DATA];
    FMResultSet *resultsGroupRatings;
    [databaseGroupRatings open];
    resultsGroupRatings = [databaseGroupRatings executeQuery:[self retrieveDataFromDBForGroupRatings]];
    while ([resultsGroupRatings next]) {        
        [ratingIds addObject:[NSNumber numberWithInt:[resultsGroupRatings intForColumn:COL_ID]]];
    }
    [databaseGroupRatings close];
    return [ratingIds copy];
}

#pragma mark - SQL Retrieve Data Methods

- (NSString *) retrieveDataFromDBForRatings {
    NSArray *selectColumns = [NSArray arrayWithObjects:@"", nil];
    NSArray *tables = [NSArray arrayWithObjects:TBL_GROUP_RATINGS, TBL_RATINGS, nil];
    NSArray *joinCriteria = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%@.%@", TBL_GROUP_RATINGS, COL_ID], [NSString stringWithFormat:@"%@.%@", TBL_RATINGS, COL_ID], nil];
    NSString *retrieveStatement = [[DBManager sharedDBManager] buildLeftJoinQuery:selectColumns withTables:tables withJoinCriteria:joinCriteria andWhereClause:nil];
    return retrieveStatement;
}

- (NSString *) retrieveDataFromDBForGroupRatings {
    NSString *retrieveStatement = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%d", TBL_GROUPS, COL_ID, self.group_id];
    return retrieveStatement;
}

-(id) mutableCopyWithZone: (NSZone *) zone {
    Product *product = [[Product alloc]init];
    product.commodity = self.commodity;
    product.group_id = self.group_id;
    product.insights_product = self.insights_product;
    product.plus = [self.plus copy];
    product.upcs = [self.upcs copy];
    product.skus = [self.skus copy];
    product.containers = [self.containers copy];
    product.product_id = self.product_id;
    product.auditsCount = self.auditsCount;
    product.countOfCases = self.countOfCases;
    product.product_name = self.product_name;
    product.program_version = self.program_version;
    product.program_id = self.program_id;
    product.require_hm_code = self.require_hm_code;
    product.variety = self.variety;
    product.qualityManual = self.qualityManual;
    product.qualityManualPreProcessed = [self.qualityManualPreProcessed copy];
    product.ratingsFromUI = [self.ratingsFromUI copy];;
    product.rating_defects = [self.rating_defects copy];
    product.name = self.name;
    product.subProductsArray = [self.subProductsArray copy];
    product.ratings = [self.ratings copy];;
    product.selectedSku = self.selectedSku;
    product.savedAudit = self.savedAudit;
    product.daysRemaining = self.daysRemaining;
    product.daysRemainingMax = self.daysRemainingMax;
    product.isFlagged = self.isFlagged;
    product.allFlaggedProductMessages = self.allFlaggedProductMessages;
    product.score = self.score;
    return product;

}

-(Product*) getCopy {
    Product *product = [[Product alloc]init];
    product.commodity = self.commodity;
    product.group_id = self.group_id;
    product.insights_product = self.insights_product;
    product.plus = [self.plus copy];
    product.upcs = [self.upcs copy];
    product.skus = [self.skus copy];
    product.containers = [self.containers copy];
    product.product_id = self.product_id;
    product.auditsCount = self.auditsCount;
    product.countOfCases = self.countOfCases;
    product.product_name = self.product_name;
    product.program_version = self.program_version;
    product.program_id = self.program_id;
    product.require_hm_code = self.require_hm_code;
    product.variety = self.variety;
    product.qualityManual = self.qualityManual;
    product.qualityManualPreProcessed = [self.qualityManualPreProcessed copy];
    product.ratingsFromUI = [self.ratingsFromUI copy];;
    product.rating_defects = [self.rating_defects copy];
    product.name = self.name;
    product.subProductsArray = [self.subProductsArray copy];
    product.ratings = [self.ratings copy];;
    product.selectedSku = self.selectedSku;
    product.savedAudit = self.savedAudit;
    product.daysRemaining = self.daysRemaining;
    product.daysRemainingMax = self.daysRemainingMax;
    product.isFlagged = self.isFlagged;
    product.allFlaggedProductMessages = self.allFlaggedProductMessages;
    product.score = self.score;
    return product;
}

@end

