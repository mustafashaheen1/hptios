//
//  ProductRatingHeaderTableViewCell.m
//  DC_Insights_iOS
//
//  Created by John Gifford on 11/12/13.
//  Copyright (c) 2013 Yottamark. All rights reserved.
//

#import "StarRatingViewCell.h"

@implementation StarRatingViewCell

@synthesize starRatingView;
@synthesize selectedStarLabel;

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
    return (70 + questionViewHeight);
}

#pragma mark - TableViewCell Methods


#pragma mark - Refresh state Method

- (void)configureFonts
{
    [super configureFonts];
    
    fontsSet = YES;
}

- (void) addAdditionalButtons {
    [super addAdditionalButtons];
}

- (void)refreshState
{
    [super refreshState];
    [self addAdditionalButtons];
    self.cellTitle = @"starRatingView";

    if (!fontsSet) {
        [self configureFonts];
    }
    
    starRatingView.delegate = self;
    starRatingView.canEdit = YES;
    starRatingView.maxRating = [self.rating.content.star_items count];
    
    
    //NSLog(@"programnname is %@", [[NSUserDefaultsManager getObjectFromUserDeafults:selectedProgramName] lowercaseString]);
    if(DEFAULT_STAR_RATING_ENABLED && self.rating.default_star!= 0) {
        starRatingView.rating = self.rating.default_star;
        if ([self.rating.content.star_items count] > self.rating.default_star-1) {
            StarRatingModel *starRatingModel = [self.rating.content.star_items objectAtIndex:self.rating.default_star-1];
            self.selectedStarLabel.text = starRatingModel.label;
        }
    }
    
    /* -- Remove hardcoded Star Rating for ALDI
    if ([[[NSUserDefaultsManager getObjectFromUserDeafults:selectedProgramName] lowercaseString] isEqualToString:@"aldi"]) {
        starRatingView.rating = 4;
        if ([self.rating.content.star_items count] > 3) {
            StarRatingModel *starRatingModel = [self.rating.content.star_items objectAtIndex:3];
            self.selectedStarLabel.text = starRatingModel.label;
        }
    }
    */
    if (self.rating.ratingAnswerFromUI) {
        float starSetValue = [self.rating.ratingAnswerFromUI floatValue];
        starRatingView.rating = starSetValue;
        //DI-2017 - update the label content if rating was saved previously
        //StarRatingModel *starRatingModel = [self.rating.content.star_items objectAtIndex:starSetValue-1];
        if ([self.rating.content.star_items count] > starSetValue-1) {
            StarRatingModel *starRatingModel = [self.rating.content.star_items objectAtIndex:starSetValue-1];
            self.selectedStarLabel.text = starRatingModel.label;
        }
        //self.selectedStarLabel.text = starRatingModel.label;
    }
    
}



- (BOOL)validate
{
    return [super validate];
}


- (NSString*)theAnswerAsString
{
    if (starRatingView.rating > 0) {
        return [NSString stringWithFormat:@"%.0f", starRatingView.rating];
    }
    
    return nil;
}

- (void) scannableButtonTouched {

}

#pragma mark - protocol ASStarRatingViewProtocol


- (void)ratingChanged
{
    if ([self.rating.content.star_items count] > 0) {
        int ratingValue = (int)floor(starRatingView.rating - 1.0);
        if ([self.rating.content.star_items count] >= ratingValue && ratingValue >= 0) {
            NSLog(@"rating Value %d", ratingValue);
            StarRatingModel *star = [self.rating.content.star_items objectAtIndex:ratingValue];
            self.selectedStarLabel.text = star.label;
        }
    }
    int ratingValue = (int)floor(starRatingView.rating - 1.0);
    [self highlightDefectsButton:ratingValue];
    if (validatedOnce) {
        [self validate];
    }
}


- (NSString*)theAnswerAsStringForNumericRating
{
    return @"";
}

- (NSString*)theAnswerAsStringForNumericAndPriceRating
{
    return @"";
}

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
