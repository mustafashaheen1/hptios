//
//  Store.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/23/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "Store.h"
#import "Program.h"
#import "StoreAPI.h"
#import "Container.h"
#import "Inspection.h"

@implementation Store

@synthesize storeID;
@synthesize name;
@synthesize address;
@synthesize chain_name;
@synthesize latitude;
@synthesize longitude;
@synthesize distance;
@synthesize city;
@synthesize state;
@synthesize country;
@synthesize gln;
@synthesize postCode;
@synthesize normalizedAddress;
@synthesize normalizedCity;
@synthesize distance_full_precision;
@synthesize distance_unit;
@synthesize allPrograms;
@synthesize msa;
@synthesize msa_desc;
@synthesize store_no;
@synthesize store_weekly_volume;
@synthesize allProductGroups;
@synthesize allContainers;
@synthesize distanceFromUserLocation;
@synthesize storeEnteredByUser;

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        self.storeID = 0;
        self.name = @"";
        self.address = @"";
        self.chain_name = @"";
        self.latitude = 0;
        self.longitude = 0;
        self.distance = @"";
        self.city = @"";
        self.state = @"";
        self.postCode = 0;
        self.country = @"";
        self.gln = @"";
        self.normalizedAddress = @"";
        self.normalizedCity = @"";
        self.distance_full_precision = 0;
        self.distance_unit = @"";
        self.storeEnteredByUser = NO; // set true when reading from TBL_USER_ENTERED_STORES
    }
    return self;
}

/*------------------------------------------------------------------------------
 Populate Programs for the Store
 -----------------------------------------------------------------------------*/

- (void) getAllTheProgramsForTheStore:(NSArray *) allProgramsLocal {
    // if storeEnteredByUser - then return all programs directly
    if(self.storeEnteredByUser) {
        self.allPrograms = [allProgramsLocal copy];
        return;
    }
    
    NSMutableArray *allProgramsMutable = [[NSMutableArray alloc] init];
    if ([allProgramsLocal count] > 0) {
        for (Program *program in allProgramsLocal) {
            NSArray *listStoreIds = program.storeIds;
            for (int i=0; i < [listStoreIds count]; i++) {
                NSInteger storeIdLocal = [[listStoreIds objectAtIndex:i] integerValue];
                if (storeIdLocal == self.storeID) {
                    [allProgramsMutable addObject:program];
                }
            }
        }
        self.allPrograms = [allProgramsMutable copy];
    }
}

/*------------------------------------------------------------------------------
 Populate Groups Of Products for the Store
 -----------------------------------------------------------------------------*/

- (NSArray *) getAllGroupsOfProductsForTheStore {
    if ([self.groupsOfProductsForTheStore count] > 0) {
        return self.groupsOfProductsForTheStore;
    }
    NSMutableArray *allProductsGroupsMutable = [[NSMutableArray alloc] init];
    NSMutableSet *set = [NSMutableSet set];
    for (Program *program in self.allPrograms) {
        [set addObject:program];
    }
    self.allPrograms = [set allObjects];
    if ([self.allPrograms count] > 0) {
        for (Program *program in self.allPrograms) {
            [allProductsGroupsMutable addObjectsFromArray:[program getAllProductGroups]];
        }
        self.groupsOfProductsForTheStore = [self sortListOfGroupsProductsForTheStore:allProductsGroupsMutable];
    }
    return self.groupsOfProductsForTheStore;
}

- (NSArray *) sortListOfProductsForTheStore: (NSArray *) groupsArray {
    NSArray *sortedArray = [[NSArray alloc] init];
    if ([groupsArray count] > 0) {
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
        NSArray *sortDescriptors = @[sort];
        sortedArray = [groupsArray sortedArrayUsingDescriptors:sortDescriptors];
    }
    return groupsArray;
}

- (NSArray *) sortListOfGroupsProductsForTheStore: (NSArray *) groupsArray {
    NSArray *sortedArray = [[NSArray alloc] init];
    if ([groupsArray count] > 0) {
        //NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"programGroupID" ascending:YES];
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
        NSArray *sortDescriptors = @[sort];
        sortedArray = [groupsArray sortedArrayUsingDescriptors:sortDescriptors];
    }
    return sortedArray;
}

/*------------------------------------------------------------------------------
 Populate List Of all containers for all programs running in the Store
 -----------------------------------------------------------------------------*/

- (NSArray *) getListOfAllContainersForTheStore {
    NSMutableSet *allContainersMutable = [[NSMutableSet alloc] init];
    NSArray *allValidContainers;
    if ([self.allPrograms count] > 0) {
        for (Program *program in self.allPrograms) {
            [allContainersMutable addObjectsFromArray:[program getAllContainersFromDB]];
        }
        allValidContainers = [self sortListOfContainersForTheStore:allContainersMutable];
        return allValidContainers;
    }
    return [allContainersMutable copy];
}

- (NSArray *) sortListOfContainersForTheStore: (NSSet *) containersArray {
    NSArray *sortedArray = [[NSArray alloc] init];
    if ([containersArray count] > 0) {
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
        NSArray *sortDescriptors = @[sort];
        sortedArray = [containersArray sortedArrayUsingDescriptors:sortDescriptors];
    }
    return sortedArray;
}

