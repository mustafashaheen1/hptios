//
//  InspectionTableManager.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/18/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "InspectionTableManager.h"
#import "InspectionStatusViewController.h"

@implementation InspectionTableManager

@synthesize navigationController;
@synthesize productsInspectionArray;
@synthesize inspectionTableView;

/*------------------------------------------------------------------------------
 METHOD: init:
 
 PURPOSE:
 Initialize the object values.
 -----------------------------------------------------------------------------*/
- (id)init
{
	if (self = [super init]) {
        NSLog(@"dfvdf");
        self.productsInspectionArray = [[NSMutableArray alloc] init];
        [self calculateProducts];
    }
	
	return self;
}

- (void) calculateProducts {
    for (int i = 0; i<3; i++)  {
        inspectionTableView = [[InspectionTableViewController alloc] initWithNibName:@"InspectionTableViewController" bundle:nil];
        inspectionTableView.view.frame = CGRectMake(0, 0, 320, [inspectionTableView calculateTheNumberOfRowsAndReturnHeight]);
        [self.productsInspectionArray addObject:inspectionTableView.view];
    }
}

- (void) bringInspection {
    InspectionStatusViewController *inspectionStatusView = [[InspectionStatusViewController alloc] initWithNibName:@"InspectionStatusViewController" bundle:nil];
    [self.navigationController pushViewController:inspectionStatusView animated:YES];
}

@end
