//
//  ComboBoxRatingViewCell.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/15/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "ComboBoxRatingViewCell.h"

#import "UIFont+UIFont_DCInsights.h"
#import "UIColor+UIColor_DCInsights.h"

#import "ComboBoxOptionView.h"
#import "Constants.h"

@implementation ComboBoxRatingViewCell

@synthesize optionsView;
@synthesize anOptionView;
@synthesize optionSelectedState;

#pragma mark - Initialization

- (id)init
{
	self = [super init];
	if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
	
	return self;
}

+ (CGFloat) myCellHeight:(Rating*)theRating
{
    CGFloat questionViewHeight = [BaseTableViewCell myQuestionViewHeight:theRating];
    
    CGSize baselineSize;
    baselineSize = [@"DCInsights" sizeWithFont:[UIFont fontWithName:@"Helvetica" size:14.0] constrainedToSize:CGSizeMake(220.0, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    
    CGFloat optionsViewHeight = 0.0;
    
    NSInteger numberOfOptions = [theRating.options count];
    
    for (int i = 0; i < numberOfOptions; i++) {
        NSString *optionText = [theRating.options objectAtIndex:i];
        CGSize optionSize;
        optionSize = [optionText sizeWithFont:[UIFont fontWithName:@"Helvetica" size:14.0] constrainedToSize:CGSizeMake(220.0, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
        
        NSInteger numberOfLines = (optionSize.height / baselineSize.height);
        NSInteger optionHeight = 8 + (baselineSize.height * numberOfLines);
        optionsViewHeight += optionHeight;
    }
    
    CGFloat answerViewHeight;
    answerViewHeight = optionsViewHeight + 13;
    
	return (questionViewHeight + answerViewHeight);
}

#pragma mark - Memory Management


- (void)dealloc
{
    self.optionSelectedState = nil;
}


#pragma mark - Refresh state Method

- (void) addAdditionalButtons {
    [super addAdditionalButtons];
}

- (void)configureFonts
{
    [super configureFonts];
    
    fontsSet = YES;
}

- (void)refreshState
{
    [super refreshState];
    [self addAdditionalButtons];
    
    if (!fontsSet) {
        [self configureFonts];
    }
    
    if (self.rating && self.rating.options) {
        
        NSInteger numberOfOptions = [self.rating.options count];
        
        if (!optionSelectedState) {
            optionSelectedState = [[NSMutableArray alloc] initWithCapacity:numberOfOptions];
            for (int i = 0; i < numberOfOptions; i++) {
                NSString *noAsString = [NSString stringWithFormat:@"%d", 0];
                [optionSelectedState insertObject:noAsString atIndex:i];
            }
        }
        
        if (!optionsViewInitialized) {
            CGFloat optionsViewHeight = 0.0;
            
            optionsViewHeight = [self calculateOptionsViewsHeight:optionsViewHeight withNumberOfOptions:numberOfOptions];
            
            optionsView.frame = CGRectMake(0, 0, 320, optionsViewHeight);
            
            CGRect origAnswerViewFrame = self.theAnswerView.frame;
            self.theAnswerView.frame = CGRectMake(origAnswerViewFrame.origin.x, origAnswerViewFrame.origin.y, origAnswerViewFrame.size.width, optionsView.frame.size.height + 18);
            
            optionsViewInitialized = YES;
        }
        
        for (int i = 0; i < numberOfOptions; i++) {
            ComboBoxOptionView *optionView = (ComboBoxOptionView*)[[optionsView subviews] objectAtIndex:i];
            
            BOOL isSelected = [[optionSelectedState objectAtIndex:i] boolValue];
            
            if (isSelected) {
                optionView.optionImage.image = [UIImage imageNamed:@"radio_button_selected"];
            } else {
                optionView.optionImage.image = [UIImage imageNamed:@"radio_button_empty"];
            }
        }
    }
}

- (CGFloat) calculateOptionsViewsHeight: (CGFloat) optionsViewHeight withNumberOfOptions: (NSInteger) numberOfOptions {
    for (int i = 0; i < numberOfOptions; i++) {
        ComboBoxOptionView *optionView;
        [[NSBundle mainBundle] loadNibNamed:@"ComboBoxOptionView" owner:self options:nil];
        optionView = anOptionView;
        self.anOptionView = nil;
        
        [optionView setDelegate:self];
        optionView.optionNumber = i;
        [optionView configureFonts];
        
        CGSize baselineSize = [@"Shopwell" sizeWithFont:optionView.optionLabel.font constrainedToSize:CGSizeMake(220.0, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
        
        NSString *optionText = [self.rating.options objectAtIndex:i];
        CGSize optionSize = [optionText sizeWithFont:optionView.optionLabel.font constrainedToSize:CGSizeMake(220.0, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
        NSInteger numberOfLines = (optionSize.height / baselineSize.height);
        
        optionView.optionLabel.text = optionText;
        if (numberOfLines > 1) {
            optionView.optionLabel.numberOfLines = numberOfLines;
            CGRect origFrame = optionView.optionLabel.frame;
            optionView.optionLabel.frame = CGRectMake(origFrame.origin.x, origFrame.origin.y-3, origFrame.size.width, 6 + (baselineSize.height * numberOfLines));
        }
        
        NSInteger optionHeight = 8 + (baselineSize.height * numberOfLines);
        [self.optionsView addSubview:optionView];
        optionView.frame = CGRectMake(0, optionsViewHeight, 320, optionHeight);
        
        optionsViewHeight += optionHeight;
    }
    // if there is an "other" option, add a UITextView
    return optionsViewHeight;
}

- (BOOL)validate
{
    return [super validate];
}


- (NSString*)theAnswerAsString
{
    NSString *theAnswer = @"";
    
    BOOL isFirst = YES;
    NSMutableArray *optionsArray = [[NSMutableArray alloc] init];
    [optionsArray addObjectsFromArray:self.rating.options];
    for (int i = 0; i < [optionsArray count]; i++) {
        BOOL currentSelectedState = [[optionSelectedState objectAtIndex:i] boolValue];
        if (currentSelectedState) {
            NSString *optionValue = [optionsArray objectAtIndex:i];
            if (isFirst) {
                isFirst = NO;
                theAnswer = [theAnswer stringByAppendingString:optionValue];
            } else {
                theAnswer = [theAnswer stringByAppendingFormat:@"|%@", optionValue];
            }
        }
    }
    return theAnswer;
}

#pragma mark - protocol ComboBoxOptionProtocol


- (void)comboBoxOptionTouched:(NSInteger)optionNumber
{
    if (self.rating && self.rating.options) {
        
        // Only one option selected at a time
        NSMutableArray *optionsArray = [[NSMutableArray alloc] init];
        [optionsArray addObjectsFromArray:self.rating.options];
        for (int i = 0; i < [optionsArray count]; i++) {
            NSString *updatedStateAsString = [NSString stringWithFormat:@"%d", 0];
            if (i == optionNumber) {
                updatedStateAsString = [NSString stringWithFormat:@"%d", 1];
            }
            [optionSelectedState replaceObjectAtIndex:i withObject:updatedStateAsString];
        }
        
        [self refreshState];
        
        if (validatedOnce) {
            [self validate];
        }
    }
}

#pragma mark - TableView



/*------------------------------------------------------------------------------
 METHOD: prepareForReuse
 
 PURPOSE:
 Reset the state of the cell to be used for a search result item.
 -----------------------------------------------------------------------------*/
- (void)prepareForReuse
{
	[super prepareForReuse];
}


@end
