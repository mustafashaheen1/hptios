//
//  SettingsViewController.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/18/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParentNavigationViewController.h"
#import "NetworkPreferencesViewCell.h"
#import "SyncPreferencesViewCell.h"
#import "UserPreferencesViewCell.h"
#import "SyncOverlayView.h"
#import "SyncManager.h"
#import "SyncOverWifiViewCellTableViewCell.h"
#import "SyncHistoryTableViewCell.h"
#import "OrderDataTableViewCell.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "CrashLogsViewCell.h"

@protocol SettingsViewControllerDelegate <NSObject>
@required
- (void) downloadSyncDone: (BOOL)success;
@end

@interface SettingsViewController : ParentNavigationViewController <UITableViewDataSource, UITableViewDelegate, SyncManagerDelegate, TestConnectionDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *settingsTable;
@property (weak, nonatomic) IBOutlet NetworkPreferencesViewCell *networkPreferencesCell;
@property (weak, nonatomic) IBOutlet SyncPreferencesViewCell *syncPreferencesCell;
@property (weak, nonatomic) IBOutlet CrashLogsViewCell *crashLogsViewCell;
@property (weak, nonatomic) IBOutlet UserPreferencesViewCell *userPreferencesCell;
@property (weak, nonatomic) IBOutlet SyncOverWifiViewCellTableViewCell *syncOverWifiViewCellTableViewCell;

@property (weak, nonatomic) IBOutlet SyncHistoryTableViewCell *syncHistoryTableViewCell;
@property (weak, nonatomic) IBOutlet OrderDataTableViewCell *orderDataTableViewCell;
@property (strong, nonatomic) SyncOverlayView *syncOverlay;
@property (strong, nonatomic) SyncManager *syncManager;
@property (retain) id <SettingsViewControllerDelegate> delegate;
@property (strong, nonatomic) NSArray *pendingAuditsArray;
@property (strong, nonatomic) NSArray *submittedAuditsArray;
@property (strong, nonatomic) NSArray *pendingScanoutsArray;
@property (strong, nonatomic) NSArray *submittedScanoutsArray;

@end
