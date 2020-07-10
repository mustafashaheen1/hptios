//
//  SyncOverWifiViewCellTableViewCell.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 6/2/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "SyncOverWifiViewCellTableViewCell.h"
#import "NSUserDefaultsManager.h"
#import "Constants.h"   

@implementation SyncOverWifiViewCellTableViewCell

@synthesize syncOverWifiButton;

- (id)init
{
	self = [super init];
	if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
	
	return self;
}

- (void)awakeFromNib
{
   // NSLog(@"code starts htrer");
    self.detailsLabel.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)eventValueChanged:(id)sender {
    BOOL state = [sender isOn];
    if (state) {
        [NSUserDefaultsManager saveBOOLToUserDefaults:YES withKey:SyncOverWifi];
    } else {
        [NSUserDefaultsManager saveBOOLToUserDefaults:NO withKey:SyncOverWifi];
    }
}

@end
