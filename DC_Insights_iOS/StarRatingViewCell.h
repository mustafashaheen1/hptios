//
//  ProductRatingHeaderTableViewCell.h
//  DC_Insights_iOS
//
//  Created by John Gifford on 11/12/13.
//  Copyright (c) 2013 Yottamark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewCell.h"
#import "ASStarRatingView.h"

#define kStarRatingViewCellReuseID @"StarRatingViewCell"
#define kStarRatingViewCellNIBFile @"StarRatingViewCell"

@interface StarRatingViewCell : BaseTableViewCell <ASStarRatingViewProtocol>

@property (strong, nonatomic) IBOutlet UIButton *cameraButton;
@property (strong, nonatomic) IBOutlet UILabel *productNameLabel;
@property (strong, nonatomic) IBOutlet ASStarRatingView *starRatingView;
@property (strong, nonatomic) IBOutlet UILabel *selectedStarLabel;

@end
