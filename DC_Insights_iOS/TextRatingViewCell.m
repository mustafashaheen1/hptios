//
//  TextRatingViewCell.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/15/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "TextRatingViewCell.h"
#import "ProductRatingViewController.h"
#import "HPTCaseCodeViewController.h"
#import "AppDelegate.h"
#import "ViewController.h"
#import "Inspection.h"

@implementation TextRatingViewCell

@synthesize theAnswer;
@synthesize utilityButtonView;
@synthesize defaultLabel;

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
    return (130 + questionViewHeight);
}

#pragma mark - Refresh state Method

- (void) addAdditionalButtons {
    theAnswer.delegate = self;
    [self setFrames];
    [super addAdditionalButtons];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    //disable editing of text field for disabled ratings - only when its order-data
    if(self.rating.optionalSettings.rating && [[Inspection sharedInspection] checkForOrderData] && ![[Inspection sharedInspection] isOtherSelected]){
        return NO;
    }
    return YES;
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    //disable editing of text field for disabled ratings - only when its order-data
    if(self.rating.optionalSettings.rating && [[Inspection sharedInspection] checkForOrderData] && ![[Inspection sharedInspection] isOtherSelected]){
        return NO;
    }
    return YES;
}


-(void) setFrames
{

   CGRect textFrame = theAnswer.frame;
   textFrame.size.height = theAnswer.contentSize.height - 50;
   theAnswer.frame = textFrame;
}

-(void) adjustFrames
{
   CGRect textFrame = theAnswer.frame;
   textFrame.size.height = theAnswer.contentSize.height;
   theAnswer.frame = textFrame;
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
    
   
    
    //[theAnswer setReturnKeyType:UIReturnKeyDone];
    
    [self.theAnswer setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    // add some padding
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(5, 0, 5, 20)];
   // theAnswer.leftView = paddingView;
   // theAnswer.leftViewMode = UITextFieldViewModeAlways;
    
    //TODO remove the utility view
    //[theAnswer setReturnKeyType:UIReturnKeyDone];

    // Configure utilityButtonView
    
    self.utilityButtonView.hidden = YES;
  /*  UIWindow *win = [[UIApplication sharedApplication] keyWindow];
    [win addSubview:utilityButtonView];
  
    utilityButtonView.frame = CGRectMake(0, (win.bounds.size.height - 200.0), win.bounds.size.width, 44.0);*/
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
       // utilityButtonView.frame = CGRectMake(0, (win.bounds.size.height - 304.0), win.bounds.size.width, 44.0);
        
        //hide the default assistant buttons on iPAD
        if ([self respondsToSelector:@selector(inputAssistantItem)]) {
            // iOS9.
            UITextInputAssistantItem* item = [self inputAssistantItem];
            item.leadingBarButtonGroups = @[];
            item.trailingBarButtonGroups = @[];
        }
    }
   /* self.utilityButtonView.barStyle = UIBarStyleBlack;
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
    
    [utilityButtonView setItems:[NSArray arrayWithObjects:flex, clearButton, doneButton, nil]];*/
    
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
    
    //DI-3154 - Add autocorrect/complete bar
    theAnswer.autocorrectionType = UITextAutocorrectionTypeYes;
    fontsSet = YES;
    
}

-(void)yourTextViewDoneButtonPressed
{
    [theAnswer resignFirstResponder];
}

- (void) removeUtilityButtonViewFromSuperView {
    self.utilityButtonView.hidden = YES;
    [theAnswer resignFirstResponder];
}

- (void)refreshState
{
    [super refreshState];
    [self addAdditionalButtons];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeUtilityButtonViewFromSuperView) name:@"RemoveUtilityView" object:nil];

    if (!fontsSet) {
        [self configureFonts];
    }
    if (self.rating.ratingAnswerFromUI && ![self.rating.ratingAnswerFromUI isEqualToString:@""]) {
        self.theAnswer.text = self.rating.ratingAnswerFromUI;
    }
}


- (BOOL)validate
{
    return [super validate];
}


- (NSString*)theAnswerAsString
{
    return theAnswer.text;
}

- (NSString*)theAnswerAsStringForNumericRating
{
    return @"";
}

