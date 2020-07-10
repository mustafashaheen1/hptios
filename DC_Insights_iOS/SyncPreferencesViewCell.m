//
//  SyncPreferencesViewCell.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/18/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "SyncPreferencesViewCell.h"

@implementation SyncPreferencesViewCell

@synthesize checkboxSyncAutomatically;
@synthesize checkboxSyncOverWifi;
@synthesize syncNowButton;

- (id)init
{
	self = [super init];
	if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
	
	return self;
}

- (void) configureFonts {
    self.syncNowButton.layer.cornerRadius = 5.0;
}

- (void)refreshState {
    [self configureFonts];
}

- (IBAction)checkboxSyncOverWifiButton:(id)sender {
    self.checkboxSyncOverWifi.selected = !self.checkboxSyncOverWifi.selected;
    
    if (self.checkboxSyncOverWifi.selected) {
        [self.checkboxSyncOverWifi setImage:[UIImage imageNamed:@"checkBoxMarked.png"] forState:UIControlStateSelected];
    }
    else {
        [self.checkboxSyncOverWifi setImage:[UIImage imageNamed:@"checkBox.png"] forState:UIControlStateSelected];
    }
}

- (IBAction)checkboxSyncAutomaticallyButton:(id)sender {
    self.checkboxSyncAutomatically.selected = !self.checkboxSyncAutomatically.selected;
    
    if (self.checkboxSyncAutomatically.selected) {
        [self.checkboxSyncAutomatically setImage:[UIImage imageNamed:@"checkBoxMarked.png"] forState:UIControlStateSelected];
    }
    else {
        [self.checkboxSyncAutomatically setImage:[UIImage imageNamed:@"checkBox.png"] forState:UIControlStateSelected];
    }
}

@end
