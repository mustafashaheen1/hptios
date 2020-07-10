//
//  InspectionTableManager.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/18/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InspectionTableViewController.h"

@interface InspectionTableManager : NSObject

@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) NSMutableArray *productsInspectionArray;
@property (strong, nonatomic) InspectionTableViewController *inspectionTableView;

- (void) bringInspection;

@end
