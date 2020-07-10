//
//  PriceRatingViewCell.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/15/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "PriceRatingViewCell.h"
#import "ProductRatingViewController.h"
#import "HPTCaseCodeViewController.h"
#import "AppDelegate.h"
#import "ViewController.h"

@implementation PriceRatingViewCell

@synthesize utilityButtonView;
@synthesize defaultLabel;
@synthesize theAnswerTextField;
@synthesize unitsButton;
@synthesize unitsLabel;

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
    return (70 + questionViewHeight);
}

#pragma mark - Refresh state Method

- (void) addAdditionalButtons {
    [super addAdditionalButtons];
}

- (void)configureFonts
{
    [super configureFonts];
    
    theAnswerTextField.backgroundColor = [UIColor colorWithHex:0xeae7e4];
    
    theAnswerTextField.font = [UIFont fontWithName:KSWFontNameUnivers47 size:20.0];
    theAnswerTextField.textColor = [UIColor colorWithHex:0x000000];
    theAnswerTextField.layer.borderWidth = 1.0;
    theAnswerTextField.layer.borderColor = [[UIColor blackColor] CGColor];
    theAnswerTextField.layer.cornerRadius = 0.0;
    theAnswerTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    [self.theAnswerTextField setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    // add some padding
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(5, 0, 5, 20)];
    theAnswerTextField.leftView = paddingView;
    theAnswerTextField.leftViewMode = UITextFieldViewModeAlways;

    unitsButton.layer.borderWidth = 2.0;
    unitsButton.layer.borderColor = [[UIColor blackColor] CGColor];
    unitsButton.layer.cornerRadius = 3.0;
    
    // Configure utilityButtonView
    
    self.utilityButtonView.hidden = YES;
    UIWindow *win = [[UIApplication sharedApplication] keyWindow];
    [win addSubview:utilityButtonView];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [utilityButtonView removeFromSuperview];
    }
    utilityButtonView.frame = CGRectMake(0, (win.bounds.size.height - 260.0), win.bounds.size.width, 44.0);
    
    self.utilityButtonView.barStyle = UIBarStyleBlack;
    self.utilityButtonView.translucent = YES;
    self.utilityButtonView.tintColor = nil;
    
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneTap)];
    
    UIBarButtonItem *clearButton = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStyleBordered target:self action:@selector(clearTap)];
    
    NSString *reqSysVer = @"7.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending) {
        doneButton.tintColor = [UIColor whiteColor];
        clearButton.tintColor = [UIColor whiteColor];
    }
    
    [utilityButtonView setItems:[NSArray arrayWithObjects:flex, clearButton, doneButton, nil]];
    
    // Configure inset of theAnswer based on screen size
    
    fontsSet = YES;
}


- (void)refreshState
{
    [super refreshState];
    [self addAdditionalButtons];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeUtilityButtonViewFromSuperView) name:@"RemoveUtilityView" object:nil];

    if (!fontsSet) {
        [self configureFonts];
    }
//    if ([self.rating.type isEqualToString:PRICE_RATING]) {
//        [self.checklistButton setBackgroundImage:[UIImage imageNamed:@"scaniconwhite.png"] forState:UIControlStateNormal];
//    }
    if (self.rating.ratingAnswerFromUI) {
        NSString *stringToParse = self.rating.ratingAnswerFromUI;
        NSArray *chunks = [stringToParse componentsSeparatedByString: @" "];
        if ([chunks count] > 0) {
            self.theAnswerTextField.text = [chunks objectAtIndex:0];
            if ([chunks count] > 1) {
                if (![[chunks objectAtIndex:1] isEqualToString:@""]) {
                    unitsLabel.text = [chunks objectAtIndex:1];
                } else {
                    unitsLabel.text = Units;
                }
            } else {
                unitsLabel.text = Units;
            }
        }
    }
}


- (BOOL)validate
{
    return [super validate];
}


