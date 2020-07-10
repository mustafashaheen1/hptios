//
//  InspectionSummaryViewController.h
//  Insights
//
//  Created by Vineet Pareek on 26/10/2015.
//  Copyright © 2015 Yottamark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParentNavigationViewController.h"
#import "SKSTableView.h"
#import "UIPopoverListView.h"
#import "Summary.h"
#import "SyncOverlayView.h"
#import "InspectionSubTableViewCell.h"
#import "RowSectionButton.h"
#import "SummaryDetailsTableViewCell.h"

@interface InspectionSummaryViewController : ParentNavigationViewController <UITableViewDataSource, UITableViewDelegate, SKSTableViewDelegate, UIPopoverListViewDelegate, UIPopoverListViewDataSource,UIAlertViewDelegate, InspectionSubTableViewCellDelegate,SummaryDetailsTableViewCellDelegate> {
    
}

@property (nonatomic, strong) SKSTableView *table;
@property (nonatomic, strong) NSArray *allSavedAudits;
@property (nonatomic, strong) NSArray *statusValues;
@property (nonatomic, strong) SyncOverlayView *syncOverlayView;
@property (nonatomic, strong) NSArray *distinctSupplierNames;

@end
