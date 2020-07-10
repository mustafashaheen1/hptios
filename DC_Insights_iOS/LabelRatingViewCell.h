//
//  LabelRatingViewCell.h
//  Insights
//
//  Created by Vineet on 10/15/18.
//  Copyright © 2018 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseTableViewCell.h"
#import "ViewController.h"

#define kLabelRatingViewCellReuseID @"LabelRatingViewCell"
#define kLabelRatingViewCellNIBFile @"LabelRatingViewCell"

@interface LabelRatingViewCell : BaseTableViewCell

@property (retain, nonatomic) NSString *labelRatingText;
@property (weak, nonatomic) IBOutlet UILabel *labelRatingTextView;

+ (CGFloat) myCellHeight:(Rating*)theRating;
+ (CGFloat)myQuestionViewHeight:(Rating*)theRating;
+ (NSInteger)numberOfLinesForQuestion:(Rating*)theRating;

@end
