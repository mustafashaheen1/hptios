//
//  Rating.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/11/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "RatingAPI.h"
#import "Rating.h"
#import "DBManager.h"
#import "ComboRatingModel.h"
#import "PriceRatingModel.h"
#import "NumericRatingModel.h"
#import "StarRatingModel.h"
#import "BooleanRatingModel.h"
#import "TextRatingModel.h"
#import "Image.h"
#import "Rating.h"
#import "PaginationCallsClass.h"
#import "DateRatingModel.h"

@implementation RatingAPI

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
    
    }
    return self;
}

/// Call Ratings

//- (void)ratingsCallWithBlock:(void (^)(BOOL isSuccess, NSArray *array, NSError *error))block {
//    NSDictionary *localStoreCallParamaters = [self paramtersFortheGETCall];
//    if ([localStoreCallParamaters count] > 0) {
//        [[AFAppDotNetAPIClient sharedClient] getPath:Ratings parameters:localStoreCallParamaters success:^(AFHTTPRequestOperation *operation, id JSON) {
//            id JSONLocal;
//            BOOL successWrite= [self writeDataToFile:RatingsFilePath withContents:JSON];
//            if (successWrite) {
//                JSONLocal = [self readDataFromFile:RatingsFilePath];
//            }
//            NSLog(@"RatingLocal %@", JSONLocal);
//            self.ratingsArray = [self getRatingsFromArray:JSONLocal];
//            if (block) {
//                block(successWrite, nil, nil);
//            }
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            if (block) {
//                block(NO, nil, nil);
//            }
//        }];
//    }
//}

- (void)ratingsCallWithBlock:(void (^)(BOOL isSuccess, NSArray *array, NSError *error))block {
    if (PAGINATE_SYNC_API) {
        PaginationCallsClass *paginate = [[PaginationCallsClass alloc] init];
        paginate.minimumNumberOfCalls = minimumNumberForCalls;
        paginate.limit = limitPerPage;
        paginate.pageNo = initialPageNo;
        paginate.apiCallString = Ratings;
        paginate.apiCallFilePath = RatingsFilePath;
        [paginate callWithBlock:^(BOOL isSuccess, NSArray *array, NSError *error) {
            if (error) {
                if (block) {
                    block(NO, nil, nil);
                }
            } else {
                self.ratingsArray = [self getRatingsFromArray:array];
                if (block) {
                    block(YES, nil, nil);
                }
            }
        }];
    } else {
        NSDictionary *localStoreCallParamaters = [self paramtersFortheGETCall];
        if ([localStoreCallParamaters count] > 0) {
            [[AFAppDotNetAPIClient sharedClient] getPath:Ratings parameters:localStoreCallParamaters success:^(AFHTTPRequestOperation *operation, id JSON) {
                id JSONLocal;
                BOOL successWrite= [self writeDataToFile:RatingsFilePath withContents:JSON];
                if (successWrite) {
                    JSONLocal = [self readDataFromFile:RatingsFilePath];
                }
                NSLog(@"RatingLocal %@", JSONLocal);
                self.ratingsArray = [self getRatingsFromArray:JSONLocal];
                if (block) {
                    block(successWrite, nil, nil);
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                if (block) {
                    block(NO, nil, nil);
                }
            }];
        }
    }

}

- (void) downloadCompleteAndItsSafeToInsertDataInToDB {
    [self insertRowDataForDB:self.ratingsArray];
}

-(void) saveApiResponseArray:(NSMutableArray *)array {
    self.ratingsArray = [self getRatingsFromArray:array];
    [self downloadCompleteAndItsSafeToInsertDataInToDB];
}


#pragma mark - Parse Methods

- (NSArray *) getRatingsFromArray :(NSArray *) ratingsArrayBeforeProcessing {
    NSMutableArray *ratingsMutable = [[NSMutableArray alloc] init];
    if (ratingsArrayBeforeProcessing) {
        for (NSDictionary *storeDictionary in ratingsArrayBeforeProcessing) {
            Rating *rating = [self setAttributesFromMap:storeDictionary];
            [ratingsMutable addObject:rating];
        }
    }
    return [ratingsMutable copy];
}

- (Rating *)setAttributesFromMap:(NSDictionary*)dataMap {
    Rating *rating = [[Rating alloc] init];
    if (dataMap) {
        rating.description = [self parseStringFromJson:dataMap key:@"description"];
        rating.ratingID = [self parseIntegerFromJson:dataMap key:@"id"];
        rating.name = [self parseStringFromJson:dataMap key:@"name"];
        rating.displayName = [self parseStringFromJson:dataMap key:@"display"];
        rating.type = [self parseStringFromJson:dataMap key:@"type"];
        rating.contentPreProcessed = [self parseDictFromJson:dataMap key:@"content"];
        rating.order_data_field = [self parseStringFromJson:dataMap key:@"order_data_field"];
        rating.defects = [[self parseArrayFromJson:dataMap key:@"defects"] mutableCopy];
        rating.is_numeric = [self parseIntegerFromJson:dataMap key:@"is_numeric"];
        Content *content = [[Content alloc] init];
        TextRatingModel *textRatingModel;
        BooleanRatingModel *booleanRatingModel;
        NumericRatingModel *numericRatingModel;
        PriceRatingModel *priceRatingModel;
        ComboRatingModel *comboRatingModel;
        DateRatingModel *dateRatingModel;
        NSMutableArray *starRatingsLocal = [[NSMutableArray alloc] init];
        if ([[self parseStringFromJson:dataMap key:@"type"] isEqualToString:STAR_RATING]) {
            NSArray *starRatingsPreProcessed = [self parseArrayFromJson:[self parseDictFromJson:dataMap key:@"content"] key:@"star_items"];
            for (NSDictionary *star in starRatingsPreProcessed) {
                StarRatingModel *starRatingModel = [[StarRatingModel alloc] init];
                starRatingModel.description = [self parseStringFromJson:star key:@"description"];
                starRatingModel.starRatingID = [self parseIntegerFromJson:star key:@"id"];
                starRatingModel.image_id = [self parseIntegerFromJson:star key:@"image_id"];
                starRatingModel.image_url = [self parseStringFromJson:star key:@"image_url"];
                starRatingModel.label = [self parseStringFromJson:star key:@"label"];
                [starRatingsLocal addObject:starRatingModel];
            }
        } else if ([[self parseStringFromJson:dataMap key:@"type"] isEqualToString:COMBO_BOX_RATING]) {
            comboRatingModel = [[ComboRatingModel alloc] init];
            comboRatingModel.comboItems = [self parseArrayFromJson:[self parseDictFromJson:dataMap key:@"content"] key:@"combo_items"];
        } else if ([[self parseStringFromJson:dataMap key:@"type"] isEqualToString:NUMERIC_RATING]) {
            numericRatingModel = [[NumericRatingModel alloc] init];
            numericRatingModel.max_value = [self parseDoubleFromJson:[self parseDictFromJson:dataMap key:@"content"] key:@"max_value"];
            numericRatingModel.min_value = [self parseDoubleFromJson:[self parseDictFromJson:dataMap key:@"content"] key:@"min_value"];
            numericRatingModel.numeric_type = [self parseStringFromJson:[self parseDictFromJson:dataMap key:@"content"] key:@"numeric_type"];
            numericRatingModel.units = [self parseArrayFromJson:[self parseDictFromJson:dataMap key:@"content"] key:@"units"];
        } else if ([[self parseStringFromJson:dataMap key:@"type"] isEqualToString:PRICE_RATING]) {
            priceRatingModel = [[PriceRatingModel alloc] init];
            priceRatingModel.price_items = [self parseArrayFromJson:[self parseDictFromJson:dataMap key:@"content"] key:@"price_items"];
        } else if ([[self parseStringFromJson:dataMap key:@"type"] isEqualToString:TEXT_RATING]) {
            textRatingModel = [[TextRatingModel alloc] init];
            textRatingModel.text = @"";//[self parseStringFromJson:[self parseDictFromJson:dataMap key:@"content"] key:@""];
        } else if ([[self parseStringFromJson:dataMap key:@"type"] isEqualToString:BOOLEAN_RATING]) {
            booleanRatingModel = [[BooleanRatingModel alloc] init];
            booleanRatingModel.boolChoice = NO;//[self parseStringFromJson:[self parseDictFromJson:dataMap key:@"content"] key:@""];
        }else if ([[self parseStringFromJson:dataMap key:@"type"] isEqualToString:DATE_RATING]) {
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

#pragma mark - SQL Methods

+ (NSString *) getTableCreateStatmentForRatings {
    NSString *sql =[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@", TBL_RATINGS];
    sql = [sql stringByAppendingString:@" ("];
    sql = [sql stringByAppendingFormat:@"%@ %@ %@,",COL_ID, SQLITE_TYPE_TEXT,SQLITE_TYPE_PRIMARY_KEY];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_CONTENT, SQLITE_TYPE_BLOB];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_DESCRIPTION, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_NAME, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_DISPLAY_NAME, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_ORDER_DATA_FIELD, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_RATINGS, SQLITE_TYPE_BLOB];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_TYPE, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@",COL_IS_NUMERIC, SQLITE_TYPE_INTEGER];
    sql = [sql stringByAppendingString:@")"];
    return sql;
}

+ (NSString *) getTableCreateStatmentForRatingImages {
    NSString *sql =[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@", TBL_STAR_RATING_IMAGES];
    sql = [sql stringByAppendingString:@" ("];
    sql = [sql stringByAppendingFormat:@"%@ %@ %@,",COL_ID, SQLITE_TYPE_INTEGER,SQLITE_TYPE_PRIMARY_KEY];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_STAR_RATING_NUMBER, SQLITE_TYPE_INTEGER];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_REMOTE_URL, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@",COL_DEVICE_URL, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingString:@")"];
    return sql;
}

- (void) downloadImagesWithBlock:(void (^)(BOOL isReceived))success {
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_INSIGHTS_DATA];
    FMResultSet *results;
    [database open];
    results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@", TBL_RATINGS]];
    dispatch_group_t group = dispatch_group_create();
    while ([results next]) {
        Rating *rating = [[Rating alloc] init];
        rating.type = [results stringForColumn:COL_TYPE];
        if ([rating.type isEqualToString:STAR_RATING]) {
            NSDictionary *contentDict = [NSKeyedUnarchiver unarchiveObjectWithData:[results dataForColumn:COL_CONTENT]];
            if ([rating.type isEqualToString:STAR_RATING]) {
                NSArray *starRatingsPreProcessed = [self parseArrayFromJson:contentDict key:@"star_items"];
                for (NSDictionary *star in starRatingsPreProcessed) {
                    StarRatingModel *starRatingModel = [[StarRatingModel alloc] init];
                    starRatingModel.starRatingID = [self parseIntegerFromJson:star key:@"id"];
                    Image *image = [[Image alloc] init];
                    image.remoteUrl = [self parseStringFromJson:star key:@"image_url"];
                    image.deviceUrl = [NSString stringWithFormat:@"starRating_%d_%d.jpg", [results intForColumn:COL_ID], starRatingModel.starRatingID];
                    image.remoteUrl = [self getModifiedUrl:image.remoteUrl];
                    NSString *imageUpdatedTime = [results stringForColumn:COL_IMAGE_UPDATED];
                    if ([self needsUpdate:imageUpdatedTime]) {
                        dispatch_group_enter(group);
                        [image getImageFromRemoteUrlWithBlock:^(BOOL isReceived) {
                            dispatch_group_leave(group); 
                        }];
                    }
                    //insert in DB
                    NSString *insertStatement = [NSString stringWithFormat:@"INSERT OR REPLACE into %@ (%@,%@,%@,%@) values (%d,%d,'%@','%@')", TBL_STAR_RATING_IMAGES, COL_ID, COL_STAR_RATING_NUMBER, COL_DEVICE_URL, COL_REMOTE_URL, [results intForColumn:COL_ID], starRatingModel.starRatingID, image.deviceUrl, image.remoteUrl];
                    [database executeUpdate:insertStatement];
                }
            }
        }
    }
    [database close];
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        success(YES);
        NSLog(@"Rating images downoaded");
    });
}

