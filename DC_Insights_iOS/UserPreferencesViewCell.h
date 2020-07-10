//
//  UserPreferencesViewCell.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/20/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserPreferencesViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIButton *clearLoginInfoButton;

- (void)refreshState;

@end
