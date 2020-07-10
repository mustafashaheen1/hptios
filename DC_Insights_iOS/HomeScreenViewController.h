//
//  HomeScreenViewController.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/13/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "ParentNavigationViewController.h"
#import "InspectionTableViewCell.h"
#import "SyncManager.h"
#import "SyncOverlayView.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "LogViewController.h"
#import "CompleteInspectionsListViewController.h"
#import "UploadCompleteView.h"

@interface HomeScreenViewController : ParentNavigationViewController </*UITableViewDataSource, UITableViewDelegate,*/ UIScrollViewDelegate, SyncManagerDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate,UIPopoverListViewDelegate, UIPopoverListViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) IBOutlet UILabel *resumeInspectionLabel;
@property (strong, nonatomic) IBOutlet UIButton *startNewInspectionButton;
@property (strong, nonatomic) IBOutlet InspectionTableViewCell *inspectionTableViewCell;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) IBOutlet UIButton *updateLocationButton;
@property (strong, nonatomic) IBOutlet UIButton *selectLocationButton;
@property (strong, nonatomic) IBOutlet UIButton *logoutButton;
@property (strong, nonatomic) IBOutlet UILabel *emailAddress;
@property (strong, nonatomic) IBOutlet UILabel *storeName;
@property (strong, nonatomic) IBOutlet UILabel *address;
@property (strong, nonatomic) NSArray *pastInspections;
@property (strong, nonatomic) SyncManager *syncManager;
//@property (strong, nonatomic) SyncOverlayView *syncOverlayView;
@property (assign, nonatomic) BOOL auditsPresentForUploadGlobal;
@property (assign, nonatomic) int retryCount;
@property (assign, nonatomic) int auditsUploadedTotalUsingRetries;
@property (assign, nonatomic) int imagesUploadedTotalUsingRetries;
@property (assign, nonatomic) BOOL updatedLocationTouched;
@property (strong, nonatomic) UITextView *logsView;
@property (strong, nonatomic) LogViewController *logViewController;
@property (strong, nonatomic) CompleteInspectionsListViewController *completeInspectionsListViewController;
@property (strong, nonatomic) IBOutlet UIButton *showCompletedInspectionsButton;
@property (strong, nonatomic) IBOutlet UIButton *dividerButton;
@property (weak, nonatomic) IBOutlet UIButton *savedInspectionsButton;
@property (weak, nonatomic) IBOutlet UIButton *savedInspDividerButton;
@property (weak, nonatomic) IBOutlet UploadCompleteView *uploadCompleteView;
@property (assign,nonatomic) int orderDataStatus;

- (IBAction)savedInspectionButtonTouched:(id)sender;
- (IBAction)startNewInspectionButtonTouched:(id)sender;
- (IBAction)selectLocationButtonTouched:(id)sender;
- (IBAction)logoutButtonTouched:(id)sender;
- (IBAction)updateLocationButtonTouched:(id)sender;
- (IBAction)bringCompleteInspectionsList:(id)sender;

@end
