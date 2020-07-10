//
//  Store.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/9/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

//"id":39708,
//"name":"7-Eleven Food Stores - Mountain View- No 15429",
//"address":"276 N Whisman Rd",
//"chain_name":"7-Eleven",
//"lat":37.396684,
//"lon":-122.060082,
//"distance":"0 Miles",
//"city":"Mountain View",
//"state":"CA",
//"postCode":"94043",
//"normalizedAddress":"276 WHISMAN RD",
//"normalizedCity":"MOUNTAIN VIEW"

#import <Foundation/Foundation.h>
#import "DCBaseEntity.h"

@interface StoreAPI : DCBaseEntity

@property (nonatomic, strong) NSDictionary *stores;
@property (nonatomic, strong) NSArray *storeObjectsGlobal;
@property (nonatomic, strong) NSArray *storesSQLRowArray;

- (void)storeCallWithBlock:(void (^)(BOOL isSuccess, NSArray *array, NSError *error))block;
- (void)storeLocationCallWithBlock:(void (^)(BOOL isSuccess, NSArray *array, NSError *error))block;
- (void) downloadCompleteAndItsSafeToInsertDataInToDB;
- (void) insertUserEnteredStoreDataForDB: (NSArray *) storesArray;

/*------------------------------------------------------------------------------
 Class Methods
 -----------------------------------------------------------------------------*/

+ (NSString *) getTableCreateStatmentForStores;

@end
