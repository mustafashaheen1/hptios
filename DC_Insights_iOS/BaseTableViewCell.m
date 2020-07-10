
//  BaseTableViewCell.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/13/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "BaseTableViewCell.h"
#import "StarQualityViewController.h"
#import "AppDelegate.h"

#define widthForButtons 40

@implementation BaseTableViewCell

@synthesize questionNumber;
@synthesize theQuestion;
@synthesize theQuestionView;
@synthesize theAnswerView;
@synthesize rating;
@synthesize myTableView;
@synthesize myTableViewController;
@synthesize checklistButton;
@synthesize cellTitle;
@synthesize scannableButton;
@synthesize unitsLabel;

#pragma mark - Initialization

- (id)init
{
	self = [super init];
	if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        fontsSet = NO;
    }
	
	return self;
}

+ (CGFloat) myCellHeight:(Rating*)theRating
{
	return 96.0;
}

+ (CGFloat)myQuestionViewHeight:(Rating*)theRating
{
    NSInteger numberOfLinesForQuestion = [BaseTableViewCell numberOfLinesForQuestion:theRating];
    return (kQuestionLabelYOffset + (kQuestionLabelHeight * numberOfLinesForQuestion));
}

+ (NSInteger)numberOfLinesForQuestion:(Rating*)theRating {
    NSString *theQuestionText = theRating.name;
    
    CGSize baselineSize;
    baselineSize = [@"DCInsights" sizeWithFont:[UIFont fontWithName:@"Helvetica" size:14.0] constrainedToSize:CGSizeMake(250.0, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    
    CGSize theQuestionSize;
    theQuestionSize = [theQuestionText sizeWithFont:[UIFont fontWithName:@"Helvetica" size:14.0] constrainedToSize:CGSizeMake(250.0, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    
    NSInteger numberOfLines = (theQuestionSize.height / baselineSize.height);
    return numberOfLines;
}


#pragma mark - Configuration


- (void) setRating:(Rating *)newRating
{
	if (newRating != rating) {
		if (newRating != nil) {
			rating = newRating;
			[self refreshState];
		} else {
			rating = nil;
		}
	}
}

#pragma mark - TO BE implemented by subclasses

- (void) addAdditionalButtons {
    self.scannableButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.scannableButton addTarget:self action:@selector(scannableButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    self.scannableButton.frame = CGRectMake(self.frame.size.width - widthForButtons - widthForButtons - 20, 5, widthForButtons, 41);
    //self.scannableButton.backgroundColor = [UIColor grayColor];
    [self.scannableButton setBackgroundImage:[UIImage imageNamed:@"ic_barcode.png"] forState:UIControlStateNormal];
    [self.scannableButton setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self.scannableButton setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
    [self.scannableButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];

    self.checklistButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.checklistButton addTarget:self action:@selector(checklistButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    self.checklistButton.frame = CGRectMake(self.frame.size.width - widthForButtons - 10, 5, widthForButtons, 41);
    //self.checklistButton.backgroundColor = [UIColor grayColor];
    [self.checklistButton setBackgroundImage:[UIImage imageNamed:@"ic_storage.png"] forState:UIControlStateNormal];
    if ([self.rating.defectsFromUI count] > 0) {
        [self.checklistButton setBackgroundImage:[UIImage imageNamed:@"ic_storage_checked.png"] forState:UIControlStateNormal];
    }
    [self.checklistButton setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self.checklistButton setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
    [self.checklistButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];

    self.helpButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.helpButton addTarget:self action:@selector(helpButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    self.helpButton.frame = CGRectMake(self.frame.size.width - widthForButtons - widthForButtons - widthForButtons - 30, 5, widthForButtons, 41);
    //self.helpButton.backgroundColor = [UIColor grayColor];
    [self.helpButton setBackgroundImage:[UIImage imageNamed:@"ic_info.png"] forState:UIControlStateNormal];
    [self.helpButton setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self.helpButton setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
    [self.helpButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    
    if ([self.rating.defectsIdList count] > 0) {
        [self addSubview:self.checklistButton];
//        NSInteger defectThreshold = self.rating.pictureAndDefectThresholds.defects;
//        if(defectThreshold > 0){
//            [self.checklistButton setBackgroundImage:[UIImage imageNamed:@"ic_storage_red.png"] forState:UIControlStateNormal];
//        }
        if (self.rating.optionalSettings.scannable) {
            if ([self.rating.type isEqualToString:TEXT_RATING] || [self.rating.type isEqualToString:NUMERIC_RATING] || [self.rating.type isEqualToString:PRICE_RATING]) {
                [self addSubview:self.scannableButton];
            }
        }
    
        if ([self.rating.type isEqualToString:STAR_RATING]) {
            int imageUrlsCount = 0;
            for (StarRatingModel *starModel in self.rating.content.star_items) {
                Image *image = [[Image alloc] init];
                image.deviceUrl = [NSString stringWithFormat:@"starRating_%d_%d.jpg", self.rating.ratingID, starModel.starRatingID];
                if ([image getImageFromDeviceUrl]) {
                    imageUrlsCount++;
                }
            }
            if (imageUrlsCount > 0) {
                [self addSubview:self.helpButton];
                self.helpButton.frame = CGRectMake(self.frame.size.width - widthForButtons - widthForButtons - 20, 5, widthForButtons, 41);
            }
        }
    } else {
        if (self.rating.optionalSettings.scannable) {
            if ([self.rating.type isEqualToString:TEXT_RATING] || [self.rating.type isEqualToString:NUMERIC_RATING] || [self.rating.type isEqualToString:PRICE_RATING]) {
                self.scannableButton.frame = CGRectMake(self.frame.size.width - widthForButtons - 10, 5, widthForButtons, 41);
                [self addSubview:self.scannableButton];
            }
        }
        if ([self.rating.type isEqualToString:STAR_RATING]) {
            int imageUrlsCount = 0;
            for (StarRatingModel *starModel in self.rating.content.star_items) {
                Image *image = [[Image alloc] init];
                image.deviceUrl = [NSString stringWithFormat:@"starRating_%d_%d.jpg", self.rating.ratingID, starModel.starRatingID];
                if ([image getImageFromDeviceUrl]) {
                    imageUrlsCount++;
                }
            }
            if (imageUrlsCount > 0) {
                self.helpButton.frame = CGRectMake(self.frame.size.width - widthForButtons - widthForButtons - 20, 5, widthForButtons, 41);
                [self addSubview:self.helpButton];
                if (!self.rating.optionalSettings.scannable) {
                    self.helpButton.frame = CGRectMake(self.frame.size.width - widthForButtons - 10, 5, widthForButtons, 41);
                }
            }
        }
    }
    
    if ([self.rating.defectsIdList count] == 0 && !self.rating.optionalSettings.scannable && ![self.rating.type isEqualToString:STAR_RATING]) {
        theQuestion.frame = CGRectMake(theQuestion.frame.origin.x, theQuestion.frame.origin.y, theQuestion.frame.size.width + 60, theQuestion.frame.size.height);
    }
    if ([self.rating.type isEqualToString:PRICE_RATING]) {
        self.checklistButton.hidden = NO;
    }
}

- (void) scannableButtonTouched {
    [self postNotificationToRemoveUtilityView];
}

- (void) helpButtonTouched {
    [self postNotificationToRemoveUtilityView];
    if ([self.rating.type isEqualToString:STAR_RATING]) {
        int imageUrlsCount = 0;
        for (StarRatingModel *starModel in self.rating.content.star_items) {
            Image *image = [[Image alloc] init];
            image.deviceUrl = [NSString stringWithFormat:@"starRating_%d_%d.jpg", self.rating.ratingID, starModel.starRatingID];
            if ([image getImageFromDeviceUrl]) {
                imageUrlsCount++;
            }
        }
        if (imageUrlsCount > 0) {
            StarQualityViewController *starQualityViewController = [[StarQualityViewController alloc] initWithNibName:@"StarQualityViewController" bundle:nil];
            starQualityViewController.rating = self.rating;
            if (myTableViewController.navigationController) {
                [myTableViewController.navigationController pushViewController:starQualityViewController animated:YES];
            } else {
                id appDelegate = [[UIApplication sharedApplication] delegate];
                AppDelegate *appDel = (AppDelegate *)appDelegate;
                [appDel.navigationController pushViewController:starQualityViewController animated:YES];
            }
        } else {
            [[[UIAlertView alloc] initWithTitle:@"No star rating manual present" message: @"" delegate: self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        }
    }
}

//highlight defects icon in red if selected rating is below the defect threshold
-(void)highlightDefectsButton:(int)currentStarRating{
    if(!self.rating || !self.rating.pictureAndDefectThresholds || !self.rating.pictureAndDefectThresholds.defects)
        return;
    
    NSInteger defectThreshold = self.rating.pictureAndDefectThresholds.defects;
    if(defectThreshold > 0 && (currentStarRating+1) <=defectThreshold){
        [self.checklistButton setBackgroundImage:[UIImage imageNamed:@"ic_storage_red.png"] forState:UIControlStateNormal];
    }else{
        [self.checklistButton setBackgroundImage:[UIImage imageNamed:@"ic_storage.png"] forState:UIControlStateNormal];
    }
}

- (void) checklistButtonTouched {
    [self postNotificationToRemoveUtilityView];
    NSArray *ratingDefects;
    if ([self.rating.defectsFromUI count] > 0) {
        ratingDefects = self.rating.defectsFromUI;
        ratingDefects = [self.rating getDefectsInSortedOrder:ratingDefects];
    } else {
        ratingDefects = [self.rating getAllDefects];
    }
    QualityManual* manual = [self.rating getQualityManual];
    if ([ratingDefects count] > 0) {
        DefectsViewController *defectsViewController = [[DefectsViewController alloc] initWithNibName:@"DefectsViewController" bundle:nil];
        defectsViewController.defectsArrayLocal = ratingDefects;
        defectsViewController.delegate = self;
        defectsViewController.qualityManual = manual;
        //NSLog(@"scsv %@", myTableViewController.navigationController);
        if (myTableViewController.navigationController) {
            [myTableViewController.navigationController pushViewController:defectsViewController animated:YES];
        } else {
            id appDelegate = [[UIApplication sharedApplication] delegate];
            AppDelegate *appDel = (AppDelegate *)appDelegate;
            [appDel.navigationController pushViewController:defectsViewController animated:YES];
        }
    } else {
        [[[UIAlertView alloc] initWithTitle: @"There are no defects for this rating" message: @"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

- (void) postNotificationToRemoveUtilityView {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveUtilityView" object:self];
}

#pragma mark - DefectRatingViewControllerDelegate methods

- (void) saveTheDefectsInTheRating:(NSArray *) defectsResponses {
    self.rating.defectsFromUI = [[NSMutableArray alloc] init];
    BOOL isSet = NO;
    for (Defect *defect in defectsResponses) {
        [self.rating addDefect:defect];
        if (!isSet && defect.isSetFromUI) {
            isSet = YES;
        }
    }
    if (isSet) {
        [self.checklistButton setBackgroundImage:[UIImage imageNamed:@"ic_storage_checked.png"] forState:UIControlStateNormal];
    } else {
        [self.checklistButton setBackgroundImage:[UIImage imageNamed:@"ic_storage.png"] forState:UIControlStateNormal];
    }
}

- (void)configureFonts
{
    theQuestion.font = [UIFont fontWithName:@"Helvetica-Bold" size:15.0];
    theQuestion.textColor = [UIColor colorWithHex:0x5f5b54];
    
    self.checklistButton.layer.cornerRadius = 0.0;
    self.checklistButton.layer.borderWidth = 0.0;
    self.checklistButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    self.scannableButton.layer.cornerRadius = 5.0;
    self.scannableButton.layer.borderWidth = 0.0;
    self.scannableButton.layer.borderColor = [[UIColor blackColor] CGColor];
    
    self.helpButton.layer.cornerRadius = 0.0;
    self.helpButton.layer.borderWidth = 0.0;
    self.helpButton.layer.borderColor = [[UIColor blackColor] CGColor];

}

- (void)refreshState
{
    if (!questionViewInitialized) {
        NSInteger numberOfLinesForQuestion;
        NSString *displayName = self.rating.name;
        if (self.rating.displayName && ![self.rating.displayName isEqualToString:@""]) {
            displayName = self.rating.displayName;
        }
        theQuestion.text = [NSString stringWithFormat:@"%@", displayName];
        if (!rating.optionalSettings.optional) {
            theQuestion.text = [NSString stringWithFormat:@"*%@", displayName];
        }
        numberOfLinesForQuestion = [BaseTableViewCell numberOfLinesForQuestion:self.rating];

//        if (numberOfLinesForQuestion > 0) {
//            
//            CGFloat questionLabelHeight;
//            questionLabelHeight = kQuestionLabelHeight;
//            CGFloat questionLabelYOffset;
//            questionLabelYOffset = kQuestionLabelYOffset;
//            CGFloat questionHeight = (questionLabelHeight * numberOfLinesForQuestion);
//            CGFloat questionViewHeight = questionLabelYOffset + questionHeight;
//            theQuestionView.frame = CGRectMake(0, 0, 320.0, questionViewHeight);
//            CGRect origQuestionFrame = theQuestion.frame;
//            
//            CGSize textSize;
//            if (IS_OS_7_OR_LATER)
//                textSize = [theQuestion.text sizeWithFont:[UIFont fontWithName:KSWFontNameUnivers47 size:14.0] constrainedToSize:CGSizeMake(theQuestion.frame.size.width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
//            
//            if(numberOfLinesForQuestion>1 && IS_OS_7_OR_LATER) {
//                theQuestion.frame = CGRectMake(origQuestionFrame.origin.x, origQuestionFrame.origin.y, textSize.width, textSize.height);
//            }
//            else {
//                theQuestion.frame = CGRectMake(origQuestionFrame.origin.x, origQuestionFrame.origin.y, origQuestionFrame.size.width, questionHeight);
//            }
//            
//            theQuestion.numberOfLines = numberOfLinesForQuestion;
//            CGRect origAnswerViewFrame = theAnswerView.frame;
//            theAnswerView.frame = CGRectMake(origAnswerViewFrame.origin.x, theQuestionView.frame.size.height, origAnswerViewFrame.size.width, origAnswerViewFrame.size.height);
//        }
        questionViewInitialized = YES;
    }
}

- (IBAction)checklistOrScanButtonTouched:(id)sender {
    [self postNotificationToRemoveUtilityView];
    NSArray *ratingDefects = [self.rating getAllDefects];
    DefectsViewController *defectsViewController = [[DefectsViewController alloc] initWithNibName:@"DefectsViewController" bundle:nil];
    defectsViewController.defectsArray = ratingDefects;
    [myTableViewController.navigationController pushViewController:defectsViewController animated:YES];
    
//    if ([cellTitle isEqualToString:@"starRatingView"]) {
//        BarcodeViewController *barcodeViewController = [[BarcodeViewController alloc] initWithNibName:@"BarcodeViewController" bundle:nil];
//        [myTableViewController.navigationController pushViewController:barcodeViewController animated:NO];
//    } else {
//        DefectsViewController *defectsViewController = [[DefectsViewController alloc] initWithNibName:@"DefectsViewController" bundle:nil];
//        [myTableViewController.navigationController pushViewController:defectsViewController animated:YES];
//    }
}

- (BOOL)validate
{
    validatedOnce = YES;
    NSString *theAnswer = [self theAnswerAsString];
    if (theAnswer && ![theAnswer isEqualToString:@""]) {
        [self clearValidationError];
        if ([theAnswer isEqualToString:OUTOFBOUNDS]) {
            return NO;
        }
        return YES;
    } else {
        [self displayValidationError];
        return NO;
    }
}

- (BOOL) validateForPriceAndNumericRating {
    validatedOnce = YES;
    NSString *theAnswer = [self theAnswerAsStringForNumericAndPriceRating];
    if (rating.optionalSettings.optional) {
        if ([self.unitsLabel.text isEqualToString:Units]) {
            if (theAnswer && ![theAnswer isEqualToString:@""]) {
                return NO;
            }
            return YES;
        } else {
            if (theAnswer && ![theAnswer isEqualToString:@""]) {
                return YES;
            }
            return NO;
        }
    } else {
        if ([self.unitsLabel.text isEqualToString:Units]) {
            return NO;
        } else {
            if (theAnswer && ![theAnswer isEqualToString:@""]) {
                return YES;
            }
            return NO;
        }
    }
}

- (BOOL) validateForNumericRating {
    validatedOnce = YES;
    NSString *theAnswer = [self theAnswerAsStringForNumericRating];
    
    //DI-3155 - ensure only 1 decimal
    //DI-2785 fix was causing a null when more than 1 decimal
    NSArray *dots = [theAnswer componentsSeparatedByString:@"."];
    NSArray *comma = [theAnswer componentsSeparatedByString:@","];
    if(dots.count > 2 || comma.count > 2)
        return NO;
    
    NSArray *array = [theAnswer componentsSeparatedByString:@" "];
    if ([array count] > 0) {
        if ([array count] == 1) {
            if (![[array objectAtIndex:0] isEqualToString:@""]) {
                double numericValue = [[array objectAtIndex:0] doubleValue];
                if (self.rating.content.numericRatingModel.min_value <= numericValue && numericValue <= self.rating.content.numericRatingModel.max_value) {
                    return YES;
                } else {
                    return NO;
                }
            } else {
                if (rating.optionalSettings.optional) {
                    return YES;
                } else {
                    return NO;
                }
            }
        }
        if (![[array objectAtIndex:0] isEqualToString:@""]) {
            double numericValue = [[array objectAtIndex:0] doubleValue];
            if (rating.optionalSettings.optional) {
                if ([[array objectAtIndex:1] isEqualToString:Units]) {
                    if (self.rating.content.numericRatingModel.min_value <= numericValue && numericValue <= self.rating.content.numericRatingModel.max_value) {
                        return NO;
                    } else if (numericValue >= self.rating.content.numericRatingModel.max_value || self.rating.content.numericRatingModel.min_value >= numericValue) {
                        return NO;
                    }
                    return YES;
                } else {
                    if (self.rating.content.numericRatingModel.min_value <= numericValue && numericValue <= self.rating.content.numericRatingModel.max_value) {
                        return YES;
                    }
                    return NO;
                }
            } else {
                if ([[array objectAtIndex:1] isEqualToString:Units]) {
                    return NO;
                } else {
                    if (self.rating.content.numericRatingModel.min_value <= numericValue && numericValue <= self.rating.content.numericRatingModel.max_value) {
                        return YES;
                    }
                    return NO;
                }
            }
        } else {
            return YES;
        }
    } else {
        return NO;
    }
}

- (NSString*)theAnswerAsString
{
    assert(NO);
}

- (NSString*)theAnswerAsStringForNumericRating
{
    assert(NO);
}

- (NSString*)theAnswerAsStringForNumericAndPriceRating
{
    assert(NO);
}

- (void)displayValidationError
{
    
}


- (void)clearValidationError
{
}

- (void)closeKeyboardIfOpen
{
}

- (void)passKeyboardIfOpen
{
}

-(void)updateMessage:(NSString*)message{
    
}


@end
