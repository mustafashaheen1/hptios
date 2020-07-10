//
//  CompleteInspectionsListViewController.h
//  Insights
//
//  Created by Shyam Ashok on 12/28/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "ParentNavigationViewController.h"

@interface CompleteInspectionsListViewController : ParentNavigationViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *inspectionsListTableView;
@property (strong, nonatomic) NSMutableArray *completeListArray;
@property (strong, nonatomic) SyncOverlayView *syncOverlay;

- (IBAction)removeView:(id)sender;

@end
