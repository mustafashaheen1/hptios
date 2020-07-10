//
//  SettingsViewController.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/18/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "SettingsViewController.h"
#import "SyncManager.h"
#import "NSUserDefaultsManager.h"
#import "User.h"
#import "DeviceManager.h"
#import "OpenUDID.h"
#import "Audit.h"
#import "PendingAudits.h"
#import "SubmittedAudits.h"
#import "CompletedScanout.h"
#import <Google/SignIn.h>
#import "CrashLogHandler.h"
#import "OrderDataAPI.h"
#import "UploadsLogHandler.h"

#define SyncHistoryHeaderHeight 30

@interface SettingsViewController ()
@property NSMutableArray *results;
@property NSString *apiResponse;
@end

@implementation SettingsViewController

@synthesize networkPreferencesCell;
@synthesize syncPreferencesCell;
@synthesize userPreferencesCell;
@synthesize syncOverWifiViewCellTableViewCell;
@synthesize syncOverlay;
@synthesize syncManager;
@synthesize delegate;
@synthesize syncHistoryTableViewCell;
@synthesize orderDataTableViewCell;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    /*if([[User sharedUser] checkForScanOut]) {
        self.pendingScanoutsArray = [[User sharedUser] getAllPendingScanouts];
        self.submittedScanoutsArray = [[User sharedUser] getAllSubmittedScanouts];
    } else {
     */
        self.pendingAuditsArray = [[User sharedUser] getAllPendingAudits];
        self.submittedAuditsArray = [[User sharedUser] getAllSubmittedAudits];
    self.pageTitle = @"SettingsViewController";
    [self setupNavBar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
   // return 3; // 4 - sync history to be added later
    if ([[User sharedUser] checkIfUserLoggedIn]) {
        if ([[User sharedUser] checkForRetailInsights] || [[User sharedUser] checkForScanOut]) {
            return 4 + 2 + 2+2+1;//for log button & clear data button
        } else {
            return 5 + 5 + 2+1+1+1+1+1;//for log button & clear data button
        }
    } else {
        return 2;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    float screen_width = self.settingsTable.bounds.size.width; //to fix the incorrect view width
    UILabel *titleView;
    UIView *sectionViewForSectionTwo;
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screen_width, 5)];
    line.backgroundColor = [UIColor blackColor];
    //if (section == 5) {
    if ([[User sharedUser] checkForRetailInsights] || [[User sharedUser] checkForScanOut]) {
        if (section == 8 || section == 9) {
            
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screen_width, 3)];
            line.backgroundColor = [UIColor blackColor];
            
            titleView = [[UILabel alloc] initWithFrame:CGRectZero];
            titleView.font = [UIFont systemFontOfSize:17.0f];
            titleView.textColor = [UIColor blackColor];
            titleView.textAlignment = NSTextAlignmentCenter;
            if (section == 8) {
                titleView.text = @"Pending";
            } else {
                titleView.text = @"Submitted";
            }
            titleView.frame = CGRectMake(0, 3, screen_width, 32.0f);
            
            UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(0, 35, screen_width, 3)];
            line2.backgroundColor = [UIColor grayColor];
            
            sectionViewForSectionTwo = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screen_width, 35)];
            sectionViewForSectionTwo.backgroundColor = [UIColor whiteColor];
            [sectionViewForSectionTwo addSubview:titleView];
            [sectionViewForSectionTwo addSubview:line];
            [sectionViewForSectionTwo addSubview:line2];
            
            return sectionViewForSectionTwo;
        }
    } else {
        if (section == 8 || section == 9) {
            
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screen_width, 3)];
            line.backgroundColor = [UIColor blackColor];
            
            titleView = [[UILabel alloc] initWithFrame:CGRectZero];
            titleView.font = [UIFont systemFontOfSize:17.0f];
            titleView.textColor = [UIColor blackColor];
            titleView.textAlignment = NSTextAlignmentCenter;
            if (section == 8) {
                titleView.text = @"Pending Audits";
            } else {
                titleView.text = @"Submitted Audits";
            }
            titleView.frame = CGRectMake(0, 3, screen_width, 32.0f);
            
            UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(0, 35, screen_width, 3)];
            line2.backgroundColor = [UIColor blackColor];
            
            sectionViewForSectionTwo = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screen_width, 35)];
            sectionViewForSectionTwo.backgroundColor = [UIColor whiteColor];
            [sectionViewForSectionTwo addSubview:titleView];
            [sectionViewForSectionTwo addSubview:line];
            [sectionViewForSectionTwo addSubview:line2];
            
            return sectionViewForSectionTwo;
        }
    }
    
    return line;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (![[User sharedUser] checkIfUserLoggedIn]) {
        if (section == 0) {
            return 2;
        } else if (section == 1) {
            return 2;
        } else {
            return 2;
        }
    } else if ([[User sharedUser] checkForRetailInsights] || [[User sharedUser] checkForScanOut]) {
        if (section == 0) {
            return 2;
        } else if (section == 1) {
            return 2;
        } else if (section == 2) {
            return 2;
        } else if (section == 3) {
            return 2;
        } else if (section == 4) {
            return 2;
        } else if (section == 5) {
            return 0;
        } else if (section == 6) {
            return 2;
        } else if (section == 7) {
            return 0;
        } else if (section == 8) {
            return SyncHistoryHeaderHeight;
        } else if (section == 9) {
            return SyncHistoryHeaderHeight;
        }else {
            return 2;
        }
    } else {
        if (section == 0) {
            return 2;
        } else if (section == 1) {
            return 2;
        } else if (section == 2) {
            return 2;
        } else if (section == 3) {
            return 2;
        } else if (section == 4) {
            return 2;
        } else if (section == 5) {
            return 2;
        } else if (section == 6) {
            return 0;
        } else if (section == 7) {
            return 0;
        } else if (section == 8) {
            return SyncHistoryHeaderHeight;
        } else if (section == 9) {
            return SyncHistoryHeaderHeight;
        } else {
            return 2;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (![[User sharedUser] checkIfUserLoggedIn]) {
        if (section == 0) {
            return 1;
        } else if (section == 1) {
            return 1;
        } else {
            return 1;
        }
    } else if ([[User sharedUser] checkForRetailInsights] || [[User sharedUser] checkForScanOut]) {
        if (section == 0) {
            return 1;
        } else if (section == 1) {
            return 1;
        } else if (section == 2) {
            return 1;
        } else if (section == 3) {
            return 1;
        } else if (section == 4) {
            return 1;
        } else if (section == 5) {
            return 1;
        } else if (section == 6) {
            return 1;
        } else if (section == 7) {
            return 1;
        } else if (section == 8) {
            return [self.pendingAuditsArray count] + 1;
        } else if (section == 9) {
            return [self.submittedAuditsArray count] + 1;
        }else {
            return 1;
        }
    } else {
        if (section == 0) {
            return 1;
        } else if (section == 1) {
            return 1;
        } else if (section == 2) {
            return 1;
        } else if (section == 3) {
            return 1;
        } else if (section == 4) {
            return 1;
        } else if (section == 5) {
            return 1;
        } else if (section == 6) {
            return 1;
        } else if (section == 7) {
            return 1;
        } else if (section == 8) {
            return [self.pendingAuditsArray count] + 1;
        } else if (section == 9) {
            return [self.submittedAuditsArray count] + 1;
        } else {
            return 1;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![[User sharedUser] checkIfUserLoggedIn]) {
        if (indexPath.section == 0) {
            NetworkPreferencesViewCell *newCell = [tableView dequeueReusableCellWithIdentifier:@"NetworkPreferencesViewCell"];
            if (newCell == nil) {
                [[NSBundle mainBundle] loadNibNamed:@"NetworkPreferencesViewCell" owner:self options:nil];
                newCell = networkPreferencesCell;
                newCell.delegate = self;
                [newCell.testConnectionButton addTarget:self action:@selector(testConnectionButtonTouched) forControlEvents:UIControlEventTouchUpInside];
                [newCell refreshState];
                self.networkPreferencesCell = nil;
            }
            return newCell;
        } else {
            SyncOverWifiViewCellTableViewCell *newCell = [tableView dequeueReusableCellWithIdentifier:@"SyncOverWifiViewCellTableViewCell"];
            if (newCell == nil) {
                [[NSBundle mainBundle] loadNibNamed:@"SyncOverWifiViewCellTableViewCell" owner:self options:nil];
                newCell = syncOverWifiViewCellTableViewCell;
                if ([NSUserDefaultsManager getBOOLFromUserDeafults:SyncOverWifi]) {
                    [newCell.syncOverWifiButton setOn:YES animated:NO];
                } else {
                    [newCell.syncOverWifiButton setOn:NO animated:NO];
                }
                [newCell.syncOverWifiButton addTarget:self action:@selector(syncOverWifiTouched:) forControlEvents:UIControlEventTouchUpInside];
                self.syncOverWifiViewCellTableViewCell = nil;
            }
            return newCell;
        }
    } else if ([[User sharedUser] checkForRetailInsights] || [[User sharedUser] checkForScanOut]) {
        if (indexPath.section == 0) {
            NetworkPreferencesViewCell *newCell = [tableView dequeueReusableCellWithIdentifier:@"NetworkPreferencesViewCell"];
            if (newCell == nil) {
                [[NSBundle mainBundle] loadNibNamed:@"NetworkPreferencesViewCell" owner:self options:nil];
                newCell = networkPreferencesCell;
                newCell.delegate = self;
                [newCell.testConnectionButton addTarget:self action:@selector(testConnectionButtonTouched) forControlEvents:UIControlEventTouchUpInside];
                [newCell refreshState];
                self.networkPreferencesCell = nil;
            }
            return newCell;
        } else if (indexPath.section == 1) {
            SyncPreferencesViewCell *newCell = [tableView dequeueReusableCellWithIdentifier:@"SyncPreferencesViewCell"];
            if (newCell == nil) {
                [[NSBundle mainBundle] loadNibNamed:@"SyncPreferencesViewCell" owner:self options:nil];
                newCell = syncPreferencesCell;
                [newCell.syncNowButton addTarget:self action:@selector(syncNowTouched) forControlEvents:UIControlEventTouchUpInside];
                [newCell refreshState];
                self.syncPreferencesCell = nil;
            }
            return newCell;
        } else if (indexPath.section == 2) {
            UserPreferencesViewCell *newCell = [tableView dequeueReusableCellWithIdentifier:@"UserPreferencesViewCell"];
            if (newCell == nil) {
                [[NSBundle mainBundle] loadNibNamed:@"UserPreferencesViewCell" owner:self options:nil];
                newCell = userPreferencesCell;
                [newCell.clearLoginInfoButton addTarget:self action:@selector(clearLoginInfo) forControlEvents:UIControlEventTouchUpInside];
                [newCell refreshState];
                self.userPreferencesCell = nil;
            }
            return newCell;
        } else if (indexPath.section == 3) {
            SyncOverWifiViewCellTableViewCell *newCell = [tableView dequeueReusableCellWithIdentifier:@"SyncOverWifiViewCellTableViewCell"];
            if (newCell == nil) {
                [[NSBundle mainBundle] loadNibNamed:@"SyncOverWifiViewCellTableViewCell" owner:self options:nil];
                newCell = syncOverWifiViewCellTableViewCell;
                if ([NSUserDefaultsManager getBOOLFromUserDeafults:SyncOverWifi]) {
                    [newCell.syncOverWifiButton setOn:YES animated:NO];
                } else {
                    [newCell.syncOverWifiButton setOn:NO animated:NO];
                }
                [newCell.syncOverWifiButton addTarget:self action:@selector(syncOverWifiTouched:) forControlEvents:UIControlEventTouchUpInside];
                self.syncOverWifiViewCellTableViewCell = nil;
            }
            return newCell;
        } else if (indexPath.section == 4 || indexPath.section == 5) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
            if(cell == nil)
            {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellID"];
            }
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat: @"yyyy-MM-dd HH:mm:ss zzz"];
            if (indexPath.section == 4) {
                cell.textLabel.text = LastDownloadSync;
                NSDate *date = [NSUserDefaultsManager getObjectFromUserDeafults:SyncDownloadTime];
                NSString *stringFromDate = [formatter stringFromDate:date];
                cell.detailTextLabel.text = stringFromDate;
            } else if (indexPath.section == 5) {
                cell.textLabel.text = LastUploadSync;
                NSDate *date = [NSUserDefaultsManager getObjectFromUserDeafults:SyncUploadTime];
                NSString *stringFromDate = [formatter stringFromDate:date];
                cell.detailTextLabel.text = stringFromDate;
            }
            return cell;
        }
//        else if (indexPath.section == 6) {
//            SyncHistoryTableViewCell *newCell = [tableView dequeueReusableCellWithIdentifier:@"SyncHistoryTableViewCell"];
//            if (newCell == nil) {
//                [[NSBundle mainBundle] loadNibNamed:@"SyncHistoryTableViewCell" owner:self options:nil];
//                newCell = syncHistoryTableViewCell;
//                self.syncHistoryTableViewCell = nil;
//            }
//            if (indexPath.row == 0) {
//                newCell.auditsNumberLabel.text = @"Audit ID";
//                newCell.auditsCountLabel.text = @"Audits";
//                newCell.imagesCountLabel.text = @"Images";
//                newCell.statusLabel.text = @"Status";
//                newCell.statusLabel.textColor = [UIColor blackColor];
//            } else {
//                
//            }
//            return newCell;
//        }
        else if (indexPath.section == 6) {
            UITableViewCell *emptyCell;
            emptyCell = [tableView dequeueReusableCellWithIdentifier:@"EmptyTableCell"];
            if (emptyCell == nil) {
                emptyCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EmptyTableCell"];
                emptyCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            emptyCell.textLabel.text = @"Send Log";
            emptyCell.textLabel.textAlignment = NSTextAlignmentCenter;
            return emptyCell;
        } else if (indexPath.section == 7) {
            UITableViewCell *emptyCell;
            emptyCell = [tableView dequeueReusableCellWithIdentifier:@"EmptyTableCell"];
            if (emptyCell == nil) {
                emptyCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EmptyTableCell"];
                emptyCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            emptyCell.textLabel.text = @"Clear Audits database";
            emptyCell.textLabel.textAlignment = NSTextAlignmentCenter;
            return emptyCell;
        }else if (indexPath.section == 8) {
            SyncHistoryTableViewCell *newCell = [tableView dequeueReusableCellWithIdentifier:@"SyncHistoryTableViewCell"];
            if (newCell == nil) {
                [[NSBundle mainBundle] loadNibNamed:@"SyncHistoryTableViewCell" owner:self options:nil];
                newCell = syncHistoryTableViewCell;
                self.syncHistoryTableViewCell = nil;
            }
            if (indexPath.row == 0) {
                newCell.auditsNumberLabel.text = @"Audit ID";
                newCell.auditsCountLabel.text = @"Audits";
                newCell.imagesCountLabel.text = @"Images";
                newCell.statusLabel.text = @"Status";
                newCell.statusLabel.textColor = [UIColor blackColor];
            } else {
                PendingAudits *pendingAudits = [self.pendingAuditsArray objectAtIndex:indexPath.row - 1];
                newCell.auditsNumberLabel.text = pendingAudits.auditMasterId;
                newCell.auditsCountLabel.text = [NSString stringWithFormat:@"%d", pendingAudits.auditCount];
                newCell.imagesCountLabel.text = [NSString stringWithFormat:@"%d", pendingAudits.imageCount];
                newCell.statusLabel.text = pendingAudits.dateCompleted;
                newCell.statusLabel.textColor = [UIColor redColor];
            }
            return newCell;
        } else if (indexPath.section == 9) {
            SyncHistoryTableViewCell *newCell = [tableView dequeueReusableCellWithIdentifier:@"SyncHistoryTableViewCell"];
            if (newCell == nil) {
                [[NSBundle mainBundle] loadNibNamed:@"SyncHistoryTableViewCell" owner:self options:nil];
                newCell = syncHistoryTableViewCell;
                self.syncHistoryTableViewCell = nil;
            }
            if (indexPath.row == 0) {
                newCell.auditsNumberLabel.text = @"Audit ID";
                newCell.auditsCountLabel.text = @"Audits";
                newCell.imagesCountLabel.text = @"Images";
                newCell.statusLabel.text = @"Status";
                newCell.statusLabel.textColor = [UIColor blackColor];
            } else {
                SubmittedAudits *submittedAudits = [self.submittedAuditsArray objectAtIndex:indexPath.row - 1];
                newCell.auditsNumberLabel.text = submittedAudits.auditMasterId;
                newCell.auditsCountLabel.text = [NSString stringWithFormat:@"%d", submittedAudits.auditCount];
                newCell.imagesCountLabel.text = [NSString stringWithFormat:@"%d", submittedAudits.imageCount];
                newCell.statusLabel.text = submittedAudits.dateSubmitted;
            }
            return newCell;
        }
    }
    else {
        if (indexPath.section == 0) {
            NetworkPreferencesViewCell *newCell = [tableView dequeueReusableCellWithIdentifier:@"NetworkPreferencesViewCell"];
            if (newCell == nil) {
                [[NSBundle mainBundle] loadNibNamed:@"NetworkPreferencesViewCell" owner:self options:nil];
                newCell = networkPreferencesCell;
                newCell.delegate = self;
                [newCell.testConnectionButton addTarget:self action:@selector(testConnectionButtonTouched) forControlEvents:UIControlEventTouchUpInside];
                [newCell refreshState];
                self.networkPreferencesCell = nil;
            }
            return newCell;
        } else if (indexPath.section == 1) {
            SyncPreferencesViewCell *newCell = [tableView dequeueReusableCellWithIdentifier:@"SyncPreferencesViewCell"];
            if (newCell == nil) {
                [[NSBundle mainBundle] loadNibNamed:@"SyncPreferencesViewCell" owner:self options:nil];
                newCell = syncPreferencesCell;
                [newCell.syncNowButton addTarget:self action:@selector(syncNowTouched) forControlEvents:UIControlEventTouchUpInside];
                [newCell refreshState];
                self.syncPreferencesCell = nil;
            }
            return newCell;
        } else if (indexPath.section == 2) {
            UserPreferencesViewCell *newCell = [tableView dequeueReusableCellWithIdentifier:@"UserPreferencesViewCell"];
            if (newCell == nil) {
                [[NSBundle mainBundle] loadNibNamed:@"UserPreferencesViewCell" owner:self options:nil];
                newCell = userPreferencesCell;
                [newCell.clearLoginInfoButton addTarget:self action:@selector(clearLoginInfo) forControlEvents:UIControlEventTouchUpInside];
                [newCell refreshState];
                self.userPreferencesCell = nil;
            }
            return newCell;
        } else if (indexPath.section == 3) {
            OrderDataTableViewCell *newCell = [tableView dequeueReusableCellWithIdentifier:@"OrderDataTableViewCell"];
            if (newCell == nil) {
                [[NSBundle mainBundle] loadNibNamed:@"OrderDataTableViewCell" owner:self options:nil];
                newCell = orderDataTableViewCell;
                [newCell.downloadButton addTarget:self action:@selector(orderDataButtonTouched) forControlEvents:UIControlEventTouchUpInside];
                [newCell refreshState];
                self.orderDataTableViewCell = nil;
            }
            return newCell;
        } else if (indexPath.section == 4) {
            SyncOverWifiViewCellTableViewCell *newCell = [tableView dequeueReusableCellWithIdentifier:@"SyncOverWifiViewCellTableViewCell"];
            if (newCell == nil) {
                [[NSBundle mainBundle] loadNibNamed:@"SyncOverWifiViewCellTableViewCell" owner:self options:nil];
                newCell = syncOverWifiViewCellTableViewCell;
                if ([NSUserDefaultsManager getBOOLFromUserDeafults:SyncOverWifi]) {
                    [newCell.syncOverWifiButton setOn:YES animated:NO];
                } else {
                    [newCell.syncOverWifiButton setOn:NO animated:NO];
                }
                [newCell.syncOverWifiButton addTarget:self action:@selector(syncOverWifiTouched:) forControlEvents:UIControlEventValueChanged];
                self.syncOverWifiViewCellTableViewCell = nil;
            }
            return newCell;
        } else if (indexPath.section == 5 || indexPath.section == 6 || indexPath.section == 7) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
            if(cell == nil)
            {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellID"];
            }
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat: @"yyyy-MM-dd HH:mm:ss zzz"];
            if (indexPath.section == 5) {
                cell.textLabel.text = LastDownloadSync;
                NSDate *date = [NSUserDefaultsManager getObjectFromUserDeafults:SyncDownloadTime];
                NSString *stringFromDate = [formatter stringFromDate:date];
                cell.detailTextLabel.text = stringFromDate;
            } else if (indexPath.section == 6) {
                cell.textLabel.text = LastUploadSync;
                NSDate *date = [NSUserDefaultsManager getObjectFromUserDeafults:SyncUploadTime];
                NSString *stringFromDate = [formatter stringFromDate:date];
                cell.detailTextLabel.text = stringFromDate;
            } else if (indexPath.section == 7) {
                cell.textLabel.text = LastOrderDataDownloadSync;
                NSDate *date = [NSUserDefaultsManager getObjectFromUserDeafults:SyncOrderDataDownloadTime];
                NSString *stringFromDate = [formatter stringFromDate:date];
                cell.detailTextLabel.text = stringFromDate;
            }
            return cell;
        } else if (indexPath.section == 8) {
            SyncHistoryTableViewCell *newCell = [tableView dequeueReusableCellWithIdentifier:@"SyncHistoryTableViewCell"];
            if (newCell == nil) {
                [[NSBundle mainBundle] loadNibNamed:@"SyncHistoryTableViewCell" owner:self options:nil];
                newCell = syncHistoryTableViewCell;
                self.syncHistoryTableViewCell = nil;
            }
            if (indexPath.row == 0) {
                newCell.auditsNumberLabel.text = @"Audit ID";
                newCell.auditsCountLabel.text = @"Audits";
                newCell.imagesCountLabel.text = @"Images";
                newCell.statusLabel.text = @"Status";
                newCell.statusLabel.textColor = [UIColor blackColor];
            } else {
                PendingAudits *pendingAudits = [self.pendingAuditsArray objectAtIndex:indexPath.row - 1];
                newCell.auditsNumberLabel.text = pendingAudits.auditMasterId;
                newCell.auditsCountLabel.text = [NSString stringWithFormat:@"%d", pendingAudits.auditCount];
                newCell.imagesCountLabel.text = [NSString stringWithFormat:@"%d", pendingAudits.imageCount];
                newCell.statusLabel.text = pendingAudits.dateCompleted;
                newCell.statusLabel.textColor = [UIColor redColor];
            }
            return newCell;
        } else if (indexPath.section == 9) {
            SyncHistoryTableViewCell *newCell = [tableView dequeueReusableCellWithIdentifier:@"SyncHistoryTableViewCell"];
            if (newCell == nil) {
                [[NSBundle mainBundle] loadNibNamed:@"SyncHistoryTableViewCell" owner:self options:nil];
                newCell = syncHistoryTableViewCell;
                self.syncHistoryTableViewCell = nil;
            }
            if (indexPath.row == 0) {
                newCell.auditsNumberLabel.text = @"Audit ID";
                newCell.auditsCountLabel.text = @"Audits";
                newCell.imagesCountLabel.text = @"Images";
                newCell.statusLabel.text = @"Status";
                newCell.statusLabel.textColor = [UIColor blackColor];
            } else {
                SubmittedAudits *submittedAudits = [self.submittedAuditsArray objectAtIndex:indexPath.row - 1];
                newCell.auditsNumberLabel.text = submittedAudits.auditMasterId;
                newCell.auditsCountLabel.text = [NSString stringWithFormat:@"%d", submittedAudits.auditCount];
                newCell.imagesCountLabel.text = [NSString stringWithFormat:@"%d", submittedAudits.imageCount];
                newCell.statusLabel.text = submittedAudits.dateSubmitted;
            }
            return newCell;
        } else if (indexPath.section == 10) {
            UITableViewCell *emptyCell;
            emptyCell = [tableView dequeueReusableCellWithIdentifier:@"EmptyTableCell"];
            if (emptyCell == nil) {
                emptyCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EmptyTableCell"];
                emptyCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            emptyCell.textLabel.text = @"Send Log";
            emptyCell.textLabel.textAlignment = NSTextAlignmentCenter;
            return emptyCell;
        } else if (indexPath.section == 11) {
            UITableViewCell *emptyCell;
            emptyCell = [tableView dequeueReusableCellWithIdentifier:@"EmptyTableCell"];
            if (emptyCell == nil) {
                emptyCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EmptyTableCell"];
                emptyCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            emptyCell.textLabel.text = @"Clear Audits database";
            emptyCell.textLabel.textAlignment = NSTextAlignmentCenter;
            return emptyCell;
        }else if (indexPath.section == 12) {
            SyncOverWifiViewCellTableViewCell *newCell = [tableView dequeueReusableCellWithIdentifier:@"SyncOverWifiViewCellTableViewCell"];
            //if (newCell == nil) {
                [[NSBundle mainBundle] loadNibNamed:@"SyncOverWifiViewCellTableViewCell" owner:self options:nil];
                newCell = syncOverWifiViewCellTableViewCell;
                 newCell.toggleLabel.text = @"Collaborative Inspections";
                 newCell.detailsLabel.text = @"Collaborative Inspections requires a continuous data connection";
                newCell.detailsLabel.hidden = NO;
                //newCell.detailsLabel.numberOfLines=2;
                newCell.detailsLabel.lineBreakMode = NSLineBreakByWordWrapping;
                if ([NSUserDefaultsManager getBOOLFromUserDeafults:colloborativeInspectionsEnabled]) {
                    [newCell.syncOverWifiButton setOn:YES animated:NO];
                } else {
                    [newCell.syncOverWifiButton setOn:NO animated:NO];
                }
                [newCell.syncOverWifiButton addTarget:self action:@selector(toggleCollabInspections:) forControlEvents:UIControlEventValueChanged];
            //[newCell.syncOverWifiButton addTarget:self action:@selector(toggleCollabInspections:) forControlEvents:UIControlEventTouchUpInside];
                self.syncOverWifiViewCellTableViewCell = nil;
            //}
            return newCell;
        }else if (indexPath.section == 13) {
            SyncOverWifiViewCellTableViewCell *newCell = [tableView dequeueReusableCellWithIdentifier:@"SyncOverWifiViewCellTableViewCell"];
            //if (newCell == nil) {
                [[NSBundle mainBundle] loadNibNamed:@"SyncOverWifiViewCellTableViewCell" owner:self options:nil];
                newCell = syncOverWifiViewCellTableViewCell;
                newCell.toggleLabel.text = @"Incremental Sync";
                //newCell.detailsLabel.text = @"Collaborative Inspections requires a continuous data connection";
                //newCell.detailsLabel.hidden = YES;
                //newCell.detailsLabel.numberOfLines=2;
                newCell.detailsLabel.lineBreakMode = NSLineBreakByWordWrapping;
                if ([NSUserDefaultsManager getBOOLFromUserDeafults:enableIncrementalSync]) {
                    [newCell.syncOverWifiButton setOn:YES animated:NO];
                } else {
                    [newCell.syncOverWifiButton setOn:NO animated:NO];
                }
                [newCell.syncOverWifiButton addTarget:self action:@selector(toggleDisableIncrementalSync:) forControlEvents:UIControlEventValueChanged];
                self.syncOverWifiViewCellTableViewCell = nil;
            //}
            return newCell;
        }else if(indexPath.section == 14){
            UITableViewCell *emptyCell;
            emptyCell = [tableView dequeueReusableCellWithIdentifier:@"EmptyTableCell"];
            if (emptyCell == nil) {
                emptyCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EmptyTableCell"];
                emptyCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            emptyCell.textLabel.text = @"Send Error Logs";
            emptyCell.textLabel.textAlignment = NSTextAlignmentCenter;
            return emptyCell;
        }else if(indexPath.section == 15){
            UITableViewCell *emptyCell;
            emptyCell = [tableView dequeueReusableCellWithIdentifier:@"EmptyTableCell"];
            if (emptyCell == nil) {
                emptyCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EmptyTableCell"];
                emptyCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            emptyCell.textLabel.text = @"Send Upload Logs";
            emptyCell.textLabel.textAlignment = NSTextAlignmentCenter;
            return emptyCell;
        }else if (indexPath.section == 16) {
            SyncOverWifiViewCellTableViewCell *newCell = [tableView dequeueReusableCellWithIdentifier:@"SyncOverWifiViewCellTableViewCell"];
            //if (newCell == nil) {
            [[NSBundle mainBundle] loadNibNamed:@"SyncOverWifiViewCellTableViewCell" owner:self options:nil];
            newCell = syncOverWifiViewCellTableViewCell;
            newCell.toggleLabel.text = @"Background Upload";
            //newCell.detailsLabel.text = @"Collaborative Inspections requires a continuous data connection";
            //newCell.detailsLabel.hidden = YES;
            //newCell.detailsLabel.numberOfLines=2;
            newCell.detailsLabel.lineBreakMode = NSLineBreakByWordWrapping;
            if ([NSUserDefaultsManager getBOOLFromUserDeafults:enableBackgroundUploads]) {
                [newCell.syncOverWifiButton setOn:YES animated:NO];
            } else {
                [newCell.syncOverWifiButton setOn:NO animated:NO];
            }
            [newCell.syncOverWifiButton addTarget:self action:@selector(toggleBackgroundUploads:) forControlEvents:UIControlEventValueChanged];
            self.syncOverWifiViewCellTableViewCell = nil;
            //}
            return newCell;
        }
    }
    UITableViewCell *emptyCell;
    emptyCell = [tableView dequeueReusableCellWithIdentifier:@"EmptyTableCell"];
    if (emptyCell == nil) {
        emptyCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EmptyTableCell"];
        emptyCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return emptyCell;
}

-(void)sendCrashLogButtonTouched
{
    CrashLogHandler *crashHandler = [[CrashLogHandler alloc]init];
    NSString* crashLogs = [crashHandler getEmailText];
    NSLog(@"Crash Logs are: %@",[crashHandler getEmailText]);
    if([[DeviceManager getDeviceID] isEqualToString:@"iOS_Simulator"]){
        NSLog(@"Debug Log Email: \n %@",crashLogs);
        return;
    }
    
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setSubject:@"Insights Crash Log"];
    [controller setToRecipients:[NSArray arrayWithObjects:@"support@harvestmark.com", nil]];
    [controller setMessageBody:crashLogs isHTML:NO];
    //[controller addAttachmentData:data mimeType:@"db" fileName:@"offlineData"];
    if (controller) {
        [self presentModalViewController:controller animated:YES];
    }

}

-(void)sendUploadsLogButtonTouched
{
    UploadsLogHandler *crashHandler = [[UploadsLogHandler alloc]init];
    NSString* crashLogs = [crashHandler getEmailText];
    //NSLog(@"Upload Logs are: \n\n%@",[crashHandler getEmailText]);
    if([[DeviceManager getDeviceID] isEqualToString:@"iOS_Simulator"]){
        NSLog(@"Debug Log Email: \n %@",crashLogs);
        return;
    }
    
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setSubject:@"Insights Crash Log"];
    [controller setToRecipients:[NSArray arrayWithObjects:@"support@harvestmark.com", nil]];
    [controller setMessageBody:crashLogs isHTML:NO];
    //[controller addAttachmentData:data mimeType:@"db" fileName:@"offlineData"];
    if (controller) {
        [self presentModalViewController:controller animated:YES];
    }
    
}


#pragma mark - TableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![[User sharedUser] checkIfUserLoggedIn]) {
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                return 90.0;
            }
        } else if (indexPath.section == 1) {
            if (indexPath.row == 0) {
                return 45.0;
            }
        }
    } else if ([[User sharedUser] checkForRetailInsights] || [[User sharedUser] checkForScanOut]) {
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                return 90.0;
            }
        } else if (indexPath.section == 1) {
            if (indexPath.row == 0) {
                return 98.0;
            }
        } else if (indexPath.section == 2) {
            if (indexPath.row == 0) {
                return 98.0;
            }
        } else if (indexPath.section == 3) {
            if (indexPath.row == 0) {
                return 40.0;
            } else {
                return 35.0;
            }
        } else {
            return 35;
        }
    } else {
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                return 90.0;
            }
        } else if (indexPath.section == 1) {
            if (indexPath.row == 0) {
                return 98.0;
            }
        } else if (indexPath.section == 2) {
            if (indexPath.row == 0) {
                return 98.0;
            }
        } else if (indexPath.section == 3) {
            if (indexPath.row == 0) {
                return 139.0;
            }
        } else if (indexPath.section == 4) {
            if (indexPath.row == 0) {
                return 45.0;
            }
        } else if (indexPath.section == 5) {
            if (indexPath.row == 0) {
                return 40.0;
            } else {
                return 35.0;
            }
        } else if (indexPath.section == 12) {
            if (indexPath.row == 0) {
                return 85.0;
            }
        }else if (indexPath.section == 13) {
            if (indexPath.row == 0) {
                return 50.0;
            }
        }else if (indexPath.section == 14) {
            if (indexPath.row == 0) {
                return 60.0;
            }
        }else {
            return 35;
        }
    }
    return 20;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"IndexPath section is: %d",indexPath.section);
    if (![[User sharedUser] checkForRetailInsights] && ![[User sharedUser] checkForScanOut]) {
        if (indexPath.section == 10) {
            NSString *string = [self getAllTheRatingsNoMatterWhat];
            if([[DeviceManager getDeviceID] isEqualToString:@"iOS_Simulator"]){
                NSLog(@"Debug Log Email: \n %@",string);
                return;
            }
            MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
            controller.mailComposeDelegate = self;
            [controller setSubject:@"Debug Log"];
            [controller setToRecipients:[NSArray arrayWithObjects:@"arthur@ifooddecisionsciences.com", @"sjacob@ifooddecisionsciences.com", nil]];
            [controller setMessageBody:string isHTML:NO];
            NSLog(@"Debug Log Email: \n %@",string);
            //[controller addAttachmentData:data mimeType:@"db" fileName:@"offlineData"];
            if (controller) {
                [self presentModalViewController:controller animated:YES];
            }
        } else if (indexPath.section == 11) {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Warning: This will delete all the audits from the app." message:@"Do you still want to continue?"
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  otherButtonTitles:@"Ok", nil];
            [alert setTag:4];
            [alert show];
        }else if (indexPath.section == 14) {
            [self sendCrashLogButtonTouched];
        }else if (indexPath.section == 15) {
            [self sendUploadsLogButtonTouched];
        }
    } else {
        if (indexPath.section == 6) {
            NSString *string = [self getAllTheRatingsNoMatterWhat];
            MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
            controller.mailComposeDelegate = self;
            [controller setSubject:@"Debug Log"];
            [controller setToRecipients:[NSArray arrayWithObjects:@"arthur@ifooddecisionsciences.com", @"sjacob@ifooddecisionsciences.com", nil]];
            [controller setMessageBody:string isHTML:NO];
            //[controller addAttachmentData:data mimeType:@"db" fileName:@"offlineData"];
            if (controller) {
                [self presentModalViewController:controller animated:YES];
            }
        } else if (indexPath.section == 7) {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Warning: This will delete all the audits from the app." message:@"Do you still want to continue?"
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  otherButtonTitles:@"Ok", nil];
            [alert setTag:4];
            [alert show];
        }
    }
}

