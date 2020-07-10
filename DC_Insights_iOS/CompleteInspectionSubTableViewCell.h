//
//  CompleteInspectionSubTableViewCell.h
//  Insights
//
//  Created by Shyam Ashok on 1/2/15.
//  Copyright (c) 2015 Yottamark. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CompleteInspectionSubTableViewCell : UITableViewCell <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) UITableView *parentTableView;
@property (strong, nonatomic) NSArray *containersGLobalArray;

@end
