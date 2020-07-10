//
//  CEHistoryViewController.h
//  Insights
//
//  Created by Vineet Pareek on 19/10/2016.
//  Copyright © 2016 Yottamark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParentNavigationViewController.h"
#import "CEHistory.h"
#import "CEHistoryList.h"

@interface CEHistoryViewController : ParentNavigationViewController<UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property CEHistoryList *allHistory;

@end