#pragma mark - Mail delegate

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    [self dismissModalViewControllerAnimated:YES];
}


- (NSString *) getAllTheRatingsNoMatterWhat {
    NSString *auditsString = @"";
    NSString *queryAllOfflineRatings = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%@'", TBL_COMPLETED_AUDITS, COL_DATA_SUBMITTED, CONST_FALSE];
    int count = 0;
    FMDatabase *databaseOfflineRatings = [[DBManager sharedDBManager] openDatabase:DB_OFFLINE_DATA];
    FMResultSet *resultsGroupRatings;
    [databaseOfflineRatings open];
    resultsGroupRatings = [databaseOfflineRatings executeQuery:queryAllOfflineRatings];
    while ([resultsGroupRatings next]) {
        count++;
        NSString *ratings = [resultsGroupRatings stringForColumn:COL_RATINGS];
        auditsString = [NSString stringWithFormat:@"%@\n\n%d : %@", auditsString, count, ratings];
    }
    [databaseOfflineRatings close];
    return auditsString;
}

- (void) deleteAllTheRowsFromTheOfflineTable {
    NSString *queryAllOfflineRatings = [NSString stringWithFormat:@"DELETE FROM %@", TBL_COMPLETED_AUDITS/*, COL_DATA_SUBMITTED, CONST_FALSE*/];
    FMDatabase *databaseOfflineRatings = [[DBManager sharedDBManager] openDatabase:DB_OFFLINE_DATA];
    [databaseOfflineRatings open];
    [databaseOfflineRatings executeUpdate:queryAllOfflineRatings];
    [databaseOfflineRatings close];
    [[[UIAlertView alloc] initWithTitle: @"Audits deleted" message:nil delegate: self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

- (void) testConnectionButtonTouched {
//    [[User sharedUser] logoutUser];
//    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void) clearLoginInfo {
    NSArray *savedInspections = [[User sharedUser] getAllSavedInspections];
    if ([savedInspections count] > 0) {
        [[[UIAlertView alloc] initWithTitle: @"Need to finish or cancel all inspections before logging out" message:nil delegate: self cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
    } else {
        [[User sharedUser] logoutUser];
        [[GIDSignIn sharedInstance] signOut];
        [self.navigationController popToRootViewControllerAnimated:YES];
        //[[[UIAlertView alloc] initWithTitle: @"If the person from your team doesnt log back in the next time, you will lose your data" message:nil delegate: self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil] show];
    }
}

//- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
//    if (buttonIndex == 0) {
//    } else {
//        [[User sharedUser] logoutUser];
//        [self.navigationController popToRootViewControllerAnimated:YES];
//    }
//}

- (void) syncOverWifiTouched:(id)sender {
    if (![[NSUserDefaultsManager getObjectFromUserDeafults:SyncOverWifiButtonSet] isEqualToString:@"SET"]) {
        [NSUserDefaultsManager saveObjectToUserDefaults:@"SET" withKey:SyncOverWifiButtonSet];
    }
    BOOL state = [sender isOn];
    if (state) {
        [NSUserDefaultsManager saveBOOLToUserDefaults:YES withKey:SyncOverWifi];
    } else {
        [NSUserDefaultsManager saveBOOLToUserDefaults:NO withKey:SyncOverWifi];
    }
}

- (void) toggleCollabInspections:(id)sender {
    //if (![[NSUserDefaultsManager getObjectFromUserDeafults:SyncOverWifiButtonSet] isEqualToString:@"SET"]) {
    //    [NSUserDefaultsManager saveObjectToUserDefaults:@"SET" withKey:SyncOverWifiButtonSet];
    //}
    BOOL state = [sender isOn];
    if (state) {
        [NSUserDefaultsManager saveBOOLToUserDefaults:YES withKey:colloborativeInspectionsEnabled];
        [[User sharedUser] initCollaborativeBackgroundUpload];
    } else {
        [NSUserDefaultsManager saveBOOLToUserDefaults:NO withKey:colloborativeInspectionsEnabled];
        //clear up collaborative inspections
        
    }
}

- (void) toggleDisableIncrementalSync:(id)sender {
    //if (![[NSUserDefaultsManager getObjectFromUserDeafults:SyncOverWifiButtonSet] isEqualToString:@"SET"]) {
    //    [NSUserDefaultsManager saveObjectToUserDefaults:@"SET" withKey:SyncOverWifiButtonSet];
    //}
    BOOL state = [sender isOn];
    if (state) {
        [NSUserDefaultsManager saveBOOLToUserDefaults:YES withKey:enableIncrementalSync];
    } else {
        [NSUserDefaultsManager saveBOOLToUserDefaults:NO withKey:enableIncrementalSync];
    }
}

- (void) toggleBackgroundUploads:(id)sender {
    //if (![[NSUserDefaultsManager getObjectFromUserDeafults:SyncOverWifiButtonSet] isEqualToString:@"SET"]) {
    //    [NSUserDefaultsManager saveObjectToUserDefaults:@"SET" withKey:SyncOverWifiButtonSet];
    //}
    BOOL state = [sender isOn];
    if (state) {
        [NSUserDefaultsManager saveBOOLToUserDefaults:YES withKey:enableBackgroundUploads];
        [[User sharedUser].backgroundUpload startBackgroundTimer];
    } else {
        [NSUserDefaultsManager saveBOOLToUserDefaults:NO withKey:enableBackgroundUploads];
        [[User sharedUser].backgroundUpload stopBackgroundTimer];
    }
}

- (void) syncNowTouched {
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    syncManager = [[SyncManager alloc] init];
    syncManager.delegate = self;
    //[self checkAppVersion]; //not used
    [self downloadOriginalData];
}

- (void) downloadProgress: (BOOL)success {
    if (success) {
        RatingAPI *ratingAPI = [[RatingAPI alloc] init];
        //[DefectAPI downloadImagesWithBlock:^(BOOL success) {
             [self updateAPIName:@"Processing"];
            [ratingAPI downloadImagesWithBlock:^(BOOL success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[User sharedUser] reportCurrentTime];
                    [[self delegate] downloadSyncDone:YES];
                    [self.settingsTable reloadData];
                    [self.syncOverlay removeProgressView];
                    [self.syncOverlay removeFromSuperview];
                    UIWindow *win = [[UIApplication sharedApplication] keyWindow];
                    SCLAlertView *alert = [[SCLAlertView alloc] init];
                    [alert addButton:@"Ok" actionBlock:^(void) {
                        NSLog(@"Ok button tapped");
                    }];
                    if(self.syncManager.failedImagesCount<=0)
                        [alert showSuccess:win.rootViewController title:@"Download Successful" subTitle:@"" closeButtonTitle:nil duration:0.0f];
                    else
                        [alert showSuccess:win.rootViewController title:@"Download Successful" subTitle:[NSString stringWithFormat:@"%d Images Failed to download. Please try again later", self.syncManager.failedImagesCount] closeButtonTitle:nil duration:0.0f];
                });
            }];
        //}];
        dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        });
    } else {
        [self.syncOverlay updateProgress];
    }
}

