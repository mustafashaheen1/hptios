//
//  MasterProductRatingManager.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/17/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "MasterProductRatingManager.h"
#import "ProductRatingViewController.h"
#import "ContainerViewController.h"
#import "User.h"
#import "Container.h"
#import "Inspection.h"

@implementation MasterProductRatingManager

@synthesize navigationController;
@synthesize containers;


/*------------------------------------------------------------------------------
 METHOD: init:
 
 PURPOSE:
 Initialize the object values.
 -----------------------------------------------------------------------------*/
- (id)init
{
	if (self = [super init]) {
        [self loadTheContainers];
        [self loadOrderData];
	}
	return self;
}

- (void) loadOrderData {
    self.orderDataArray = [[Inspection sharedInspection] getOrderData];
    //NSLog(@"polign %@", self.orderDataArray);
}

- (void) loadTheContainers {
    // Container screen
    self.containers = [[[User sharedUser] currentStore] getListOfAllContainersForTheStore];
}

- (void) navigateNow {
    [self createViewController];
}

- (void) createViewController {
    ContainerViewController *containerViewController;
    containerViewController = [[ContainerViewController alloc] initWithNibName:kContainerViewNIBName bundle:nil];
    containerViewController.containers = self.containers;
    containerViewController.orderDataArray = self.orderDataArray;
    [self.navigationController pushViewController:containerViewController animated:YES];
}


@end
