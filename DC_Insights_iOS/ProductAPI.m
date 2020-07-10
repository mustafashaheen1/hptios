//
//  ProductAPI.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/27/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "ProductAPI.h"
#import "DBManager.h"
#import "Product.h"
#import "QualityManual.h"
#import "PaginationCallsClass.h"

@implementation ProductAPI

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

/// Call Programs Products

- (void)programsProductsCallWithBlock:(void (^)(BOOL isSuccess, NSArray *array, NSError *error))block {
    if (PAGINATE_SYNC_API) {
        PaginationCallsClass *paginate = [[PaginationCallsClass alloc] init];
        paginate.minimumNumberOfCalls = minimumNumberForCalls;
        paginate.limit = limitPerPage;
        paginate.pageNo = initialPageNo;
        paginate.apiCallString = ProgramsProducts;
        paginate.apiCallFilePath = ProgramsProductsFilePath;
        [paginate callWithBlock:^(BOOL isSuccess, NSArray *array, NSError *error) {
            if (error) {
                if (block) {
                    block(NO, nil, nil);
                }
            } else {
                self.sqlRowArray = [self getProgramsFromArray:array];
                if (block) {
                    block(YES, nil, nil);
                }
            }
        }];
    } else {
        NSDictionary *localStoreCallParamaters = [self paramtersFortheGETCall];
        if ([localStoreCallParamaters count] > 0) {
            [[AFAppDotNetAPIClient sharedClient] getPath:ProgramsProducts parameters:localStoreCallParamaters success:^(AFHTTPRequestOperation *operation, id JSON) {
                id JSONLocal;
                BOOL successWrite= [self writeDataToFile:ProgramsFilePath withContents:JSON];
                if (successWrite) {
                    JSONLocal = [self readDataFromFile:ProgramsFilePath];
                }
                NSLog(@"ProductLocal %@", JSONLocal);
                self.sqlRowArray = [self getProgramsFromArray:JSONLocal];
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
    [self insertRowDataForDB:self.sqlRowArray];
}


-(void) saveApiResponseArray:(NSMutableArray *)array {
    self.sqlRowArray = [self getProgramsFromArray:array];
    [self downloadCompleteAndItsSafeToInsertDataInToDB];
}

#pragma mark - Parse Methods

- (NSArray *) getProgramsFromArray :(NSArray *) programArrayBeforeProcessing {
    NSMutableArray *programMutable = [[NSMutableArray alloc] init];
    if (programArrayBeforeProcessing) {
        for (NSDictionary *programDictionary in programArrayBeforeProcessing) {
            Product *product = [self setAttributesFromMap:programDictionary];
            [programMutable addObject:product];
        }
    }
    return [programMutable copy];
}

- (Product *)setAttributesFromMap:(NSDictionary*)dataMap {
    Product *product = [[Product alloc] init];
    QualityManual *qualityManual = [[QualityManual alloc] init];
    
    if (dataMap) {
        product.commodity = [self parseStringFromJson:dataMap key:@"commodity"];
        product.group_id = [self parseIntegerFromJson:dataMap key:@"group_id"];
        product.insights_product = [self parseIntegerFromJson:dataMap key:@"insights_product"];
        product.plus = [self parseArrayFromJson:dataMap key:@"plu"];
        product.product_id = [self parseIntegerFromJson:dataMap key:@"product_id"];
        product.product_name = [self parseStringFromJson:dataMap key:@"product_name"];
        product.program_id = [self parseIntegerFromJson:dataMap key:@"program_id"];
        product.require_hm_code = [self parseIntegerFromJson:dataMap key:@"require_hm_code"];
        product.upcs = [self parseArrayFromJson:dataMap key:@"upc"];
        product.skus = [self parseArrayFromJson:dataMap key:@"skus"];
        product.variety = [self parseStringFromJson:dataMap key:@"variety"];
        product.qualityManualPreProcessed = [self parseDictFromJson:dataMap key:@"quality_manual"];
        product.daysRemaining = [self parseIntegerFromJson:dataMap key:@"days_remaining"];
        product.daysRemainingMax = [self parseIntegerFromJson:dataMap key:@"days_remaining_max"];
        
        //NSArray *starRatingsPreProcessed = [self parseArrayFromJson:[self parseDictFromJson:dataMap key:@"content"] key:@"star_items"];
        product.rating_defects = [self parseArrayFromJson:dataMap key:@"rating_defects"];

        qualityManual.updated_at = [self parseDateFromJson:[self parseDictFromJson:dataMap key:@"quality_manual"] key:@"updated_at"];
        qualityManual.updated_atPreProcessed = [self parseStringFromJson:[self parseDictFromJson:dataMap key:@"quality_manual"] key:@"updated_at"];
        qualityManual.pdf = [self parseStringFromJson:[self parseDictFromJson:dataMap key:@"quality_manual"] key:@"pdf"];
        
        product.qualityManual = qualityManual;

    }
    return product;
}

#pragma mark - SQL Methods

+ (NSString *) getTableCreateStatmentForProgramsProducts {
    NSString *sql =[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@", TBL_PRODUCTS];
    sql = [sql stringByAppendingString:@" ("];
    sql = [sql stringByAppendingFormat:@"%@ %@ %@,",COL_ID, SQLITE_TYPE_TEXT,SQLITE_TYPE_PRIMARY_KEY];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_PROGRAM_ID, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_PRODUCT_NAME, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_DAYS_REMAINING, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_DAYS_REMAINING_MAX, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_COMMODITY, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_VARIETY, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_UPC, SQLITE_TYPE_BLOB];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_PLU, SQLITE_TYPE_BLOB];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_SKUS, SQLITE_TYPE_BLOB];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_INSIGHTS_PRODUCT, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_GROUP_ID, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_REQUIRE_HM_CODE, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_QUALITY_MANUAL_URL, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_QUALITY_MANUAL_CONTENT, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@",COL_RATING_DEFECTS, SQLITE_TYPE_BLOB];
    sql = [sql stringByAppendingString:@")"];
    return sql;
}

#pragma mark - SQL Methods

+ (NSString *) getTableCreateStatmentForProductQualityManual {
    NSString *sql =[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@", TBL_PRODUCT_QUALITY_MANUAL];
    sql = [sql stringByAppendingString:@" ("];
    sql = [sql stringByAppendingFormat:@"%@ %@ %@,",COL_ID, SQLITE_TYPE_INTEGER,SQLITE_TYPE_PRIMARY_KEY];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_QUALITY_MANUAL_UPDATED, SQLITE_TYPE_INTEGER];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_REMOTE_URL, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@",COL_DEVICE_URL, SQLITE_TYPE_TEXT];
    
    sql = [sql stringByAppendingString:@")"];
    return sql;
}

- (void) downloadQualityManuals {
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_INSIGHTS_DATA];
    FMResultSet *results;
    [database open];
    results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@", TBL_PRODUCTS]];
    while ([results next]) {
        QualityManual *qualityManual = [[QualityManual alloc] init];
        qualityManual.path = [results stringForColumn:COL_QUALITY_MANUAL_URL];
        if (qualityManual.path) {
            qualityManual.deviceUrl = [NSString stringWithFormat:@"quality_manual_%d.html", [results intForColumn:COL_ID]];
            [qualityManual getHTMLContentFromRemoteUrlAndSaveToTheLocalDirectory];
            NSString *colIdString = [NSString stringWithFormat:@"%d", [results intForColumn:COL_ID]];
            //NSString *insertStatement = [NSString stringWithFormat:@"INSERT into %@ (%@,%@,%@,%@) values (%d,'%@','%@','%@')", TBL_PRODUCT_QUALITY_MANUAL, COL_ID, COL_QUALITY_MANUAL_UPDATED, COL_DEVICE_URL, COL_REMOTE_URL, [results intForColumn:COL_ID], [results stringForColumn:COL_QUALITY_MANUAL_CONTENT], qualityManual.deviceUrl, qualityManual.remoteUrl];
            [database executeUpdate:@"insert into QUALITY_MANUAL (id, quality_manual_updated, DEVICE_URL, REMOTE_URL) values (?,?,?,?)", colIdString, [results stringForColumn:COL_QUALITY_MANUAL_CONTENT], qualityManual.deviceUrl, qualityManual.remoteUrl];
        }
    }
    [database close];
}

#pragma mark - SQL Insert Methods

//- (NSArray *) insertRowDataForDB: (NSArray *) programArray {
//    NSMutableArray *sqlRowArray = [[NSMutableArray alloc] init];
//    if ([programArray count] > 0) {
//        for (int i=0; i < [programArray count]; i++) {
//            Product *product = [programArray objectAtIndex:i];
//            NSString *sql =[NSString stringWithFormat:@"INSERT INTO %@", TBL_PRODUCTS];
//            sql = [sql stringByAppendingString:@" ("];
//            sql = [sql stringByAppendingFormat:@"%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@", COL_ID, COL_PROGRAM_ID, COL_PRODUCT_NAME, COL_COMMODITY, COL_VARIETY, COL_UPC, COL_PLU, COL_INSIGHTS_PRODUCT, COL_GROUP_ID, COL_REQUIRE_HM_CODE, COL_QUALITY_MANUAL_URL, COL_QUALITY_MANUAL_CONTENT];
//            sql = [sql stringByAppendingString:@")"];
//            sql = [sql stringByAppendingString:@" VALUES "];
//            sql = [sql stringByAppendingString:@"("];
//            sql = [sql stringByAppendingFormat:@"%d,%d,'%@','%@','%@','%@','%@',%d,%d,%d,'%@','%@'", product.product_id, product.program_id, product.product_name, product.commodity, product.variety, product.upcs, product.plus, product.insights_product, product.group_id, product.require_hm_code, product.qualityManual.url, product.qualityManual.updated_at];
//            sql = [sql stringByAppendingString:@");"];
//            [sqlRowArray addObject:sql];
//        }
//    }
//    return [sqlRowArray copy];
//}

- (void) insertRowDataForDB: (NSArray *) programArray {
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_INSIGHTS_DATA];
    [database open];
    for (int i=0; i < [programArray count]; i++) {
        Product *product = [programArray objectAtIndex:i];
        NSData *dataUPC;
        NSData *dataPLU;
        NSData *dataSKUS;
        NSData *ratingDefects;
        if ([product.upcs count] > 0) {
            dataUPC = [NSKeyedArchiver archivedDataWithRootObject:product.upcs];
        }
        if ([product.plus count] > 0) {
            dataPLU = [NSKeyedArchiver archivedDataWithRootObject:product.plus];
        }
        if ([product.skus count] > 0) {
            dataSKUS = [NSKeyedArchiver archivedDataWithRootObject:product.skus];
        }
        
        if([product.rating_defects count] > 0){
            ratingDefects = [NSKeyedArchiver archivedDataWithRootObject:product.rating_defects];
        }
        
        BOOL response = [database executeUpdate:@"insert or replace into PRODUCTS (id, program_id, product_name, commodity, variety, upc, plu, insights_product, group_id, require_hm_code, quality_manual, quality_manual_content, skus, rating_defects,DAYS_REMAINING,DAYS_REMAINING_MAX) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?,?,?)", [NSString stringWithFormat:@"%d", product.product_id], [NSString stringWithFormat:@"%d", product.program_id], product.product_name, product.commodity, product.variety, dataUPC, dataPLU, [NSString stringWithFormat:@"%d", product.insights_product], [NSString stringWithFormat:@"%d", product.group_id], [NSString stringWithFormat:@"%d", product.require_hm_code], product.qualityManual.pdf, product.qualityManual.updated_atPreProcessed, dataSKUS, ratingDefects,[NSString stringWithFormat:@"%d", product.daysRemaining],[NSString stringWithFormat:@"%d", product.daysRemainingMax]];

       /*
        NSString *statement = [NSString stringWithFormat:@"insert or replace into PRODUCTS (id, program_id, product_name, commodity, variety, upc, plu, insights_product, group_id, require_hm_code, quality_manual, quality_manual_content, skus, rating_defects) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?)",
                               [NSString stringWithFormat:@"%d", product.product_id],
                               [NSString stringWithFormat:@"%d", product.program_id],
                               product.product_name,
                               product.commodity,
                               product.variety,
                               dataUPC,
                               dataPLU,
                               [NSString stringWithFormat:@"%d", product.insights_product],
                               [NSString stringWithFormat:@"%d", product.group_id],
                               [NSString stringWithFormat:@"%d", product.require_hm_code],
                               product.qualityManual.pdf,
                               product.qualityManual.updated_atPreProcessed,
                               dataSKUS,
                               ratingDefects];
        BOOL response = [database executeUpdate:statement];*/
         //NSLog(@"ProductApi.m - TBL_PRODUCTS Insert or replace response - %d", response);
    }
    [database close];
    //[self downloadQualityManuals]; //remove download manuals logic
}



@end
