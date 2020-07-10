//
//  PriceRatingViewCell.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/15/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewCell.h"

#define kPriceRatingViewCellReuseID @"PriceRatingViewCell"
#define kPriceRatingViewCellNIBFile @"PriceRatingViewCell"

@interface PriceRatingViewCell : BaseTableViewCell

@property (retain, nonatomic) IBOutlet UITextField *theAnswerTextField;
@property (retain, nonatomic) IBOutlet UIToolbar *utilityButtonView;
@property (retain, nonatomic) IBOutlet UILabel *defaultLabel;
@property (retain, nonatomic) IBOutlet UIButton *unitsButton;

- (IBAction) unitsButtonTouched:(id)sender;
- (NSString*)theAnswerAsStringForNumericAndPriceRating;

@end
