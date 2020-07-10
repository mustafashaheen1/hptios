//
//  Location.h
//  Insights
//
//  Created by Mustafa Shaheen on 6/30/20.
//  Copyright © 2020 Yottamark. All rights reserved.
//

#import "DCBaseEntity.h"



@interface Location : DCBaseEntity
@property (nonatomic, assign) NSInteger location_id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSInteger store_number;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, assign) NSInteger postal_code;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *geo_point;
@property (nonatomic, strong) NSString *marketing_sales_area;
@property (nonatomic, strong) NSString *sales_volume;
@property (nonatomic, strong) NSString *banner_id;
@property (nonatomic, strong) NSString *short_name;
@property (nonatomic, assign) NSInteger company_id;
@property (nonatomic, assign) BOOL archived;
@property (nonatomic, strong) NSString *gln;

- (void) storeCallWithBlock:(void (^)(NSArray *stores, NSError *error))block;
- (void) getLocationsFromArray :(NSArray *) storesArrayBeforeProcessing;
- (void) setStoreAttributesFromMap:(NSString*)dataMap;
+ (NSString *) getStoreNameFromStoreId: (NSString *) storeIDLocal;
@end


