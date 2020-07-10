//
//  InspectionViewControllerWithTableViewController.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/19/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParentNavigationViewController.h"

@interface InspectionViewControllerWithTableViewController : ParentNavigationViewController <UITableViewDelegate, UITableViewDataSource>

@property (retain, nonatomic) NSMutableArray *defectsArray;
@property (retain, nonatomic) NSMutableArray *majorMinorMediumArray;
@property (retain, nonatomic) NSMutableArray *tableDefectsTotalArray;
@property (strong, nonatomic) UITableView *table;

- (CGFloat) calculateTheNumberOfRowsAndReturnHeight;

// DEAD CODE

@end
