//
//  LabelRatingViewCell.m
//  Insights
//
//  Created by Vineet on 10/15/18.
//  Copyright © 2018 Yottamark. All rights reserved.
//

#import "LabelRatingViewCell.h"

@implementation LabelRatingViewCell

@synthesize labelRatingText;

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.labelRatingText = @"";
    }
    
    return self;
}

+ (CGFloat) myCellHeight:(Rating*)theRating
{
    CGFloat questionViewHeight = [LabelRatingViewCell myQuestionViewHeight:theRating];
    return (70 + questionViewHeight);
}

#pragma mark - Refresh state Method

- (void) addAdditionalButtons {
    [super addAdditionalButtons];
}

- (void)refreshState
{
    [super refreshState];
    [self addAdditionalButtons];
    self.labelRatingText = self.rating.displayName;
    self.theQuestion.hidden = YES;
    self.theAnswerView.hidden = YES;
    self.labelRatingTextView.text = self.labelRatingText;
    self.labelRatingTextView.numberOfLines = 0;
    self.labelRatingTextView.lineBreakMode = NSLineBreakByWordWrapping;
    [self.labelRatingTextView sizeToFit];//top align the text
    [self configureFonts];
}

- (void)configureFonts
{
    [super configureFonts];
    self.labelRatingTextView.font = [UIFont fontWithName:@"Helvetica-Bold" size:15.0];
    self.labelRatingTextView.textColor = [UIColor colorWithHex:0x5f5b54];
}

- (BOOL)validate
{
    return [super validate];
}

- (NSString*)theAnswerAsString
{
    return @" "; //no result needed for label rating
}

+ (CGFloat)myQuestionViewHeight:(Rating*)rating
{
    NSInteger numberOfLinesForQuestion = [LabelRatingViewCell numberOfLinesForQuestion:rating];
    return (kQuestionLabelYOffset + (kQuestionLabelHeight * numberOfLinesForQuestion));
}

+ (NSInteger)numberOfLinesForQuestion:(Rating*)rating {
    NSString *theQuestionText = rating.displayName;
    
    CGSize baselineSize;
    baselineSize = [@"DCInsights" sizeWithFont:[UIFont fontWithName:@"Helvetica" size:14.0] constrainedToSize:CGSizeMake(250.0, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    
    CGSize theQuestionSize;
    theQuestionSize = [theQuestionText sizeWithFont:[UIFont fontWithName:@"Helvetica" size:14.0] constrainedToSize:CGSizeMake(250.0, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    
    NSInteger numberOfLines = (theQuestionSize.height / baselineSize.height);
    return numberOfLines;
}

@end
