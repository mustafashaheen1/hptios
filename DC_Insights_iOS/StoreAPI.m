//
//  Store.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/9/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "StoreAPI.h"
#import "Store.h"
#import "DBManager.h"
#import "Constants.h"
#import "LocationManager.h"
#import "PaginationCallsClass.h"

#define min 9999900
#define max 9999999

@implementation StoreAPI

@synthesize storeObjectsGlobal;

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
       
    }
    return self;
}

#pragma mark - CallToServer

// Call to Stores

- (void)storeCallWithBlock:(void (^)(BOOL isSuccess, NSArray *array, NSError *error))block {
    if (PAGINATE_SYNC_API) {
        PaginationCallsClass *paginate = [[PaginationCallsClass alloc] init];
        paginate.minimumNumberOfCalls = minimumNumberForCalls;
        paginate.limit = limitPerPage;
        paginate.pageNo = initialPageNo;
        paginate.apiCallString = Stores;
        paginate.apiCallFilePath = storesFilePath;
        [paginate callWithBlock:^(BOOL isSuccess, NSArray *array, NSError *error) {
            if (error) {
                if (block) {
                    block(NO, nil, nil);
                }
            } else {
                self.storesSQLRowArray = [self getStoresFromArray:array];
                if (block) {
                    block(YES, nil, nil);
                }
            }
        }];
    } else {
        NSDictionary *localStoreCallParamaters = [self paramtersFortheGETCall];
        if ([localStoreCallParamaters count] > 0) {
            [[AFAppDotNetAPIClient sharedClient] getPath:Stores parameters:localStoreCallParamaters success:^(AFHTTPRequestOperation *operation, id JSON) {
                id JSONLocal;
                BOOL successWrite= [self writeDataToFile:storesFilePath withContents:JSON];
                if (successWrite) {
                    JSONLocal = [self readDataFromFile:storesFilePath];
                }
                NSLog(@"StoreLocal %@", JSONLocal);
                self.storesSQLRowArray = [self getStoresFromArray:JSONLocal];
                if (block) {
                    block(successWrite, self.storesSQLRowArray, nil);
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
    [self insertRowDataForDB:self.storesSQLRowArray];
}


-(void) saveApiResponseArray:(NSMutableArray *)array {
    self.storesSQLRowArray = [self getStoresFromArray:array];
    [self downloadCompleteAndItsSafeToInsertDataInToDB];
}
// Call to Store Locations

- (void)storeLocationCallWithBlock:(void (^)(BOOL isSuccess, NSArray *array, NSError *error))block {
    NSDictionary *localStoreCallParamaters = [self paramtersFortheGETCallWithLatLon];
    if ([localStoreCallParamaters count] > 0) {
        [[AFAppDotNetAPIClient sharedClient] getPath:[NSString stringWithFormat:@"%@/%d", StoresLocations, countOfStoresForFetching] parameters:localStoreCallParamaters success:^(AFHTTPRequestOperation *operation, id JSON) {
            id JSONLocal;
            BOOL successWrite= [self writeDataToFile:storesLocationFilePath withContents:JSON]; 
            if (successWrite) {
                JSONLocal = [self readDataFromFile:storesLocationFilePath];
            }
            NSArray *stores = [JSONLocal objectForKey:@"stores"];
            NSArray *storesArray = [self getStoresFromArray:stores];
            if (block) {
                block(successWrite, storesArray, nil);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (block) {
                block(NO, nil, error);
            }
        }];
    }
}

#pragma mark - Parse Methods

- (NSArray *) getStoresFromArray :(NSArray *) storesArrayBeforeProcessing {
    NSMutableArray *storesMutable = [[NSMutableArray alloc] init];
    if (storesArrayBeforeProcessing) {
        for (NSDictionary *storeDictionary in storesArrayBeforeProcessing) {
            Store *store = [self setAttributesFromMap:storeDictionary];
            [storesMutable addObject:store];
        }
    }
    return [storesMutable copy];
}

- (Store *)setAttributesFromMap:(NSDictionary*)dataMap {
    Store *store = [[Store alloc] init];
    CLLocation *currentLocation = [[LocationManager sharedLocationManager] currentLocation];
    if (dataMap) {
        store.address = [self parseStringFromJson:dataMap key:@"address"];
        store.chain_name = [self parseStringFromJson:dataMap key:@"chain_name"];
        store.city = [self parseStringFromJson:dataMap key:@"city"];
        store.distance = [self parseStringFromJson:dataMap key:@"distance"];
        store.distance_full_precision = [self parseDoubleFromJson:dataMap key:@"distance_full_precision"];
        store.distance_unit = [self parseStringFromJson:dataMap key:@"distance_unit"];
        store.storeID = [self parseIntegerFromJson:dataMap key:@"id"];
        store.latitude = [self parseDoubleFromJson:dataMap key:@"lat"];
        store.longitude = [self parseDoubleFromJson:dataMap key:@"lon"];
        store.msa = [self parseStringFromJson:dataMap key:@"msa"];
        store.msa_desc= [self parseStringFromJson:dataMap key:@"msa_desc"];
        store.name= [self parseStringFromJson:dataMap key:@"name"];
        store.normalizedAddress= [self parseStringFromJson:dataMap key:@"normalizedAddress"];
        store.normalizedCity= [self parseStringFromJson:dataMap key:@"normalizedCity"];
        store.postCode= [self parseIntegerFromJson:dataMap key:@"postCode"];
        store.state = [self parseStringFromJson:dataMap key:@"state"];
        store.country = [self parseStringFromJson:dataMap key:@"country"];
        store.gln = [self parseStringFromJson:dataMap key:@"gln"];
        store.store_no = [self parseStringFromJson:dataMap key:@"store_no"];
        store.store_weekly_volume = [self parseStringFromJson:dataMap key:@"store_weekly_volume"];
        CLLocation *storeLocation = [[CLLocation alloc] initWithLatitude:store.latitude longitude:store.longitude];
        CLLocationDistance distance = [storeLocation distanceFromLocation:currentLocation];
        store.distanceFromUserLocation = distance/1609.344;
    }
    return store;
}

#pragma mark - SQL Methods

+ (NSString *) getTableCreateStatmentForStores {
    NSString *sql =[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@", TBL_STORES];
    sql = [sql stringByAppendingString:@" ("];
    sql = [sql stringByAppendingFormat:@"%@ %@ %@,",COL_ID, SQLITE_TYPE_INTEGER, SQLITE_TYPE_PRIMARY_KEY];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_NAME, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_ADDRESS, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_CHAIN_NAME, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_LAT, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_LON, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_CITY, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_STATE, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_COUNTRY, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_GLN, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@",COL_POSTCODE, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingString:@")"];
    return sql;
}

- (void) insertRowDataForDB: (NSArray *) storesArray {
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_INSIGHTS_DATA];
    [database open];
    for (int i=0; i < [storesArray count]; i++) {
        Store *store = [storesArray objectAtIndex:i];
        BOOL response = [database executeUpdate:@"insert or replace into STORES (id, name, address, chain_name, lat, lon, city, state, postCode, country, gln) values (?,?,?,?,?,?,?,?,?,?,?)", [NSString stringWithFormat:@"%d", store.storeID], store.name, store.address, store.chain_name, [NSString stringWithFormat:@"%f", store.latitude], [NSString stringWithFormat:@"%f", store.longitude], store.city, store.state, [NSString stringWithFormat:@"%ld", (long)store.postCode], store.country, store.gln];
        //NSLog(@"StoreApi.m - TBL_STORE Insert or replace response - %d", response);
    }
    [database close];
}

- (void) insertUserEnteredStoreDataForDB: (NSArray *) storesArray {
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_OFFLINE_DATA];
    [database open];
    for (int i=0; i < [storesArray count]; i++) {
        Store *store = [storesArray objectAtIndex:i];
        NSString *storeIDLocal = [NSString stringWithFormat:@"%d", store.storeID];
        if (store.storeID < 1) {
            storeIDLocal = [NSString stringWithFormat:@"%d",  (NSInteger)(min + arc4random_uniform(max - min + 1))];
        }
        [database executeUpdate:@"insert into USER_ENTERED_STORES (id, name, address, postCode, lat, lon) values (?,?,?,?,?,?)", storeIDLocal, store.name, store.address, [NSString stringWithFormat:@"%ld", (long)store.postCode], [NSString stringWithFormat:@"%f", store.latitude], [NSString stringWithFormat:@"%f", store.longitude]];
    }
    [database close];
}

@end
