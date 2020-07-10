//
//  BaseTableViewCell.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/13/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Rating.h"
#import "UIColor+UIColor_DCInsights.h"
#import "UIFont+UIFont_DCInsights.h"
#import "Constants.h"
#import "DefectsViewController.h"
//#import "SWBarcodePickerManager.h"
//#import "BarcodeViewController.h"
#import "UIPopoverListView.h"
#import "CurrentAudit.h"
#import "ViewController.h"


#define kQuestionLabelWidth         250
#define kQuestionLabelHeight        17
#define kQuestionLabelYOffset       14

@interface BaseTableViewCell : UITableViewCell <UIAlertViewDelegate, DefectRatingViewControllerDelegate, ScannerProtocol, UIPopoverListViewDelegate, UIPopoverListViewDataSource> {
    BOOL fontsSet;
    BOOL validatedOnce;
    BOOL questionViewInitialized;
}

@property (nonatomic, assign) NSInteger questionNumber;
@property (retain, nonatomic) IBOutlet UILabel *theQuestion;
@property (retain, nonatomic) IBOutlet UIView *theQuestionView;
@property (retain, nonatomic) IBOutlet UIView *theAnswerView;
@property (retain, nonatomic) Rating *rating;
@property (nonatomic, weak) UITableView *myTableView;
@property (nonatomic, weak) UIViewController *myTableViewController;
@property (retain, nonatomic) IBOutlet UIButton *checklistButton;
@property (retain, nonatomic) IBOutlet UIButton *scannableButton;
@property (retain, nonatomic) IBOutlet UIButton *helpButton;
@property (retain, nonatomic) IBOutlet UIButton *additionalDetailsButton;
@property (retain, nonatomic) NSString *cellTitle;
@property (retain, nonatomic) ViewController *pickerController;
@property (retain, nonatomic) IBOutlet UILabel *unitsLabel;
@property (retain, nonatomic) CurrentAudit *currentAudit;


+ (CGFloat)myCellHeight:(Rating*)theRating;
+ (CGFloat)myQuestionViewHeight:(Rating*)theRating;
+ (NSInteger)numberOfLinesForQuestion:(Rating*)theRating;

- (void)configureFonts;
- (void) addAdditionalButtons;
- (void)refreshState;
- (BOOL)validate;
- (BOOL)validateForNumericRating;
- (BOOL) validateForPriceAndNumericRating;
- (NSString*)theAnswerAsString;
- (NSString *) theAnswerAsStringForNumericAndPriceRating;
- (NSString *) theAnswerAsStringForNumericRating;
- (void)closeKeyboardIfOpen;
- (void)passKeyboardIfOpen;
-(void)highlightDefectsButton:(int)currentStarRating;
-(void)updateMessage:(NSString*)message;

-(void)reset;

@end
