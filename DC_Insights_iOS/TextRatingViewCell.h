//
//  TextRatingViewCell.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/15/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewCell.h"
#import "ViewController.h"

#define kTextRatingViewCellReuseID @"TextRatingViewCell"
#define kTextRatingViewCellNIBFile @"TextRatingViewCell"

@interface TextRatingViewCell : BaseTableViewCell

@property (weak, nonatomic) IBOutlet UITextView *theAnswer;
@property (retain, nonatomic) NSString *allCodes;
@property (retain, nonatomic) IBOutlet UIToolbar *utilityButtonView;
@property (retain, nonatomic) IBOutlet UILabel *defaultLabel;

@end