- (void) updateAPIName: (NSString *) apiName {
    dispatch_async(dispatch_get_main_queue(), ^{
    self.syncOverlay.apiDownloadedLabel.text = apiName;
    [self.syncOverlay setNeedsDisplay];
    });
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 2) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UpdateLink]];
    } else if (alertView.tag ==3) {
        if (buttonIndex == [alertView cancelButtonIndex]) {
            [self downloadOriginalData];
        }
    } else if(alertView.tag==4) {
        if (buttonIndex == alertView.firstOtherButtonIndex) {
            [self deleteAllTheRowsFromTheOfflineTable];
            self.pendingAuditsArray = [[User sharedUser] getAllPendingAudits];
            [self.settingsTable reloadData];
        }
    }
}

- (void) downloadFailed {
    [self.syncOverlay removeFromSuperview];
    //[[[UIAlertView alloc] initWithTitle:@"Sync Failed" message: @"Goto Settings and Sync again" delegate: self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    UIWindow *win = [[UIApplication sharedApplication] keyWindow];
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    [alert addButton:@"Ok" actionBlock:^(void) {
        NSLog(@"Ok button tapped");
    }];
    [alert showSuccess:win.rootViewController title:@"Sync Failed" subTitle:@"Goto Settings and Sync again" closeButtonTitle:nil duration:0.0f];
}

