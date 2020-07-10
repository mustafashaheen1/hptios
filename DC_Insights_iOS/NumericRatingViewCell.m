//
//  NumericRatingViewCell.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/15/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "NumericRatingViewCell.h"
#import "ProductRatingViewController.h"
#import "HPTCaseCodeViewController.h"
#import "AppDelegate.h"
#import "ViewController.h"
#import "Inspection.h"

@implementation NumericRatingViewCell

@synthesize theAnswer;
@synthesize utilityButtonView;
@synthesize defaultLabel;
@synthesize unitsLabel;
@synthesize numericRatingModel;

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
    
    theAnswer.backgroundColor = [UIColor colorWithHex:0xeae7e4];
    
    theAnswer.font = [UIFont fontWithName:KSWFontNameUnivers47 size:20.0];
    theAnswer.textColor = [UIColor colorWithHex:0x000000];
    theAnswer.layer.borderWidth = 1.0;
    theAnswer.layer.borderColor = [[UIColor blackColor] CGColor];
    theAnswer.layer.cornerRadius = 0.0;
    theAnswer.autocorrectionType = UITextAutocorrectionTypeNo;
    [self.theAnswer setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    self.unitsButton.layer.borderWidth = 2.0;
    self.unitsButton.layer.borderColor = [[UIColor blackColor] CGColor];
    self.unitsButton.layer.cornerRadius = 3.0;
    
    // add some padding
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(5, 0, 5, 20)];
    theAnswer.leftView = paddingView;
    theAnswer.leftViewMode = UITextFieldViewModeAlways;
    
    // Configure utilityButtonView
    
    self.utilityButtonView.hidden = YES;
   /* UIWindow *win = [[UIApplication sharedApplication] keyWindow];
    [win addSubview:utilityButtonView];
    
    //utilityButtonView.frame = CGRectMake(0, (win.bounds.size.height - 260.0), 320.0, 44.0);
    utilityButtonView.frame = CGRectMake(0, (win.bounds.size.height - 260.0), win.bounds.size.width, 44.0);
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        utilityButtonView.frame = CGRectMake(0, (win.bounds.size.height - 304.0), win.bounds.size.width, 44.0);
        
        //hide the default assistant buttons on iPAD
        if ([self respondsToSelector:@selector(inputAssistantItem)]) {
            // iOS9.
            UITextInputAssistantItem* item = [self inputAssistantItem];
            item.leadingBarButtonGroups = @[];
            item.trailingBarButtonGroups = @[];
        }
    }

    self.utilityButtonView.barStyle = UIBarStyleBlack;
    self.utilityButtonView.translucent = YES;
    self.utilityButtonView.tintColor = nil;
    
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneTap)];
    
    UIBarButtonItem *clearButton = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStyleBordered target:self action:@selector(clearTap)];
    
    UIBarButtonItem *negativeSymbol = [[UIBarButtonItem alloc] initWithTitle:@"  [ - ]" style:UIBarButtonItemStylePlain target:self action:@selector(negativeTap)];
    
    NSString *reqSysVer = @"7.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending) {
        doneButton.tintColor = [UIColor whiteColor];
        clearButton.tintColor = [UIColor whiteColor];
        negativeSymbol.tintColor = [UIColor whiteColor];
    }
    
    [utilityButtonView setItems:[NSArray arrayWithObjects:negativeSymbol, flex, clearButton, doneButton, nil]];
 */
    // Configure inset of theAnswer based on screen size
    
    fontsSet = YES;
    
        UIToolbar* keyboardToolbar = [[UIToolbar alloc] init];
        [keyboardToolbar sizeToFit];
        UIBarButtonItem *flexBarButton = [[UIBarButtonItem alloc]
                                          initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                          target:nil action:nil];
        UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc]
                                          initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                          target:self action:@selector(yourTextViewDoneButtonPressed)];
        keyboardToolbar.items = @[flexBarButton, doneBarButton];
        theAnswer.inputAccessoryView = keyboardToolbar;
}

-(void)yourTextViewDoneButtonPressed
{
    if (([self.rating.order_data_field isEqualToString:@"QuantityOfCases"]) || ([self.rating.order_data_field isEqualToString:@"QuantityOfItems"])) {
    ProductRatingViewController *viewController = (ProductRatingViewController*)self.myTableViewController;
        [viewController checkCountOfCases:self.rating withCount:theAnswer.text];
        
    }
    [theAnswer resignFirstResponder];
}

- (void) removeUtilityButtonViewFromSuperView {
    self.utilityButtonView.hidden = YES;
    [theAnswer resignFirstResponder];
}


