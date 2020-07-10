//
//  CECodeDetailsExapndedView.h
//  Insights
//
//  Created by Vineet Pareek on 19/10/2016.
//  Copyright © 2016 Yottamark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CEEvent.h"

@interface CECodeDetailsExapndedView : UIView<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic,strong) UITableView* tableView;
@property (nonatomic,strong) CEEvent *event;

@end
