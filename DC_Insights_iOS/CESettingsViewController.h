//
//  CESettingsViewController.h
//  Insights
//
//  Created by Vineet Pareek on 20/10/2016.
//  Copyright © 2016 Yottamark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParentNavigationViewController.h"


@interface CESettingsViewController : ParentNavigationViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSMutableArray *viewList;

- (void) testConnectionButtonTouched;

@end
