//
//  InspectionTableView.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 4/29/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InspectionTotalSummaryTableViewCell.h"
#import "Summary.h"
#import "InspectionDefectTableTableViewCell.h"
#import "SyncOverlayView.h"
#import "SavedAudit.h"
#import "UserNetworkActivityView.h"
#import "UserNetworkActivityViewProtocol.h"
#import "SCLAlertView.h"
#import "RowSectionButton.h"

#define kInspectionSubTableViewCellReuseID @"InspectionSubTableViewCell"
#define kInspectionSubTableViewCellNIBFile @"InspectionSubTableViewCell"

@protocol InspectionSubTableViewCellDelegate <NSObject>
-(void) refreshSavedAudits;
@required
- (void) updateCountOfCasesAndReloadTableView;
@end

@interface InspectionSubTableViewCell : UITableViewCell <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UserNetworkActivityViewProtocol, SummaryAveragesDelegate>

@property (strong, nonatomic) IBOutlet InspectionTotalSummaryTableViewCell *inspectionTotalSummaryTableViewCell;
@property (strong, nonatomic) RowSectionButton *modifyInspectionButton;
@property (strong, nonatomic) RowSectionButton *changeStatusButton;
@property (strong, nonatomic) RowSectionButton *closeButton;
@property (strong, nonatomic) SyncOverlayView *syncOverlayView;
@property (strong, nonatomic) UITextField *textFieldCountOfCases;
@property (strong, nonatomic) UIButton *buttonEditableForCountOfCases;
@property (strong, nonatomic) SavedAudit *savedAudit;
@property (strong, nonatomic) Summary *summary;
@property (assign, nonatomic) int totalHeight;
@property (strong, nonatomic) NSMutableDictionary *heightDictForRatings;
@property (weak, nonatomic) UITableView *parentTableView;
@property (weak, nonatomic) id <InspectionSubTableViewCellDelegate> delegate;
@property (strong, nonatomic) Product *globalProduct;
@property (strong, nonatomic) UISwitch *switchview;

@property (assign,nonatomic) BOOL updateAveragesTableView;

-(int)getTotalHeightForTableView;
-(int)calculateHeightForTheInspectionDefectCell2;


@end
