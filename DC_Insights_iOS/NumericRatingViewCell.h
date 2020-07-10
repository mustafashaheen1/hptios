//
//  NumericRatingViewCell.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/15/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewCell.h"

#define kNumericRatingViewCellReuseID @"NumericRatingViewCell"
#define kNumericRatingViewCellNIBFile @"NumericRatingViewCell"

@interface NumericRatingViewCell : BaseTableViewCell

@property (retain, nonatomic) IBOutlet UITextField *theAnswer;
@property (retain, nonatomic) IBOutlet UIToolbar *utilityButtonView;
@property (retain, nonatomic) IBOutlet UILabel *defaultLabel;
@property (retain, nonatomic) NumericRatingModel *numericRatingModel;
@property (retain, nonatomic) IBOutlet UIButton *unitsButton;
@property (retain, nonatomic) IBOutlet UIImageView *arrowImage;
@property (retain, nonatomic) NSString *allCodes;

- (IBAction) unitsButtonTouched:(id)sender;
- (NSString*) theAnswerAsStringForNumericRating;

@end
