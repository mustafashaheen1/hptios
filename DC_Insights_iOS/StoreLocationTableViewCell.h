//
//  StoreLocationTableViewCell.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/7/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewCell.h"

#define StoreLocationTableView @"StoreLocationTableViewCell"

@interface StoreLocationTableViewCell : BaseTableViewCell

@property (strong, nonatomic) IBOutlet UILabel *storeName;
@property (strong, nonatomic) IBOutlet UILabel *storeAddress;
@property (strong, nonatomic) IBOutlet UIView *roundedCornersView;
@property (strong, nonatomic) IBOutlet UILabel *distance;

+ (CGFloat) myCellHeight;

@end