- (void)refreshState
{
    [super refreshState];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeUtilityButtonViewFromSuperView) name:@"RemoveUtilityView" object:nil];
    numericRatingModel = self.rating.content.numericRatingModel;
    self.unitsLabel.text = Units;
    if ([[numericRatingModel.numeric_type lowercaseString] isEqualToString:@"decimal"]) {
        self.theAnswer.placeholder = [NSString stringWithFormat:@" [ %.2f  to  %.2f] ", numericRatingModel.min_value, numericRatingModel.max_value];
    } else {
        self.theAnswer.placeholder = [NSString stringWithFormat:@" [ %.0f  to  %.0f] ", numericRatingModel.min_value, numericRatingModel.max_value];
    }
    [self addAdditionalButtons];
    if (!fontsSet) {
        [self configureFonts];
    }
    if (self.rating.ratingAnswerFromUI) {
        NSString *stringToParse = self.rating.ratingAnswerFromUI;
        NSArray *chunks = [stringToParse componentsSeparatedByString: @" "];
        if ([chunks count] > 0) {
            self.theAnswer.text = [chunks objectAtIndex:0];
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
    NSLog(@"%@", self.rating.content.numericRatingModel.units);
    if ([self.rating.content.numericRatingModel.units count] < 1) {
        self.unitsLabel.hidden = YES;
        self.unitsButton.hidden = YES;
        self.arrowImage.hidden = YES;
        self.theAnswer.frame = CGRectMake(self.theAnswer.frame.origin.x, self.theAnswer.frame.origin.y, 270, 41);
    }
    
    
    if ([[numericRatingModel.numeric_type lowercaseString] isEqualToString:@"decimal"]) {
        [theAnswer setKeyboardType:UIKeyboardTypeDecimalPad];
    }
    if ([self.rating.order_data_field isEqualToString:@"QuantityOfCases"]) {
        ProductRatingViewController *viewController = (ProductRatingViewController*)self.myTableViewController;
        int count = viewController.currentAuditGlobal.countOfCasesFromSavedAudit;
        if (count > 0) {
            theAnswer.text = [NSString stringWithFormat:@"%d", count];
        }
    }
}


- (BOOL)validate
{
    return [super validate];
}


- (NSString*)theAnswerAsStringForNumericAndPriceRating
{
    return @"";
}

- (NSString*)theAnswerAsString
{
    return @"";
}

- (void)negativeTap
{
    NSString *negativeLocal = theAnswer.text;
    negativeLocal = [negativeLocal stringByAppendingString:@"-"];
    theAnswer.text = negativeLocal;
}

-(NSString*)getLocaleFormattedNumber:(NSString*)theAnswer {
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    //NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
   // f.locale = usLocale;
    NSNumber *theAnswerAsNumber = [f numberFromString:theAnswer];
    NSString* localeFormattedAnswer = [NSString stringWithFormat:@"%@",theAnswerAsNumber];
    NSLog(@"en_US: %@",localeFormattedAnswer);
    return localeFormattedAnswer;
}

- (NSString*)theAnswerAsStringForNumericRating
{
    //NSLog(@"thenad %@", theAnswer.text);
    if ([theAnswer.text isEqualToString:@""] || [theAnswer.text isEqualToString:@"."] || [[NSString stringWithFormat:@"%@", theAnswer.text] isEqualToString:@"(null)"]) {
        return @"";
    }
    NSString *answer;
    
    //DI-3167
    NSString* localFormattedValue = self.theAnswer.text;
    NSLocale *currentLocale = [NSLocale currentLocale];
    
    //DI-2785 - handle comma in numeric fields instead of period (spanish language) - SunWorld
    if(currentLocale && [currentLocale.localeIdentifier hasPrefix:@"es_"]){
        localFormattedValue = [self getLocaleFormattedNumber:self.theAnswer.text];
    }
    
    if ([self.rating.content.numericRatingModel.units count] < 1) {
        answer = [NSString stringWithFormat:@"%@", localFormattedValue];
    } else {
        answer = [NSString stringWithFormat:@"%@ %@", localFormattedValue, unitsLabel.text];
    }
    
    return answer;
    
//    
//    if (numericRatingModel.min_value <= numericValue && numericValue <= numericRatingModel.max_value) {
//        NSString *answer = [NSString stringWithFormat:@"%@ %@", self.theAnswer.text, unitsLabel.text];
//        
//        if (self.rating.optionalSettings.optional) {
//            if ([unitsLabel.text isEqualToString:Units]) {
//                answer = [NSString stringWithFormat:@"%@", self.theAnswer.text];
//            }
//        } else {
//            if ([unitsLabel.text isEqualToString:Units]) {
//                return @"";
//            }
//        }
//        return answer;
//    } else if (self.rating.optionalSettings.optional) {
//        NSString *answer = [NSString stringWithFormat:@"%@ %@", self.theAnswer.text, unitsLabel.text];
//        if ([unitsLabel.text isEqualToString:Units]) {
//            answer = [NSString stringWithFormat:@"%@", self.theAnswer.text];
//        }
//        return answer;
//    } else {
//        return OUTOFBOUNDS;
//    }
}

//- (NSString*) theAnswerAsStringForNumericAndPriceRating
//{
//    NSString *theAnswer = @"";
//    NSLog(@"thenad %@", theAnswerTextField.text);
//    if ([theAnswerTextField.text isEqualToString:@""] || [theAnswerTextField.text isEqualToString:@"."] || [[NSString stringWithFormat:@"%@", theAnswerTextField.text] isEqualToString:@"(null)"]) {
//        return @"";
//    }
//    
//    if ([self.unitsLabel.text isEqualToString:Units]) {
//        theAnswer = [NSString stringWithFormat:@"%@", self.theAnswerTextField.text];
//    } else {
//        theAnswer = [NSString stringWithFormat:@"%@ %@", self.theAnswerTextField.text, self.unitsLabel.text];
//    }
//    
//    return theAnswer;
//}


- (void)closeKeyboardIfOpen
{
    if (!utilityButtonView.hidden) {
        self.utilityButtonView.hidden = YES;
        
        [theAnswer resignFirstResponder];
    }
}


- (void)passKeyboardIfOpen
{
    if (!utilityButtonView.hidden) {
        self.utilityButtonView.hidden = YES;
        
        [theAnswer nextResponder];
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
    theAnswer.text = @"";
}


- (void)doneTap
{
    self.utilityButtonView.hidden = YES;
    
	[theAnswer resignFirstResponder];
        
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
    }else if (self.myTableViewController &&
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

- (void) scannableButtonTouched {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveUtilityView" object:self];
    if([[User sharedUser] checkForRetailInsights] || [[User sharedUser] checkForScanOut] || [[User sharedUser] checkForDCInsights]) {
        ViewController *scannerViewController = [[ViewController alloc] initWithNibName:@"ViewController_iPhone" bundle:nil withDelegate:self];
        scannerViewController.multiScan = NO;
        if ([[User sharedUser] checkForScanOut]) {
            scannerViewController.multiScan = YES;
            scannerViewController.allCodes = self.allCodes;
        }
        [scannerViewController startScanner];//fire scanner after variables set
        if (self.myTableViewController.navigationController) {
            [self.myTableViewController.navigationController pushViewController:scannerViewController animated:YES];
        } else {
            id appDelegate = [[UIApplication sharedApplication] delegate];
            AppDelegate *appDel = (AppDelegate *)appDelegate;
            [appDel.navigationController pushViewController:scannerViewController animated:YES];
        }
    }
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

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    //disable editing of text field for disabled ratings - only when its order-data 
    if(self.rating.optionalSettings.rating && [[Inspection sharedInspection] checkForOrderData] && ![[Inspection sharedInspection] isOtherSelected]){
            return NO;
    }
    return YES;
}

#pragma mark - SWBarcodePickerManagerProtocol


- (void)scanDoneWithUpc:(NSString*)theUpc {
//    if (self.myTableViewController.navigationController) {
//        [self.myTableViewController.navigationController popViewControllerAnimated:YES];
//    } else {
//        id appDelegate = [[UIApplication sharedApplication] delegate];
//        AppDelegate *appDel = (AppDelegate *)appDelegate;
//        [appDel.navigationController popViewControllerAnimated:YES];
//    }
    self.theAnswer.text = theUpc;
}

- (void)scanCheckingForProductOnServer:(Product*)productInProgress {
}

- (void)scanDoneWithProduct:(Product*)theProduct {
}

- (void)scanDoneWithError:(NSError*)theError forProduct:(Product*)theProduct {
}

- (void)scanCancelled {
}

#pragma mark - UIPopoverListViewDataSource

- (UITableViewCell *)popoverListView:(UIPopoverListView *)popoverListView
                    cellForIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    if ([self.rating.content.numericRatingModel.units count] >0) {
        cell.textLabel.text = [self.rating.content.numericRatingModel.units objectAtIndex:indexPath.row];
    }
    return cell;
}

- (NSInteger)popoverListView:(UIPopoverListView *)popoverListView
       numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"contern %d", [self.rating.content.numericRatingModel.units count]);
    return [self.rating.content.numericRatingModel.units count];
}

#pragma mark - UIPopoverListViewDelegate
- (void)popoverListView:(UIPopoverListView *)popoverListView
     didSelectIndexPath:(NSIndexPath *)indexPath
{
    if ([self.rating.content.numericRatingModel.units count] > 0) {
        self.unitsLabel.text = [self.rating.content.numericRatingModel.units objectAtIndex:indexPath.row];
    }
}

- (CGFloat)popoverListView:(UIPopoverListView *)popoverListView
   heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
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

- (void) selectOptions {
    CGFloat xWidth = self.myTableViewController.view.frame.size.width - 20.0f;
    CGFloat yHeight = popupDefaultHeight;
    if ([self.rating.content.numericRatingModel.units count] < 5) {
        int heightAfterCalculation = [self.rating.content.numericRatingModel.units count] * 60.0f;
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

@end
