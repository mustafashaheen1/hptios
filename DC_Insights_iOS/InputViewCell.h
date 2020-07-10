//
//  CellInput.h
//  DC_Insights_iOS
//
//  Created by John Gifford on 11/6/13.
//  Copyright (c) 2013 Yottamark. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InputViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UITextField *inputTextField;

@end