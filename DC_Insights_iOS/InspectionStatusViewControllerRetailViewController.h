//
//  InspectionStatusViewControllerRetailViewController.h
//  Insights
//
//  Created by Shyam Ashok on 8/29/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParentNavigationViewController.h"
#import "SyncOverlayView.h"
#import "SKSTableView.h"
#import "SKSTableViewCell.h"
#import "Constants.h"

@interface InspectionStatusViewControllerRetailViewController : ParentNavigationViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, SKSTableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *table;
@property (nonatomic, strong) NSArray *productAudits;
@property (nonatomic, strong) SyncOverlayView *syncOverlayView;
@property (nonatomic, strong) NSArray *products;
@property (nonatomic, strong) SKSTableView *tableSKS;
@property (nonatomic, strong) NSMutableArray *productGroups;

@end
