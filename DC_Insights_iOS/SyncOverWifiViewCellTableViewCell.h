//
//  SyncOverWifiViewCellTableViewCell.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 6/2/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SyncOverWifiViewCellTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UISwitch *syncOverWifiButton;

- (IBAction)eventValueChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *toggleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailsLabel;

@end
