//
//  InspectionInfoTableViewController.h
//  DC_Insights_iOS
//
//  Created by John Gifford on 11/5/13.
//  Copyright (c) 2013 Yottamark. All rights reserved.
//
// This is the controller for the "Inspection Info" table view.  This view
// will contain the preliminary form for the inspector to complete before
// starting a new inspection.
//


#import <UIKit/UIKit.h>
#import "UIPopoverListView.h"

//This controller uses three different delegates for various tasks
@interface InspectionInfoTableViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UIPopoverListViewDataSource, UIPopoverListViewDelegate, UINavigationControllerDelegate>

//Return to user/location select
- (IBAction)homeButtonClick:(id)sender;

//Creates pop up spinner view to choose type of inspection
- (void) selectInspectionType;

@end
