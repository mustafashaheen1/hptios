//
//  BooleanRatingOptionView.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/17/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "BooleanRatingOptionView.h"

#import "UIFont+UIFont_DCInsights.h"
#import "UIColor+UIColor_DCInsights.h"

#import "Constants.h"

@implementation BooleanRatingOptionView

@synthesize optionImage;
@synthesize optionLabel;
@synthesize optionNumber;
@synthesize delegate;

#pragma mark - Memory Management

- (void)dealloc
{
    self.delegate = nil;
}

- (void)configureFonts
{
    optionLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0];
    optionLabel.textColor = [UIColor colorWithHex:0x5f5b54];
}

- (IBAction)optionTouched:(id)sender
{
    if (delegate) {
        [delegate booleanRatingOptionTouched:optionNumber];
    }
}



@end