- (void) downloadFailed:(NSString*)failMessage {
    //[[[UIAlertView alloc] initWithTitle:@"Sync Failed" message: failMessage delegate: self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    [self.syncOverlay removeFromSuperview];
    [[[UIAlertView alloc] initWithTitle:@"Sync Failed" message: failMessage delegate: self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
//    UIWindow *win = [[UIApplication sharedApplication] keyWindow];
//    SCLAlertView *alert = [[SCLAlertView alloc] init];
//    [alert addButton:@"Ok" actionBlock:^(void) {
//        NSLog(@"Ok button tapped");
//    }];
//    [alert showNotice:win.rootViewController title:@"Sync Failed" subTitle:failMessage closeButtonTitle:nil duration:0.0f];
}

- (void) testConnectionDelegateTouched {
//    BOOL networkAvailable = [DeviceManager isConnectedToNetwork];
//    if (networkAvailable) {
//        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Network Availability"
//                                                          message:@"Available"
//                                                         delegate:nil
//                                                cancelButtonTitle:@"OK"
//                                                otherButtonTitles:nil];
//        
//        [message show];
//    } else {
//        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Network Availability"
//                                                          message:@"Not Available"
//                                                         delegate:nil
//                                                cancelButtonTitle:@"OK"
//                                                otherButtonTitles:nil];
//        
//        [message show];
//    }
    
    BOOL connectionAvailable = NO;
    NSString *endpoint = [NSUserDefaultsManager getObjectFromUserDeafults:PORTAL_ENDPOINT];
    NSString *connectionString;
    if ([NSUserDefaultsManager getBOOLFromUserDeafults:SyncOverWifi]) {
        connectionAvailable = [DeviceManager isConnectedToWifi];
        connectionString = @"Wifi connection not available, Manage connection in Settings";
    } else {
        connectionAvailable = [DeviceManager isConnectedToNetwork];
        connectionString = @"No connection available";
    }
    if(!connectionAvailable){
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Network Availability"
                                                          message:[NSString stringWithFormat:@"%@", connectionString]
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        
        [message show];
    } else {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Network Availability"
                                                          message:[NSString stringWithFormat:@"Available : \n Endpoint:%@",endpoint]
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        
        [message show];
    }
}

- (void) settingsInfoButtonTouched {
    NSString* openUDID = [OpenUDID value];
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    if ([[[User sharedUser] getAuditorRole] isEqualToString:AUDITOR_ROLE_SCANOUT] || [appName isEqualToString:@"Scan Out"]) {
        [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Scan Out %@ \n Device Id: %@ \n", [DeviceManager getCurrentVersionOfTheApp], openUDID] message:@"HarvestMark(c) 2020 is the food tracebility solution. Protected by US Patent 7,770,783 and others. International and other patents pending." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else if ([[[User sharedUser] getAuditorRole] isEqualToString:AUDITOR_ROLE_RETAIL] || [appName isEqualToString:@"Scan Out"]) {
        [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Retail-Insights %@ \n Device Id: %@ \n", [DeviceManager getCurrentVersionOfTheApp], openUDID] message:@"HarvestMark(c) 2020 is the food tracebility solution. Protected by US Patent 7,770,783 and others. International and other patents pending." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }else
    [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"DC Insights %@ \n Device Id: %@ \n", [DeviceManager getCurrentVersionOfTheApp], openUDID] message:@"HarvestMark(c) 2020 is the food tracebility solution. Protected by US Patent 7,770,783 and others. International and other patents pending." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

-(void)downloadOrderData{
    OrderDataAPI *orderDataHelper = [[OrderDataAPI alloc] init];
    UIWindow *win = [[UIApplication sharedApplication] keyWindow];
    self.syncOverlayView = [[SyncOverlayView alloc] initWithFrame:CGRectMake(0, 0, win.bounds.size.width, win.bounds.size.height)];
    self.syncOverlayView.headingTitleLabel.text = @"Downloading Order Data..";
    [win addSubview:self.syncOverlayView];
    
    [orderDataHelper orderDataCallwithAllTheBlocks:^(BOOL isSuccess, NSArray *array, NSError *error){
            if (!isSuccess) {
                [self showSimpleAlertWithMessage:[error localizedDescription] withTitle:@"Error"];
                DebugLog(@"\n Error: %@  \n", [error localizedDescription]);
                [self.syncOverlayView removeFromSuperview];//DSIN-4660
            } else {
                NSLog(@"posts %d Order data API", isSuccess);
                NSDate *dateLocal = [NSDate date];
                [NSUserDefaultsManager saveObjectToUserDefaults:dateLocal withKey:SyncOrderDataDownloadTime];
                if ([array count] > 0) {
                    [self orderDataDownloadComplete];
                } else {
                    [self orderDataMissing];
                }
                [self.settingsTable reloadData];
            }
    } withSyncOverlayView:self.syncOverlayView];
}


- (void) orderDataButtonTouched {
    //[super orderDataSyncButtonTouched];
    if([DeviceManager isConnectedBasedOnAppSettings]){
        [self initializeOrderDataTable];
        [self downloadOrderData];
    }
    else
        [self showSimpleAlertWithMessage:@"No Internet Connection Available" withTitle:@"Network Availability"];
}

- (NSDictionary *) processTheInfoForTheSyncHistoryTable: (Audit *) audit {
    NSMutableDictionary *mutableDict = [[NSMutableDictionary alloc] init];
    NSArray *toGetTheAuditId = [audit.auditData.audit.id componentsSeparatedByString:@"-"];
    if ([toGetTheAuditId count] > 2) {
        //NSLog(@"toGetTheAuditId %@", [toGetTheAuditId objectAtIndex:1]);
        NSString *auditId = [toGetTheAuditId objectAtIndex:1];
        [mutableDict setObject:auditId forKey:@"auditId"];
    }
    return mutableDict;
}

/*
-(void) downloadSyncDataTest {
    self.results = [[NSMutableArray alloc] init];
    [self callApi:Defects withPage:1];
}

-(void) callApi: (NSString*)apiName withPage:(int)pageNo {
    __block int pageNumber = pageNo;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        NSMutableDictionary *localStoreCallParamaters = [[self paramtersFortheGETCall] mutableCopy];
        [localStoreCallParamaters setObject:[NSString stringWithFormat:@"%d", pageNumber] forKey:@"page_number"];
        [localStoreCallParamaters setObject:[NSString stringWithFormat:@"%d", 50] forKey:@"page_size"];
        [[AFAppDotNetAPIClient sharedClient] getPath:apiName parameters:localStoreCallParamaters success:^(AFHTTPRequestOperation *operation, id JSON) {
            [self.results addObjectsFromArray:JSON];
            //NSLog(@"results is: %@", self.results);
            //if([JSON count]>0)
            //int countResults = self.pageNo * self.limit;
           
            if ([JSON count]>0) {
                 NSLog(@"Call %@ %d page %d", apiName, [self.results count], pageNumber);
                [self callApi:apiName withPage:++pageNumber];
            } else {
                 NSLog(@"ALL DONE");
                [self writeDataToFile:Defects withContents:self.results];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Failed");
        }];

    });
}

- (BOOL) writeDataToFile: (NSString *) fileName withContents:(id) JSON
{
    //applications Documents dirctory path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSError *error;
    BOOL success = NO;
    BOOL functionSuccess = NO;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:JSON
                                                       options:kNilOptions
                                                         error:&error];
    //attempt to download live data
    if (JSON)
    {
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,fileName];
        if([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            success = [fileManager removeItemAtPath:filePath error:NULL];
            if (success) {
                functionSuccess = [jsonData writeToFile:filePath atomically:YES];
            }
        } else {
            functionSuccess = [jsonData writeToFile:filePath atomically:YES];
        }
    }
    return functionSuccess;
    //copy data from initial package into the applications Documents folder
}
*/

- (NSDictionary *) paramtersFortheGETCall{
    //NSLog(@"[DeviceManager getDeviceID] %@", [DeviceManager getDeviceID]);
    //NSArray *values = @[@"sotJjiqygkNyPBostbu9", @"D8C2E73A-954A-4FE8-8BBE-0F5BFDC833DA"];
    NSArray *values;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"]) {
        values = @[[[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"], [DeviceManager getDeviceID]];
    }
    NSArray *keys = @[@"auth_token", DEVICE_ID];
    NSDictionary *parametersLocal;
    if (values && keys) {
        parametersLocal = [[NSDictionary alloc] initWithObjects:values forKeys:keys];
    }
    return parametersLocal;
}

- (void) checkAppVersion {
    UIWindow *win = [[UIApplication sharedApplication] keyWindow];
    self.syncOverlay = [[SyncOverlayView alloc] initWithFrame:CGRectMake(0, 0, win.bounds.size.width, win.bounds.size.height)];
    self.syncOverlay.headingTitleLabel.text = @"Checking app version";
    [self.syncOverlay showActivityView];
    [win addSubview:self.syncOverlay];
    [self.syncManager appUpdateCheckCall:^(BOOL appUpdateCheckCall, NSError *error){
        if (appUpdateCheckCall) {
            if ([[[NSUserDefaultsManager getObjectFromUserDeafults:UPDATEMETHOD] lowercaseString] isEqualToString:ForcedUpdateMethod]) {
                [self.syncOverlay removeFromSuperview];
                UIAlertView *alert = [[UIAlertView alloc] init];
                alert.tag = 2;
                [[alert initWithTitle:@"Update Required" message: @"Tap on this link to update" delegate: self cancelButtonTitle:@"Download Link" otherButtonTitles: nil] show];
            } else if ([[[NSUserDefaultsManager getObjectFromUserDeafults:UPDATEMETHOD] lowercaseString] isEqualToString:ManualUpdateMethod]) {
                [self.syncOverlay removeFromSuperview];
                UIAlertView *alert = [[UIAlertView alloc] init];
                alert.tag = 3;
                [[alert initWithTitle:@"Update Available" message: @"Tap on this buttons to either update or cancel" delegate: self cancelButtonTitle:@"Cancel" otherButtonTitles: @"Upgrade", nil] show];
            } else {
                [self.syncOverlay removeFromSuperview];
                [self downloadOriginalData];
            }
        } else {
            [self.syncOverlay removeFromSuperview];
            [self downloadOriginalData];
        }
        NSLog(@"appid %d", appUpdateCheckCall);
    }];
}

- (void) downloadOriginalData {
    BOOL connectionAvailable = NO;
    NSString *connectionString;
    if ([NSUserDefaultsManager getBOOLFromUserDeafults:SyncOverWifi]) {
        connectionAvailable = [DeviceManager isConnectedToWifi];
        connectionString = @"Wifi connection not available, Manage connection in Settings";
    } else {
        connectionAvailable = [DeviceManager isConnectedToNetwork];
        //connectionString = @"3G/4G/LTE connection not available, Manage connection in Settings";
        connectionString = @"No connection available";
    }
    if(!connectionAvailable){
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Sync Device"
                                                          message:[NSString stringWithFormat:@"%@", connectionString]
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        
        [message show];
    } else {
        UIWindow *win = [[UIApplication sharedApplication] keyWindow];
        self.syncOverlay = [[SyncOverlayView alloc] initWithFrame:CGRectMake(0, 0, win.bounds.size.width, win.bounds.size.height)];
        self.syncOverlay.headingTitleLabel.text = @"Downloading and Processing Data";
        [win addSubview:self.syncOverlay];
        
        
        syncManager = [[SyncManager alloc] init];
        syncManager.delegate = self;
        [syncManager prepareSQLDatabasesAndTables];
        [syncManager callAllTheAPIsAndProcessThem : NO];
    }
}


@end
