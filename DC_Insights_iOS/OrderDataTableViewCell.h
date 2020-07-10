//
//  OrderDataTableViewCell.h
//  DC Insights
//
//  Created by Shyam Ashok on 8/4/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIPopoverListView.h"

@interface OrderDataTableViewCell : UITableViewCell <UIPopoverListViewDelegate, UIPopoverListViewDataSource>

@property (strong, nonatomic) IBOutlet UIButton *daysBeforeButton;
@property (strong, nonatomic) IBOutlet UIButton *daysAfterButton;
@property (strong, nonatomic) IBOutlet UIButton *downloadButton;
@property (strong, nonatomic) NSArray *days;
@property (assign, nonatomic) BOOL daysBefore;

- (IBAction)daysBeforeButtonTouched:(id)sender;
- (IBAction)daysAfterButtonTouched:(id)sender;
- (void) refreshState;

@end
