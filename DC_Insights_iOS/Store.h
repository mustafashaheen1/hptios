//
//  Store.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/23/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "DCBaseEntity.h"
#import <MapKit/MapKit.h>

@interface Store : DCBaseEntity

@property (nonatomic, assign) NSInteger storeID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *chain_name;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
@property (nonatomic, strong) NSString *distance;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, assign) NSInteger postCode;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *gln;
@property (nonatomic, strong) NSString *normalizedAddress;
@property (nonatomic, strong) NSString *normalizedCity;
@property (nonatomic, strong) NSString *msa;
@property (nonatomic, strong) NSString *msa_desc;
@property (nonatomic, strong) NSString *distance_unit;
@property (nonatomic, strong) NSString *store_no;
@property (nonatomic, strong) NSString *store_weekly_volume;
@property (nonatomic, assign) double distance_full_precision;
@property (nonatomic, strong) NSArray *allPrograms;
@property (nonatomic, strong) NSArray *allProductGroups;
@property (nonatomic, strong) NSArray *allContainers;
@property (nonatomic, assign) CLLocationDistance distanceFromUserLocation;
@property (nonatomic, assign) BOOL storeEnteredByUser;
@property (nonatomic, strong) NSArray *productGroups;
@property (nonatomic, strong) NSArray *groupsOfProductsForTheStore;


- (void) storeCallWithBlock:(void (^)(NSArray *stores, NSError *error))block;
- (void) getStoresFromArray :(NSArray *) storesArrayBeforeProcessing;
- (void) setStoreAttributesFromMap:(NSString*)dataMap;
- (CLLocation *) getStoreLocationWithLatitude: (double) latitude andLongitude: (double) longitude;
- (NSArray *) getListOfAllContainersForTheStore;
- (NSArray *) getAllGroupsOfProductsForTheStore;
- (void) getAllTheProgramsForTheStore:(NSArray *) allProgramsLocal;
- (NSArray *) getProductGroups;
+ (NSString *) getStoreNameFromStoreId: (NSString *) storeIDLocal;
- (NSArray *) filterProductsBasedOnContainers: (NSArray *) products;

@end