//- (NSString*)theAnswerAsString
//{
//    NSString *theAnswer = @"";
//    NSLog(@"thenad %@", theAnswerTextField.text);
//    if ([theAnswerTextField.text isEqualToString:@""] || [theAnswerTextField.text isEqualToString:@"."] || [[NSString stringWithFormat:@"%@", theAnswerTextField.text] isEqualToString:@"(null)"]) {
//        return @"";
//    }
//    if (self.unitsButton) {
//        theAnswer = [NSString stringWithFormat:@"%@ %@", self.theAnswerTextField.text, unitsLabel.text];
//        if (self.rating.optionalSettings.optional) {
//            if ([unitsLabel.text isEqualToString:Units]) {
//                theAnswer = [NSString stringWithFormat:@"%@", self.theAnswerTextField.text];
//            }
//        } else {
//            if ([unitsLabel.text isEqualToString:Units]) {
//                return @"";
//            }
//        }
//    }
//    if (self.rating.optionalSettings.optional) {
//        NSString *answer = [NSString stringWithFormat:@"%@ %@", self.theAnswerTextField.text, unitsLabel.text];
//        if ([unitsLabel.text isEqualToString:Units]) {
//            answer = [NSString stringWithFormat:@"%@", self.theAnswerTextField.text];
//        }
//        return answer;
//    }
//    
//    return theAnswer;
//}

- (NSString*)theAnswerAsStringForNumericRating
{
    return @"";
}

- (NSString*)theAnswerAsString
{
    return @"";
}

- (NSString*) theAnswerAsStringForNumericAndPriceRating
{
    NSString *theAnswer = @"";
    //NSLog(@"thenad %@", theAnswerTextField.text);
    if ([theAnswerTextField.text isEqualToString:@""] || [theAnswerTextField.text isEqualToString:@"."] || [[NSString stringWithFormat:@"%@", theAnswerTextField.text] isEqualToString:@"(null)"]) {
        return @"";
    }
    
    if ([self.unitsLabel.text isEqualToString:Units]) {
        theAnswer = [NSString stringWithFormat:@"%@", self.theAnswerTextField.text];
    } else {
        theAnswer = [NSString stringWithFormat:@"%@ %@", self.theAnswerTextField.text, self.unitsLabel.text];
    }
    
//    if (self.unitsButton) {
//        theAnswer = [NSString stringWithFormat:@"%@ %@", self.theAnswerTextField.text, unitsLabel.text];
//        if (self.rating.optionalSettings.optional) {
//            if ([unitsLabel.text isEqualToString:Units]) {
//                theAnswer = [NSString stringWithFormat:@"%@", self.theAnswerTextField.text];
//            }
//        } else {
//            if ([unitsLabel.text isEqualToString:Units]) {
//                return @"";
//            }
//        }
//    }
//    if (self.rating.optionalSettings.optional) {
//        NSString *answer = [NSString stringWithFormat:@"%@ %@", self.theAnswerTextField.text, unitsLabel.text];
//        if ([unitsLabel.text isEqualToString:Units]) {
//            answer = [NSString stringWithFormat:@"%@", self.theAnswerTextField.text];
//        }
//        return answer;
//    }
    
    return theAnswer;
}


- (void)closeKeyboardIfOpen
{
    if (!utilityButtonView.hidden) {
        self.utilityButtonView.hidden = YES;
        
        [theAnswerTextField resignFirstResponder];
    }
}


- (void)passKeyboardIfOpen
{
    if (!utilityButtonView.hidden) {
        self.utilityButtonView.hidden = YES;
        
        [theAnswerTextField nextResponder];
    }
}

- (IBAction) unitsButtonTouched:(id)sender {
    if (self.myTableViewController &&
        [self.myTableViewController isKindOfClass:[ProductRatingViewController class]]) {
        [self closeKeyboardIfOpen];
        [self selectOptions];
    } else if (self.myTableViewController &&
        [self.myTableViewController isKindOfClass:[HPTCaseCodeViewController class]]) {
        [self closeKeyboardIfOpen];
        [self selectOptions];
    }
}