- (BOOL) needsUpdate: (NSString *) imageUpdatedDate {
    BOOL needsUpda = NO;
    int imageUpdated = [imageUpdatedDate integerValue];
    NSDate *tr = [NSDate dateWithTimeIntervalSince1970:imageUpdated];
    NSDate *syncDate = [NSUserDefaultsManager getObjectFromUserDeafults:SyncDownloadTime];
    switch ([syncDate compare:tr]) {
        case NSOrderedAscending:
            // dateOne is earlier in time than dateTwo
            break;
        case NSOrderedSame:
            // The dates are the same
            break;
        case NSOrderedDescending:
            needsUpda = YES;
            break;
    }
    return needsUpda;
}


- (NSString *) getModifiedUrl: (NSString *) url {
    NSArray *components = [url componentsSeparatedByString:@"/"];
    NSString *imageName = [components lastObject];
    NSString *size = [NSString stringWithFormat:@"%@_", imageSizeFromServer];
    if (imageName) {
        size = [size stringByAppendingString:imageName];
    }
    NSMutableArray *componentsMutable = [components mutableCopy];
    int count = [componentsMutable count];
    NSString *finalString;
    if (count > 0) {
        [componentsMutable replaceObjectAtIndex:count-1 withObject:size];
        finalString = [componentsMutable componentsJoinedByString:@"/"];
        //NSLog(@"componenets %@", components);
    } else {
        return @"";
    }
    return finalString;
}