/*------------------------------------------------------------------------------
 Check range of Store
 -----------------------------------------------------------------------------*/

- (BOOL) isStoreWithinrange: (CLLocation *) storeLocation {
    BOOL inRange = NO;
    CLLocation *currentLocation;
    if (storeLocation && currentLocation) {
        CLLocationDistance distanceLocal = [currentLocation distanceFromLocation:storeLocation];
        float miles = distanceLocal/1609.344;
        if (miles <= 5) {
            inRange = YES;
        }
    }
    return inRange;
}

/*------------------------------------------------------------------------------
 Get Store's CLLocation
 -----------------------------------------------------------------------------*/

- (CLLocation *) getStoreLocationWithLatitude: (double) latitude andLongitude: (double) longitude {
    CLLocation *location = [[CLLocation alloc] initWithLatitude:-56.6462520 longitude:-36.6462520];
    return location;
}

#pragma mark - CallToServer

/*------------------------------------------------------------------------------
 Get Stores
 -----------------------------------------------------------------------------*/

- (void)storeCallWithBlock:(void (^)(NSArray *stores, NSError *error))block {
    StoreAPI *storeAPI = [[StoreAPI alloc] init];
    [storeAPI storeCallWithBlock:^(BOOL isSuccess, NSArray *storesLocal, NSError *error){
        if (error) {
            DebugLog(@"\n Error: %@  \n", [error localizedDescription]);
        } else {
            [self getStoresFromArray:storesLocal];
        }
    }];
}

#pragma mark - JSON Methods

- (void)setStoreAttributesFromMap:(NSString*)dataMap {
    if (dataMap) {
        self.storeID = [dataMap integerValue];
    }
}

/*!
 *  Get Product Groups and cache it
 *
 *  @return Product Groups
 */

- (NSArray *) getProductGroups {
    NSArray *groupsArray = [self getAllGroupsOfProductsForTheStore];
    NSMutableArray *productGroupsLocal = [[NSMutableArray alloc] init];
    for (ProgramGroup *programGroup in groupsArray) {
        NSArray *productsArray = [programGroup getAllProducts];
        if (![programGroup.name isEqualToString:@""]) {
            programGroup.products = productsArray;
            [productGroupsLocal addObject:programGroup];
        } else {
            [productGroupsLocal addObjectsFromArray:productsArray];
        }
    }
    NSArray *productGroupsSorted = [self sortListOfProductsForTheStore:productGroupsLocal];
    self.productGroups = productGroupsSorted;
    return self.productGroups;
}

- (NSArray *) filterProductsBasedOnContainers: (NSArray *) productsOrProgramGroups {
    NSArray *containers = [[[User sharedUser] currentStore] getListOfAllContainersForTheStore];
    if (FILTER_PRODUCTS_CONTAINERS && [containers count] > 0) {
        NSMutableArray *newProductGroupsArray = [[NSMutableArray alloc] init];
        NSString *containerID = [Inspection sharedInspection].containerId;
        for (int i=0; i < [productsOrProgramGroups count]; i++) {
            if ([[productsOrProgramGroups objectAtIndex:i] isKindOfClass:[ProgramGroup class]]) {
                ProgramGroup *prg = [productsOrProgramGroups objectAtIndex:i];
                NSArray *products = prg.products;
                NSMutableArray *newProductsArray = [NSMutableArray array];
                for (Product *product in products) {
                    BOOL present = NO;
                    for (int i=0; i < [product.containers count]; i++) {
                        NSString *string = [NSString stringWithFormat:@"%@", [product.containers objectAtIndex:i]];
                        if ([string isEqualToString:containerID]) {
                            present = YES;
                            break;
                        }
                    }
                    if (present) {
                        [newProductsArray addObject:product];
                    }
                }
                prg.products = newProductsArray;
                if ([prg.products count] > 0) {
                    [newProductGroupsArray addObject:prg];
                }
            } else {
                Product *product = [productsOrProgramGroups objectAtIndex:i];
                BOOL present = NO;
                for (int i=0; i < [product.containers count]; i++) {
                    NSString *string = [NSString stringWithFormat:@"%@", [product.containers objectAtIndex:i]];
                    if ([string isEqualToString:containerID]) {
                        present = YES;
                        break;
                    }
                }
                if (present) {
                    [newProductGroupsArray addObject:product];
                }
            }
        }
        return [newProductGroupsArray copy];
    } else {
        return productsOrProgramGroups;
    }
}

+ (NSString *) getStoreNameFromStoreId: (NSString *) storeIDLocal {
    FMDatabase *databaseGroupRatings = [[DBManager sharedDBManager] openDatabase:DB_INSIGHTS_DATA];
    FMResultSet *results;
    [databaseGroupRatings open];
    results = [databaseGroupRatings executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE id=%@", TBL_STORES, storeIDLocal]];
    NSString *nameLocal = @"";
    while ([results next]) {
        nameLocal = [results stringForColumn:@"name"];
    }
    [databaseGroupRatings close];
    return nameLocal;
}


@end
