//
//  AppFlow.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 4/3/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "AppFlow.h"
#import "User.h"
#import "Store.h"
#import "Container.h"
#import "Inspection.h"
#import "Rating.h"
#import "LocationManager.h"

@implementation AppFlow

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void) testAppFlow {
    /*
    // Store screen
    UserLocation *userLocation = [[UserLocation alloc] init];
    CLLocation *location = [[LocationManager sharedLocationManager] currentLocation];
    userLocation.latitude = location.coordinate.latitude;// 37.540008;
    userLocation.longitude = location.coordinate.longitude; //-122.248894;
    [[User sharedUser] setUserLocation:userLocation];
    
    NSArray *storesArray = [[User sharedUser] getListOfStoresSortedByDistance];
    for (Store *store in storesArray) {
        NSLog(@"Store Name is %@", store.name);
    }
    if ([storesArray count] > 0) {
        [[User sharedUser] setCurrentStore:[storesArray objectAtIndex:0]];
    }
    
    // Container screen
    NSArray *containersArray = [[[User sharedUser] currentStore] getListOfAllContainersForTheStore];
    for (Container *container in containersArray) {
        NSLog(@"Container Name is %@", container.name);
    }
    if ([containersArray count] > 0) {
        [[Inspection sharedInspection] setSelectedContainer:[containersArray objectAtIndex:0]];
    }
    
    Container *container = [[Inspection sharedInspection] selectedContainer];
    NSArray *ratingsArray = [container getAllRatings];
    for (Rating *rating in ratingsArray) {
        NSLog(@"Rating name is %@", rating.name);
    }
    
    Rating *containerRating;
    if ([ratingsArray count] > 0) {
        containerRating = [ratingsArray objectAtIndex:0];
    }
    NSArray *defectsArray = [containerRating getAllDefects];
    for (Defect *defect in defectsArray) {
        NSLog(@"Defect name is %@", defect.name);
        NSArray *thresholdsArray = defect.thresholdsArray;
        for (Threshold *threshold in thresholdsArray) {
            NSLog(@"Threshold name is %@", threshold.name);
        }
    }
    
    Store *store = [[User sharedUser] currentStore];
    NSArray *groupsArray = [store getAllGroupsOfProductsForTheStore];
    for (ProgramGroup *programGroup in groupsArray) {
        NSLog(@"ProgramGroup name is %@", programGroup.name);
        NSArray *productsArray = [programGroup getAllProducts];
        for (Product *product in productsArray) {
            NSLog(@"Product name is %@", product.product_name);
            NSArray *productRatingsArray = [product getAllRatings];
            for (Rating *rating in productRatingsArray) {
                NSLog(@"Product Ratings name is %@", rating.name);
                NSArray *defectsArrayForProductRatings = [rating getAllDefects];
                for (Defect *defect in defectsArrayForProductRatings) {
                    NSLog(@"Defect Ratings name is %@", defect.name);
                    NSArray *thresholdsArray = defect.thresholdsArray;
                    for (Threshold *threshold in thresholdsArray) {
                        NSLog(@"Threshold name is %@", threshold.name);
                    }
                }
            }
        }
    }*/
}

@end
