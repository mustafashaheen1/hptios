//
//  DefectAPI.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/22/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "DefectAPI.h"
#import "Defect.h"
#import "DBManager.h"
#import "Image.h"
#import "PaginationCallsClass.h"

@implementation DefectAPI

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

#pragma mark - CallToServer

/// Call Defects

- (void)defectsCallWithBlock:(void (^)(BOOL isSuccess, NSArray *array, NSError *error))block {
    if (PAGINATE_SYNC_API) {
        PaginationCallsClass *paginate = [[PaginationCallsClass alloc] init];
        paginate.minimumNumberOfCalls = minimumNumberForCalls;
        paginate.limit = 200;
        paginate.pageNo = initialPageNo;
        paginate.apiCallString = Defects;
        paginate.apiCallFilePath = defectsFilePath;
        [paginate callWithBlock:^(BOOL isSuccess, NSArray *array, NSError *error) {
            if (error) {
                if (block) {
                    block(NO, nil, nil);
                }
            } else {
                self.defectsArray = [self getDefectsFromArray:array];
                if (block) {
                    block(YES, nil, nil);
                }
            }
        }];
    } else {
        NSDictionary *localStoreCallParamaters = [self paramtersFortheGETCall];
        if ([localStoreCallParamaters count] > 0) {
            [[AFAppDotNetAPIClient sharedClient] getPath:Defects parameters:localStoreCallParamaters success:^(AFHTTPRequestOperation *operation, id JSON) {
                id JSONLocal;
                BOOL successWrite= [self writeDataToFile:defectsFilePath withContents:JSON];
                if (successWrite) {
                    JSONLocal = [self readDataFromFile:defectsFilePath];
                }
                NSLog(@"DefectLocal %@", JSONLocal);
                self.defectsArray = [self getDefectsFromArray:JSONLocal];
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
    [self insertRowDataForDB:self.defectsArray];
}

-(void) saveApiResponseArray:(NSMutableArray *)array {
    self.defectsArray = [self getDefectsFromArray:array];
    [self downloadCompleteAndItsSafeToInsertDataInToDB];
}

#pragma mark - Parse Methods

- (NSArray *) getDefectsFromArray :(NSArray *) defectArrayBeforeProcessing {
    NSMutableArray *defectMutable = [[NSMutableArray alloc] init];
    if (defectArrayBeforeProcessing) {
        for (NSDictionary *containerDictionary in defectArrayBeforeProcessing) {
            Defect *defect = [self setAttributesFromMap:containerDictionary];
            [defectMutable addObject:defect];
        }
    }
    return [defectMutable copy];
}

- (Defect *)setAttributesFromMap:(NSDictionary*)dataMap {
    Defect *defect = [[Defect alloc] init];
    if (dataMap) {
        NSMutableArray *thresholdMutableArray = [[NSMutableArray alloc] init];
        defect.coverage_type = [self parseStringFromJson:dataMap key:@"coverage_type"];
        defect.description = [self parseStringFromJson:dataMap key:@"description"];
        defect.display = [self parseStringFromJson:dataMap key:@"display"];
        defect.defectID = [self parseIntegerFromJson:dataMap key:@"id"];
        defect.image_smaller = [self parseStringFromJson:dataMap key:@"image_smaller"];
        defect.image_updated = [self parseStringFromJson:dataMap key:@"image_updated"];
        defect.image_url = [self parseStringFromJson:dataMap key:@"image_url"];
        defect.name = [self parseStringFromJson:dataMap key:@"name"];
        defect.name = [self parseStringFromJson:dataMap key:@"name"];
        defect.defectGroupName = [self parseStringFromJson:dataMap key:@"defect_group_name"];
        defect.defectGroupID = [self parseIntegerFromJson:dataMap key:@"defect_group_id"];
        defect.html_description_source =[self parseStringFromJson:dataMap key:@"html_description_source"];
        defect.enable_html_description = [self parseIntegerFromJson:dataMap key:@"enable_html_description"];
        defect.order_position = [self parseIntegerFromJson:dataMap key:@"order_position"];
        NSArray *thresholdsBeforeProcessing = [self parseArrayFromJson:dataMap key:@"thresholds"];
        for (NSDictionary *thresholdDict in thresholdsBeforeProcessing) {
            Threshold *threshold = [defect setThresholdAttributesFromMap:thresholdDict];
            [thresholdMutableArray addObject:threshold];
        }
        defect.thresholdsArrayBeforeProcessing = [self parseArrayFromJson:dataMap key:@"thresholds"];
        defect.thresholdsArray = thresholdMutableArray;
    }
    return defect;
}

- (Defect *)setDefectAttributesFromMap:(NSString *)defectIDLocal {
    Defect *defect = [[Defect alloc] init];
    if (defectIDLocal) {
        defect.defectID = [defectIDLocal integerValue];
    }
    return defect;
}


#pragma mark - SQL Methods

+ (NSString *) getTableCreateStatmentForDefects {
    NSString *sql =[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@", TBL_DEFECT_FAMILY_DEFECTS];
    sql = [sql stringByAppendingString:@" ("];
    sql = [sql stringByAppendingFormat:@"%@ %@ %@,",COL_ID, SQLITE_TYPE_TEXT,SQLITE_TYPE_PRIMARY_KEY];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_NAME, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_DISPLAY_NAME, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_COVERAGE_TYPE, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_DESCRIPTION, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_IMAGE_URL_REMOTE, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_IMAGE_UPDATED, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_ORDER_POSITION, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_DEFECT_GROUP_ID, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_DEFECT_GROUP_NAME, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_THRESHOLDS, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_HTML_DESCRIPTION, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@",COL_HTML_DESCRIPTION_ENABLED, SQLITE_TYPE_INTEGER];
    
    sql = [sql stringByAppendingString:@")"];
    return sql;
}

+ (NSString *) getTableCreateStatmentForDefectsImages {
    NSString *sql =[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@", TBL_DEFECT_IMAGES];
    sql = [sql stringByAppendingString:@" ("];
    sql = [sql stringByAppendingFormat:@"%@ %@ %@,",COL_ID, SQLITE_TYPE_INTEGER,SQLITE_TYPE_PRIMARY_KEY];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_IMAGE_UPDATED, SQLITE_TYPE_INTEGER];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_REMOTE_URL, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@",COL_DEVICE_URL, SQLITE_TYPE_TEXT];
    
    sql = [sql stringByAppendingString:@")"];
    return sql;
}

+ (void) downloadImagesWithBlock:(void (^)(BOOL isReceived))success {
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_INSIGHTS_DATA];
    FMResultSet *results;
    [database open];
    //results = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@", TBL_DEFECT_FAMILY_DEFECTS]];
    results = [database executeQuery:[NSString stringWithFormat:@"SELECT %@,%@ FROM %@ WHERE %@ IS NOT NULL", COL_IMAGE_URL_REMOTE, COL_ID, TBL_DEFECT_FAMILY_DEFECTS, COL_IMAGE_URL_REMOTE]];
    dispatch_group_t group = dispatch_group_create();
    while ([results next]) {
        Image *image = [[Image alloc] init];
        image.remoteUrl = [results stringForColumn:COL_IMAGE_URL_REMOTE];
        image.deviceUrl = [NSString stringWithFormat:@"defect_%d.jpg", [results intForColumn:COL_ID]];
        image.remoteUrl = [self getModifiedUrl:image.remoteUrl];
        NSString *imageUpdatedTime = [results stringForColumn:COL_IMAGE_UPDATED];
        if ([self needsUpdate:imageUpdatedTime] && image.remoteUrl!=nil) {
            dispatch_group_enter(group);
            [image getImageFromRemoteUrlWithBlock:^(BOOL isReceived) {
                dispatch_group_leave(group);
            }];
        }
        NSString *colIdString = [NSString stringWithFormat:@"%d", [results intForColumn:COL_ID]];
        [database executeUpdate:@"insert or replace into DEFECT_IMAGES (id, image_updated, DEVICE_URL, REMOTE_URL) values (?,?,?,?)", colIdString, [results stringForColumn:COL_IMAGE_UPDATED], image.deviceUrl, image.remoteUrl];
    }
    [database close];
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        success(YES);
        NSLog(@"all images downoaded");
    });
    //success(YES);
}

+ (BOOL) needsUpdate: (NSString *) imageUpdatedDate {
    BOOL imageNeedUpdate = NO;
    int imageUpdated = [imageUpdatedDate integerValue];
    NSDate *tr = [NSDate dateWithTimeIntervalSince1970:imageUpdated];
    NSDate *syncDate = [NSUserDefaultsManager getObjectFromUserDeafults:SyncDownloadTime];
    switch ([syncDate compare:tr]) {
        case NSOrderedAscending:
            // dateOne is earlier in time than dateTwo
            //syncDate is less than image updated date
            imageNeedUpdate = YES;
            break;
        case NSOrderedSame:
            // The dates are the same
            //both are same
            break;
        case NSOrderedDescending:
            //imageUpdated date is less than syncDate
            break;
    }
    return imageNeedUpdate;
}

+ (NSString *) getModifiedUrl: (NSString *) url {
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
//            Defect *defect = [defectsArray objectAtIndex:i];
//            NSString *sql =[NSString stringWithFormat:@"INSERT INTO %@", TBL_DEFECT_FAMILY_DEFECTS];
//            sql = [sql stringByAppendingString:@" ("];
//            sql = [sql stringByAppendingFormat:@"%@,%@,%@,%@,%@,%@,%@,%@,%@", COL_ID, COL_NAME, COL_DISPLAY_NAME, COL_COVERAGE_TYPE, COL_DESCRIPTION, COL_IMAGE_URL_REMOTE, COL_IMAGE_UPDATED, COL_ORDER_POSITION, COL_THRESHOLDS];
//            sql = [sql stringByAppendingString:@")"];
//            sql = [sql stringByAppendingString:@" VALUES "];
//            sql = [sql stringByAppendingString:@"("];
//            sql = [sql stringByAppendingFormat:@"%d,'%@','%@','%@','%@','%@','%@',%d,'%@'", defect.defectID, defect.name, defect.display, defect.coverage_type, defect.description, defect.image_url, defect.image_updated, defect.order_position, defect.thresholdsArrayBeforeProcessing];
//            sql = [sql stringByAppendingString:@");"];
//            [sqlRowArray addObject:sql];
//        }
//    }
//    return [sqlRowArray copy];
//}

- (void) insertRowDataForDB: (NSArray *) defectsArray {
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_INSIGHTS_DATA];
    [database open];
    for (int i=0; i < [defectsArray count]; i++) {
        Defect *defect = [defectsArray objectAtIndex:i];
        NSData *dataThresholds = [NSKeyedArchiver archivedDataWithRootObject:defect.thresholdsArrayBeforeProcessing];
       // BOOL response = [database executeUpdate:@"insert or replace into DEFECT_FAMILY_DEFECTS (id, name, display, coverage_type, description, html_description_source, enable_html_description, image_url, image_updated, order_position, thresholds, defect_group_id, defect_group_name) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?,?)", [NSString stringWithFormat:@"%d", defect.defectID], defect.name, defect.display, defect.coverage_type, defect.description, defect.html_description_source,[NSString stringWithFormat:@"%d", defect.enable_html_description], defect.image_url, defect.image_updated, [NSString stringWithFormat:@"%d", defect.order_position], dataThresholds, [NSString stringWithFormat:@"%d", defect.defectGroupID], defect.defectGroupName];
        
        BOOL response = [database executeUpdate:@"insert or replace into DEFECT_FAMILY_DEFECTS (id, name, display, coverage_type, description, html_description_source, enable_html_description, image_url, image_updated, order_position, thresholds, defect_group_id, defect_group_name) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?,?)", [NSString stringWithFormat:@"%d", defect.defectID], defect.name, defect.display, defect.coverage_type, defect.description, defect.html_description_source,[NSString stringWithFormat:@"%d", defect.enable_html_description], defect.image_url, defect.image_updated, [NSString stringWithFormat:@"%d", defect.order_position], dataThresholds, [NSString stringWithFormat:@"%d", defect.defectGroupID], defect.defectGroupName];

        
        //NSLog(@"DefectApi.m - TBL_DEFECT_FAMILY_DEFECTS Insert or replace response - %d", response);
    }
    [database close];
    //[self downloadImages];
}




@end