#pragma mark - TableViewCell Methods


/*------------------------------------------------------------------------------
 METHOD: prepareForReuse
 
 PURPOSE:
 Reset the state of the cell to be used for a search result item.
 -----------------------------------------------------------------------------*/
- (void)prepareForReuse
{
	[super prepareForReuse];
}



#pragma mark - UITextViewDelegate


- (void)clearTap
{
    theAnswerTextField.text = @"";
}


- (void)doneTap
{
    self.utilityButtonView.hidden = YES;
    
	[theAnswerTextField resignFirstResponder];
    
    if (validatedOnce) {
        [self validate];
    }
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(self.questionNumber - 1) inSection:0];
//    [self.myTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(self.questionNumber - 1) inSection:0];
    CGRect rectInTableView = [self.myTableView rectForRowAtIndexPath:indexPath];
    UIWindow *win = [[UIApplication sharedApplication] keyWindow];
    [self.myTableView scrollRectToVisible:CGRectMake(0, rectInTableView.origin.y + 100, self.myTableView.frame.size.width, self.myTableView.frame.size.height) animated:YES];

    
    NSInteger maxTitleLinesBeforeAdditionalOffet = 1;
    if ([UIScreen mainScreen].bounds.size.height > 480.0) {
        maxTitleLinesBeforeAdditionalOffet = 6;
    }
    
    if (self.theQuestion.numberOfLines > maxTitleLinesBeforeAdditionalOffet) {
        // Edge case for essays with long questions, scroll further to the answer itself
        if (self.myTableViewController &&
            [self.myTableViewController isKindOfClass:[ProductRatingViewController class]]) {
            
            NSInteger myStartingPos = [(ProductRatingViewController*)self.myTableViewController verticalStartingPositionForRow:(self.questionNumber - 1)];
            NSInteger additionalOffset = kQuestionLabelHeight * (self.theQuestion.numberOfLines - maxTitleLinesBeforeAdditionalOffet);
            [self.myTableView setContentOffset:CGPointMake(0, myStartingPos + additionalOffset) animated:YES];
        } else if (self.myTableViewController &&
            [self.myTableViewController isKindOfClass:[HPTCaseCodeViewController class]]) {
            
            NSInteger myStartingPos = [(HPTCaseCodeViewController*)self.myTableViewController verticalStartingPositionForRow:(self.questionNumber - 1)];
            NSInteger additionalOffset = kQuestionLabelHeight * (self.theQuestion.numberOfLines - maxTitleLinesBeforeAdditionalOffet);
            [self.myTableView setContentOffset:CGPointMake(0, myStartingPos + additionalOffset) animated:YES];
        }
    }
    
    if (self.myTableViewController &&
        [self.myTableViewController isKindOfClass:[ProductRatingViewController class]]) {
        [(ProductRatingViewController*)self.myTableViewController tellOtherQuestionsToCloseKeyboard:self.rating];
    } else if (self.myTableViewController &&
        [self.myTableViewController isKindOfClass:[HPTCaseCodeViewController class]]) {
        [(HPTCaseCodeViewController*)self.myTableViewController tellOtherQuestionsToCloseKeyboard:self.rating];
    }
    [self.myTableView setContentOffset:self.myTableView.contentOffset animated:NO];
    self.utilityButtonView.hidden = NO;
    
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    self.defaultLabel.hidden = YES;
}

- (void)textViewDidChange:(UITextView *)txtView
{
    self.defaultLabel.hidden = ([txtView.text length] > 0);
}

- (void)textViewDidEndEditing:(UITextView *)txtView
{
    self.defaultLabel.hidden = ([txtView.text length] > 0);
}

- (void) removeUtilityButtonViewFromSuperView {
    self.utilityButtonView.hidden = YES;
    [self.theAnswerTextField resignFirstResponder];
}

