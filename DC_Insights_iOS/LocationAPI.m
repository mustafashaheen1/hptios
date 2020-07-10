//
//  LocationAPI.m
//  Insights
//
//  Created by Mustafa Shaheen on 6/30/20.
//  Copyright © 2020 Yottamark. All rights reserved.
//

#import "LocationAPI.h"
#import "Location.h"
#import "DBManager.h"
#import "Constants.h"
#import "PaginationCallsClass.h"

#define min 9999900
#define max 9999999
@implementation LocationAPI


@synthesize locationObjectsGlobal;

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
       
    }
    return self;
}

#pragma mark - CallToServer

// Call to Locations

- (void)locationCallWithBlock:(void (^)(BOOL isSuccess, NSArray *array, NSError *error))block {
    if (PAGINATE_SYNC_API) {
        PaginationCallsClass *paginate = [[PaginationCallsClass alloc] init];
        paginate.minimumNumberOfCalls = minimumNumberForCalls;
        paginate.limit = limitPerPage;
        paginate.pageNo = initialPageNo;
        paginate.apiCallString = Locations;
        paginate.apiCallFilePath = locationsFilePath;
        [paginate callWithBlock:^(BOOL isSuccess, NSArray *array, NSError *error) {
            if (error) {
                if (block) {
                    block(NO, nil, nil);
                }
            } else {
                self.locationsSQLRowArray = [self getLocationsFromArray:array];
                if (block) {
                    block(YES, nil, nil);
                }
            }
        }];
    } else {
        NSDictionary *localLocationCallParamaters = [self paramtersFortheGETCall];
        if ([localLocationCallParamaters count] > 0) {
            [[AFAppDotNetAPIClient sharedClient] getPath:Locations parameters:localLocationCallParamaters success:^(AFHTTPRequestOperation *operation, id JSON) {
                id JSONLocal;
                BOOL successWrite= [self writeDataToFile:locationsFilePath withContents:JSON];
                if (successWrite) {
                    JSONLocal = [self readDataFromFile:locationsFilePath];
                }
                NSLog(@"LocationLocal %@", JSONLocal);
                self.locationsSQLRowArray = [self getLocationsFromArray:JSONLocal];
                if (block) {
                    block(successWrite, self.locationsSQLRowArray, nil);
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                if (block) {
                    block(NO, nil, error);
                }
            }];
        }
    }
}

- (void) downloadCompleteAndItsSafeToInsertDataInToDB {
    [self insertRowDataForDB:self.locationsSQLRowArray];
}


-(void) saveApiResponseArray:(NSMutableArray *)array {
    self.locationsSQLRowArray = [self getLocationsFromArray:array];
    [self downloadCompleteAndItsSafeToInsertDataInToDB];
}

#pragma mark - Parse Methods

- (NSArray *) getLocationsFromArray :(NSArray *) locationsArrayBeforeProcessing {
    NSMutableArray *locationsMutable = [[NSMutableArray alloc] init];
    if (locationsArrayBeforeProcessing) {
        for (NSDictionary *locationDictionary in locationsArrayBeforeProcessing) {
            Location *location = [self setAttributesFromMap:locationDictionary];
            [locationsMutable addObject:location];
        }
    }
    return [locationsMutable copy];
}

- (Location *)setAttributesFromMap:(NSDictionary*)dataMap {
    Location *location = [[Location alloc] init];
    if (dataMap) {
        location.location_id = [self parseIntegerFromJson:dataMap key:@"id"];
        location.address = [self parseStringFromJson:dataMap key:@"address"];
        location.city = [self parseStringFromJson:dataMap key:@"city"];
        location.name= [self parseStringFromJson:dataMap key:@"name"];
        location.postal_code = [self parseIntegerFromJson:dataMap key:@"postal_code"];
        location.state = [self parseStringFromJson:dataMap key:@"state"];
        location.country = [self parseStringFromJson:dataMap key:@"country"];
        location.gln = [self parseStringFromJson:dataMap key:@"gln"];
        location.store_number = [self parseIntegerFromJson:dataMap key:@"store_number"];
        location.geo_point = [self parseStringFromJson:dataMap key:@"geo_point"];
        location.marketing_sales_area = [self parseStringFromJson:dataMap key:@"marketing_sales_area"];
        location.sales_volume = [self parseStringFromJson:dataMap key:@"sales_volume"];
        location.banner_id = [self parseStringFromJson:dataMap key:@"banner_id"];
        location.short_name = [self parseStringFromJson:dataMap key:@"short_name"];
        location.company_id = [self parseIntegerFromJson:dataMap key:@"company_id"];
        location.archived = [self parseBoolFromJson:dataMap key:@"archived"];
        
    }
    return location;
}

#pragma mark - SQL Methods

+ (NSString *) getTableCreateStatmentForLocations {
    NSString *sql =[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@", TBL_LOCATIONS];
    sql = [sql stringByAppendingString:@" ("];
    sql = [sql stringByAppendingFormat:@"%@ %@ %@,",COL_ID, SQLITE_TYPE_INTEGER, SQLITE_TYPE_PRIMARY_KEY];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_NAME, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_STORE_NUMBER, SQLITE_TYPE_INTEGER];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_ADDRESS, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_CITY, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_STATE, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_COUNTRY, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_GLN, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_GEO_POINT, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_MARKETING_SALES_AREA, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_SALES_VOLUME, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_BANNER_ID, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_SHORT_NAME, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_COMPANY_ID, SQLITE_TYPE_INTEGER];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_ARCHIVED, SQLITE_TYPE_INTEGER];
    sql = [sql stringByAppendingFormat:@"%@ %@",COL_POSTCODE, SQLITE_TYPE_INTEGER];
    sql = [sql stringByAppendingString:@")"];
    return sql;
}

- (void) insertRowDataForDB: (NSArray *) locationsArray {
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_INSIGHTS_DATA];
    [database open];
    for (int i=0; i < [locationsArray count]; i++) {
        Location *location = [locationsArray objectAtIndex:i];
        BOOL response = [database executeUpdate:@"insert or replace into LOCATIONS (id, name, store_number, address, postCode, city, state, country, geo_point, marketing_sales_area, sales_volume, banner_id, short_name, company_id, archived, gln) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", [NSString stringWithFormat:@"%d",location.location_id], location.name, [NSString stringWithFormat:@"%d",location.store_number], location.address, [NSString stringWithFormat:@"%d", location.postal_code], location.city, location.state, location.country, location.geo_point, location.marketing_sales_area, location.sales_volume, location.banner_id, location.short_name, [NSString stringWithFormat:@"%d",location.company_id], [NSString stringWithFormat:@"%d",location.archived], location.gln];
        if(response){
            
        }
    }
    [database close];
}

@end
