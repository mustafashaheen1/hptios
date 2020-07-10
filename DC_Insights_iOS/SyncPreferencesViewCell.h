//
//  SyncPreferencesViewCell.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/18/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SyncPreferencesViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIButton *checkboxSyncAutomatically;
@property (strong, nonatomic) IBOutlet UIButton *checkboxSyncOverWifi;
@property (strong, nonatomic) IBOutlet UIButton *syncNowButton;

- (void)refreshState;
- (IBAction)checkboxSyncOverWifiButton:(id)sender;
- (IBAction)checkboxSyncAutomaticallyButton:(id)sender;

@end