- (void) scannableButtonTouched {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveUtilityView" object:self];
   // if([[User sharedUser] checkForRetailInsights]) {
        ViewController *scannerViewController = [[ViewController alloc] initWithNibName:@"ViewController_iPhone" bundle:nil withDelegate:self];
        scannerViewController.multiScan = NO;
        [scannerViewController startScanner];//fire scanner after variables set
        if (self.myTableViewController.navigationController) {
            [self.myTableViewController.navigationController pushViewController:scannerViewController animated:YES];
        } else {
            id appDelegate = [[UIApplication sharedApplication] delegate];
            AppDelegate *appDel = (AppDelegate *)appDelegate;
            [appDel.navigationController pushViewController:scannerViewController animated:YES];
        }
   // }
    /*else {
        self.pickerController = [[SWBarcodePickerManager sharedSWBarcodePickerManager] pickerController:self withScanOnly:YES];
        if (self.myTableViewController.navigationController) {
            [self.myTableViewController.navigationController pushViewController:self.pickerController animated:YES];
        } else {
            id appDelegate = [[UIApplication sharedApplication] delegate];
            AppDelegate *appDel = (AppDelegate *)appDelegate;
            [appDel.navigationController pushViewController:self.pickerController animated:YES];
        }
    }*/
}

- (void) selectOptions {
    CGFloat xWidth = self.myTableViewController.view.frame.size.width - 20.0f;
    CGFloat yHeight = popupDefaultHeight;
    if ([self.rating.content.priceRatingModel.price_items count] < 5) {
        int heightAfterCalculation = [self.rating.content.priceRatingModel.price_items count] * 60.0f;
        heightAfterCalculation = heightAfterCalculation + 40;
        yHeight = heightAfterCalculation;
    }
    CGFloat yOffset = (self.myTableViewController.view.frame.size.height - yHeight)/2.0f;
    UIPopoverListView *poplistview = [[UIPopoverListView alloc] initWithFrame:CGRectMake(10, yOffset, xWidth, yHeight)];
    poplistview.delegate = self;
    poplistview.datasource = self;
    poplistview.listView.scrollEnabled = TRUE;
    [poplistview setTitle:@"   Select Unit"];
    [poplistview show];
}

#pragma mark - UIPopoverListViewDataSource

- (UITableViewCell *)popoverListView:(UIPopoverListView *)popoverListView
                    cellForIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    if ([self.rating.content.priceRatingModel.price_items count] >0) {
        cell.textLabel.text = [self.rating.content.priceRatingModel.price_items objectAtIndex:indexPath.row];
    }
    return cell;
}

- (NSInteger)popoverListView:(UIPopoverListView *)popoverListView
       numberOfRowsInSection:(NSInteger)section
{
    return [self.rating.content.priceRatingModel.price_items count];
}

#pragma mark - UIPopoverListViewDelegate
- (void)popoverListView:(UIPopoverListView *)popoverListView
     didSelectIndexPath:(NSIndexPath *)indexPath
{
    if ([self.rating.content.priceRatingModel.price_items count] > 0) {
        self.unitsLabel.text = [self.rating.content.priceRatingModel.price_items objectAtIndex:indexPath.row];
    }
}

- (CGFloat)popoverListView:(UIPopoverListView *)popoverListView
   heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

#pragma mark - SWBarcodePickerManagerProtocol


- (void)scanDoneWithUpc:(NSString*)theUpc {
    if (self.myTableViewController.navigationController) {
        [self.myTableViewController.navigationController popViewControllerAnimated:YES];
    } else {
        id appDelegate = [[UIApplication sharedApplication] delegate];
        AppDelegate *appDel = (AppDelegate *)appDelegate;
        [appDel.navigationController popViewControllerAnimated:YES];
    }
    self.theAnswerTextField.text = theUpc;
}

- (void)scanCheckingForProductOnServer:(Product*)productInProgress {
}

- (void)scanDoneWithProduct:(Product*)theProduct {
}

- (void)scanDoneWithError:(NSError*)theError forProduct:(Product*)theProduct {
}

- (void)scanCancelled {
}




@end
