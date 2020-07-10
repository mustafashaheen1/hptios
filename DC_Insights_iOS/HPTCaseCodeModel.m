//
//  HPTCaseCodeModel.m
//  Insights
//
//  Created by Mustafa Shaheen on 6/18/20.
//  Copyright © 2020 Yottamark. All rights reserved.
//

#import "HPTCaseCodeModel.h"
#import "Rating.h"
#import "HPTCaseCode.h"
#import "Store.h"
@implementation HPTCaseCodeModel

- (NSArray *) getAllRatings {
    
    NSMutableArray *ratingsLocal = [[NSMutableArray alloc] init];
    NSMutableArray *qualityManuals = [[NSMutableArray alloc]init];
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_INSIGHTS_DATA];
    FMResultSet *results;
    [database open];
    results = [database executeQuery:@"SELECT * FROM RATINGS"];
    while ([results next]) {
        Rating *rating = [[Rating alloc] init];
        rating.ratingID = [results intForColumn:COL_ID];
        rating.groupRatingID = [results intForColumn:COL_GROUP_ID];
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
        LocationRatingModel *locationRatingModel;
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
        }else if ([rating.type isEqualToString:LOCATION_RATING]) {
            locationRatingModel = [[LocationRatingModel alloc] init];
            locationRatingModel.comboItems = [self getLocationRatings];
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
        content.locationRatingModel = locationRatingModel;
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

        [ratingsLocal addObject:rating];
    }
    [database close];

    return [self getContainerRatings: ratingsLocal];
}

-(NSArray *) getLocationRatings{
    NSMutableArray *locationRatings = [[NSMutableArray alloc] init];
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_INSIGHTS_DATA];
    FMResultSet *results;
    [database open];
    results = [database executeQuery:@"SELECT * FROM LOCATIONS"];
    while ([results next]) {
        
        NSString *gln = @"";
        NSString *name = [results stringForColumn:COL_NAME];
        if(name == nil)
            name = @"";
        NSString *address = [results stringForColumn:COL_ADDRESS];
        if(address == nil)
            address = @"";
        NSString *city = [results stringForColumn:COL_CITY];
        if(city == nil)
            city = @"";
        NSString *state = [results stringForColumn:COL_STATE];
        if(state == nil)
            state = @"";
        int postCode = [results intForColumn:COL_POSTCODE];
        if(postCode == nil)
            postCode = 0;
        NSString *country = [results stringForColumn:COL_COUNTRY];
        if(country == nil)
            country = @"";
         gln = [results stringForColumn:COL_GLN];
        if(gln == nil){
            gln = @"";
        }
        NSMutableString *location =  [@"" mutableCopy];
        [location appendString:name];
        [location appendString:@", "];
        [location appendString:address];
        [location appendString:@", "];
        [location appendString:city];
        [location appendString:@", "];
        [location appendString:state];
        [location appendString:@"\n"];
        [location appendString:[NSString stringWithFormat:@"%d",postCode]];
        [location appendString:@", "];
        [location appendString:country];
        [location appendString:@"\n"];
        [location appendString:gln];
        
        [locationRatings addObject:location];
        
    }
    [database close];
    return [locationRatings copy];
}
-(NSArray *) getContainerRatings: (NSArray *) ratings {
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_INSIGHTS_DATA];
    FMResultSet *results;
    NSMutableArray *containerRatings = [[NSMutableArray alloc] init];
    [database open];
    results = [database executeQuery:@"SELECT * FROM CONTAINER_RATINGS"];
    while ([results next]) {
        int ratingId = [results intForColumn:COL_RATING_ID];
        for(Rating *rating in ratings){
            if(ratingId == rating.ratingID){
                [containerRatings addObject:rating];
            }
        }
        
    }
    [database close];
    return [containerRatings copy];
}
-(void) setValuesFromViews: (NSArray *) tempRatings: (NSArray *) caseCodeList: (HPTAddress *) toAddress: (NSString *) sscc{
    if(caseCodeList != nil){
        self.caseCodes = [[NSMutableArray alloc] init];
        self.caseCodes = caseCodeList;
    }
    self.toAddress = toAddress;
    self.sscc = sscc;
    self.ratings = tempRatings;
}

-(void) setValuesFromViews: (NSArray *) tempRatings{
    
    for(Rating *rating in tempRatings){
        [self.ratings addObject:rating];
    }
    
    
}
-(BOOL) validate{
    
    for(HPTCaseCode *caseCode in self.caseCodes){
        if(![caseCode validate]){
            return NO;
        }
        if(self.caseCodes.count == 0){
            return NO;
        }
        return YES;
    }
    return NO;
}
-(HPTAddress *) convert: (Store *) store{
    HPTAddress *address = [[HPTAddress alloc] init];
    address.companyName = store.name;
    address.city = store.city;
    address.state = store.state;
    address.streetAddress = store.address;
    address.zip = [NSString stringWithFormat:@"%d",store.postCode];
    
    return address;
}


@end
