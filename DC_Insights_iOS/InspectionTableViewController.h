//
//  InspectionTableViewController.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/18/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InspectionTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (retain, nonatomic) NSMutableArray *defectsArray;
@property (retain, nonatomic) NSMutableArray *majorMinorMediumArray;
@property (retain, nonatomic) NSMutableArray *tableDefectsTotalArray;
@property (retain, nonatomic) IBOutlet UITableView *table;

- (CGFloat) calculateTheNumberOfRowsAndReturnHeight;

// DEAD CODE

@end