#pragma mark - SQL Insert Methods

//- (NSArray *) insertRowDataForDB: (NSArray *) defectsArray {
//    NSMutableArray *sqlRowArray = [[NSMutableArray alloc] init];
//    if ([defectsArray count] > 0) {
//        for (int i=0; i < [defectsArray count]; i++) {
//            Rating *rating = [defectsArray objectAtIndex:i];
//            NSString *sql =[NSString stringWithFormat:@"INSERT INTO %@", TBL_RATINGS];
//            sql = [sql stringByAppendingString:@" ("];
//            sql = [sql stringByAppendingFormat:@"%@,%@,%@,%@,%@", COL_ID, COL_CONTENT, COL_DESCRIPTION, COL_NAME, COL_TYPE];
//            sql = [sql stringByAppendingString:@")"];
//            sql = [sql stringByAppendingString:@" VALUES "];
//            sql = [sql stringByAppendingString:@"("];
//            sql = [sql stringByAppendingFormat:@"%d,'%@','%@','%@','%@'", rating.ratingID, [NSString stringWithFormat:@"%@", rating.contentPreProcessed], rating.description, rating.name, rating.type];
//            sql = [sql stringByAppendingString:@");"];
//            [sqlRowArray addObject:sql];
//        }
//    }
//    return [sqlRowArray copy];
//}