- (NSString*)theAnswerAsStringForNumericAndPriceRating
{
    return @"";
}

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
    } else if (self.myTableViewController &&
        [self.myTableViewController isKindOfClass:[HPTCaseCodeViewController class]]) {
        [(HPTCaseCodeViewController*)self.myTableViewController tellOtherQuestionsToCloseKeyboard:self.rating];
    }
    [self.myTableView setContentOffset:self.myTableView.contentOffset animated:NO];
    self.utilityButtonView.hidden = NO;
    
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    //    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(self.questionNumber - 1) inSection:0];
    //    [self.myTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(self.questionNumber - 1) inSection:0];
        CGRect rectInTableView = [self.myTableView rectForRowAtIndexPath:indexPath];
    UITableViewCell *cell = [self.myTableView cellForRowAtIndexPath:indexPath];
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
    self.defaultLabel.hidden = YES;
}

- (void)textViewDidChange:(UITextView *)txtView
{
    [self adjustFrames];
    self.defaultLabel.hidden = ([txtView.text length] > 0);
}
- (void)textViewDidEndEditing:(UITextView *)txtView
{
    self.defaultLabel.hidden = ([txtView.text length] > 0);
}

- (void) scannableButtonTouched {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveUtilityView" object:self];
 //   if([[User sharedUser] checkForRetailInsights] || [[User sharedUser] checkForScanOut] || [[User sharedUser] checkForDCInsights]) {
        ViewController *scannerViewController = [[ViewController alloc] initWithNibName:@"ViewController_iPhone" bundle:nil withDelegate:self];
        scannerViewController.multiScan = NO;
        if ([[User sharedUser] checkForScanOut]) {
            scannerViewController.multiScan = YES;
            scannerViewController.allCodes = self.allCodes;
        }
        if([[User sharedUser] checkForRetailInsights]){
            if([self.rating.name containsString:@"QR"]){
                scannerViewController.enforceQROnlyScan = YES;
            }
        }
        [scannerViewController startScanner];//fire scanner after variables set
        if (self.myTableViewController.navigationController) {
            [self.myTableViewController.navigationController pushViewController:scannerViewController animated:YES];
        } else {
            id appDelegate = [[UIApplication sharedApplication] delegate];
            AppDelegate *appDel = (AppDelegate *)appDelegate;
            [appDel.navigationController pushViewController:scannerViewController animated:YES];
        }
  //  }
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

#pragma mark - SWBarcodePickerManagerProtocol


- (void)scanDoneWithUpc:(NSString*)theUpc {
    if ([[User sharedUser] checkForScanOut]) {
        self.allCodes = theUpc;
    }

    else if([[User sharedUser] checkForRetailInsights]){
        if(theUpc && [self.rating.name containsString:@"(QR_DS)"]){
            if([self isADriscollCode:theUpc]){
                NSString* parsedCode = [self parseDriscollsCode:theUpc];
                if([self isMatchDriscollsCodeRegex:parsedCode]){
                    theUpc = parsedCode;
                }else
                    theUpc = @"";
            }
        }
    }

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

-(BOOL) isADriscollCode:(NSString*)code{
    
    if ([code rangeOfString:@"http://dscl.us/" options:NSCaseInsensitiveSearch].location == NSNotFound
        && [code rangeOfString:@"https://dscl.us/" options:NSCaseInsensitiveSearch].location == NSNotFound)
    {
        return NO;
    }else
        return YES;
}

-(NSString*) parseDriscollsCode:(NSString*)code{
    NSArray *splitStringArray = [code componentsSeparatedByString:@"/"];
    // this would display the characters before the character ")"
    NSLog(@"%@", [splitStringArray objectAtIndex:3]);
    NSString* parsedCode = [splitStringArray objectAtIndex:3];
    return parsedCode;
}


-(BOOL) isMatchDriscollsCodeRegex:(NSString*)code{
    NSString *searchedString = code;
    NSRange   searchedRange = NSMakeRange(0, [searchedString length]);
    NSString *pattern = @"^([a-zA-Z0-9]{12}DS[0-9a-zA-Z][0-9a-zA-Z])$";
    NSError  *error = nil;
    
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern: pattern options:0 error:&error];
    NSTextCheckingResult *match = [regex firstMatchInString:searchedString options:0 range:NSMakeRange(0, [searchedString length])];
    BOOL isMatch = match != nil;
    return isMatch;
}



@end
