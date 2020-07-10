//
//  DateRatingViewCell.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/15/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewCell.h"

#define kDateRatingViewCellReuseID @"DateRatingViewCell"
#define kDateRatingViewCellNIBFile @"DateRatingViewCell"

@interface DateRatingViewCell : BaseTableViewCell {
    BOOL dateSetOnce;
}

@property (retain, nonatomic) IBOutlet UIView *monthView;
@property (retain, nonatomic) IBOutlet UILabel *monthLabel;
@property (retain, nonatomic) IBOutlet UIView *dayView;
@property (retain, nonatomic) IBOutlet UILabel *dayLabel;
@property (retain, nonatomic) IBOutlet UIView *yearView;
@property (retain, nonatomic) IBOutlet UILabel *yearLabel;
@property (retain, nonatomic) IBOutlet UILabel *slashOne;
@property (retain, nonatomic) IBOutlet UILabel *slashTwo;
@property (retain, nonatomic) IBOutlet UILabel *message;
@property (weak, nonatomic) IBOutlet UITextField *dateLabel;

@property (retain, nonatomic) IBOutlet UIView *datePickerView;
@property (retain, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (retain, nonatomic) IBOutlet UIToolbar *keyboardDoneButtonView;
@property (assign, nonatomic) BOOL datePickerViewPresent;

- (void)launchDatePicker;
- (IBAction)closePicker:(id)sender;
- (IBAction) launchPicker:(id)sender;
- (IBAction)clearPicker:(id)sender;

@end
