//
//  CellInputScan.h
//  DC_Insights_iOS
//
//  Created by John Gifford on 11/6/13.
//  Copyright (c) 2013 Yottamark. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InputScanViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UITextField *textInput;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
- (IBAction)scanButton:(id)sender;

@end