- (void) insertRowDataForDB: (NSArray *) ratingsArray {
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_INSIGHTS_DATA];
    [database open];
    for (int i=0; i < [ratingsArray count]; i++) {
        Rating *rating = [ratingsArray objectAtIndex:i];
        NSData *dataContent = [NSKeyedArchiver archivedDataWithRootObject:rating.contentPreProcessed];
        NSData *dataDefectsArray = [NSKeyedArchiver archivedDataWithRootObject:rating.defects];
        if ([rating.defects count] > 0) {
            BOOL response = [database executeUpdate:@"insert or replace into RATINGS (id, content, description, name, type, defects, order_data_field, display,is_numeric) values (?,?,?,?,?,?,?,?,?)", rating.ratingID, dataContent, rating.description, rating.name, rating.type,dataDefectsArray, rating.order_data_field, rating.displayName,[NSString stringWithFormat:@"%d",rating.is_numeric]];
            //NSLog(@"RatingApi.m - TBL_RATINGS Insert or replace response - %d", response);
        } else {
            BOOL response = [database executeUpdate:@"insert or replace into RATINGS (id, content, description, name, type, order_data_field, display,is_numeric) values (?,?,?,?,?,?,?,?)", [NSString stringWithFormat:@"%d",rating.ratingID], dataContent, rating.description, rating.name, rating.type, rating.order_data_field, rating.displayName,[NSString stringWithFormat:@"%d",rating.is_numeric]];
            //;
            //NSLog(@"RatingApi.m - TBL_RATINGS Insert or replace response - %d", response);
        }
    }
    [database close];
    //[self downloadImages];
}



@end
