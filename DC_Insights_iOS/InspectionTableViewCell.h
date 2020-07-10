//
//  InspectionTableViewCell.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/13/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewCell.h"

#define InspectionTableView @"InspectionTableViewCell"

@interface InspectionTableViewCell : BaseTableViewCell

@property (strong, nonatomic) IBOutlet UILabel *modifiedLabel;
@property (strong, nonatomic) IBOutlet UILabel *numberOfInspectionsLabel;
@property (strong, nonatomic) IBOutlet UILabel *inspectionNumberLabel;
@property (strong, nonatomic) IBOutlet UIView *roundedCornersView;

+ (CGFloat) myCellHeight;

@end
