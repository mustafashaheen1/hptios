//
//  DateRatingViewCell.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/15/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "DateRatingViewCell.h"
#import "ProductRatingViewController.h"
#import "HPTCaseCodeViewController.h"
#import "DaysRemainingValidator.h"


@implementation DateRatingViewCell

@synthesize monthView;
@synthesize monthLabel;
@synthesize dayView;
@synthesize dayLabel;
@synthesize yearView;
@synthesize yearLabel;
@synthesize slashOne;
@synthesize slashTwo;
@synthesize datePickerView;
@synthesize datePicker;
@synthesize keyboardDoneButtonView;
@synthesize dateLabel;

- (id)init
{
    self = [super init];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.message.hidden = YES;//hidden by default
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
    
    monthView.backgroundColor = [UIColor colorWithHex:0xeae7e4];
    monthView.layer.borderColor = [[UIColor blackColor] CGColor];
    monthView.layer.borderWidth = 1.0;
    monthView.layer.cornerRadius = 0.0;
    
    dateLabel.backgroundColor = [UIColor colorWithHex:0xeae7e4];
    dateLabel.font = [UIFont fontWithName:KSWFontNameUnivers47 size:20.0];
    dateLabel.textColor = [UIColor colorWithHex:0x000000];
    dateLabel.layer.borderWidth = 0.0;
    dateLabel.layer.borderColor = [[UIColor colorWithHex:0xeae7e4] CGColor];
    
    //monthLabel.font = [UIFont fontWithName:KSWFontNameUnivers47 size:20.0];
    //monthLabel.textColor = [UIColor colorWithHex:0x000000];
    
    dayView.backgroundColor = [UIColor colorWithHex:0xeae7e4];
    dayView.layer.borderColor = [[UIColor blackColor] CGColor];
    dayView.layer.borderWidth = 1.0;
    dayView.layer.cornerRadius = 0.0;
    
    dayLabel.font = [UIFont fontWithName:KSWFontNameUnivers47 size:20.0];
    dayLabel.textColor = [UIColor colorWithHex:0x000000];
    
    yearView.backgroundColor = [UIColor colorWithHex:0x000000];
    yearView.layer.borderColor = [[UIColor blackColor] CGColor];
    yearView.layer.borderWidth = 1.0;
    yearView.layer.cornerRadius = 0.0;
    
    
    yearLabel.font = [UIFont fontWithName:KSWFontNameUnivers47 size:20.0];
    yearLabel.textColor = [UIColor colorWithHex:0x000000];
    
    slashOne.font = [UIFont fontWithName:KSWFontNameUnivers47 size:20.0];
    slashOne.textColor = [UIColor colorWithHex:0x5f5b54];
    
    slashTwo.font = [UIFont fontWithName:KSWFontNameUnivers47 size:20.0];
    slashTwo.textColor = [UIColor colorWithHex:0x5f5b54];
    
    // Set up Date Picker Window
    datePickerView.hidden = YES;
    self.datePickerViewPresent = YES;
    datePickerView.tag = 5;
    UIWindow *win = [[UIApplication sharedApplication] keyWindow];
    [win addSubview:datePickerView];
    
    
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    
    self.keyboardDoneButtonView.barStyle = UIBarStyleBlack;
    self.keyboardDoneButtonView.translucent = YES;
    self.keyboardDoneButtonView.tintColor = nil;
    
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(closePicker:)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(clearPicker:)];
    
    NSString *reqSysVer = @"7.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending) {
        doneButton.tintColor = [UIColor whiteColor];
        cancelButton.tintColor = [UIColor whiteColor];
    }
    
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton,flex, cancelButton, nil]];
    datePickerView.frame = CGRectMake(0, (win.bounds.size.height - 260), win.frame.size.width, 260.0);
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        datePickerView.frame = CGRectMake(0, (win.bounds.size.height - 260.0), 768, 260.0);
    }
    
    fontsSet = YES;
}

- (void) removeUtilityButtonViewFromSuperView {
    self.datePickerView.hidden = YES;
}

-(NSString*)getHintText {
    NSString* dateRange = [self getMinMaxDateRangeForHint];
    if(!dateRange || [dateRange isEqualToString:@""])
        return @"Select Date";
    
    return dateRange;
}

-(void) validateForDaysRemaining {
    if(!self.currentAudit)
        return;
        
  BOOL isValidForDaysRemaining = [self.currentAudit validateDaysRemainingMinConditionForRating:self.rating forProduct:self.currentAudit.product];
        if(!isValidForDaysRemaining){
            //show message in baseLocalTableViewCell
            [self.message setText:@"Date validation failed"];
        }else{
            [self.message setText:@""];
        }
}

-(NSString*)getMinMaxDateRangeForHint {
    Product* product =self.currentAudit.product;
    Rating *rating =self.rating;
    
    DaysRemainingValidator *daysRemainingValidator = [[DaysRemainingValidator alloc] initWithRating:rating withProduct:product];
    
    //validation not required
    if((product.daysRemaining == 0 && product.daysRemainingMax == 0) || !([daysRemainingValidator isCheckRequiredForRating]))
        return @"";
    
    return [daysRemainingValidator getDateRange];
}

- (void)refreshState
{
    [super refreshState];
    [self addAdditionalButtons];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeUtilityButtonViewFromSuperView) name:@"RemoveUtilityView" object:nil];
    
    if (!fontsSet) {
        [self configureFonts];
    }
    
    //set default label
   // monthLabel.text = [self getHintText]; //support dynamic range
    self.dateLabel.placeholder = [self getHintText]; //support dynamic range
    
    @try{
    if (![self.rating.ratingAnswerFromUI isEqualToString:@""] && self.rating.ratingAnswerFromUI) {
        NSString *dateString = self.rating.ratingAnswerFromUI;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM/dd/yyyy"];
        NSDate *dateFromString = [dateFormatter dateFromString:dateString];
        [datePicker setDate:dateFromString];
        
        //convert mm/dd/yyyy to locale
        datePicker.timeZone = [NSTimeZone localTimeZone];
        NSDateFormatter *df = [[NSDateFormatter alloc]init];
        [df setDateStyle:NSDateFormatterMediumStyle];
        NSString *str = [df stringFromDate:[datePicker date]];
        //monthLabel.text = str;
        dateLabel.text = str;
    }
    
    if (dateSetOnce) {
        NSCalendar *theCalender = [datePicker calendar];
        
        //NSDateComponents* components = [theCalender components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[datePicker date]]; // Get necessary date components
        //convert mm/dd/yyyy to locale
        datePicker.timeZone = [NSTimeZone localTimeZone];
        NSDateFormatter *df = [[NSDateFormatter alloc]init];
        [df setDateStyle:NSDateFormatterMediumStyle];
        NSString *str = [df stringFromDate:[datePicker date]];
        //monthLabel.text = str;
        dateLabel.text = str;
        
        //monthLabel.text = [NSString stringWithFormat:@"%ld", (long)[components month]];
        //dayLabel.text = [NSString stringWithFormat:@"%ld", (long)[components day]];
        //yearLabel.text = [NSString stringWithFormat:@"%ld", (long)[components year]];
        
    } /*else {
        monthLabel.text = @"Select Date";
        //dayLabel.text = @"D";
        //yearLabel.text = @"Y";
    }*/
    if (![self.rating.ratingAnswerFromUI isEqualToString:@""] && self.rating.ratingAnswerFromUI) {
        NSString *dateString = self.rating.ratingAnswerFromUI;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM/dd/yyyy"];
        NSDate *dateFromString = [dateFormatter dateFromString:dateString];
        [datePicker setDate:dateFromString];
        NSCalendar *theCalender = [datePicker calendar];
        
        //NSDateComponents* components = [theCalender components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[datePicker date]]; // Get necessary date components
        
        //convert mm/dd/yyyy to locale
       /* datePicker.timeZone = [NSTimeZone localTimeZone];
        NSDateFormatter *df = [[NSDateFormatter alloc]init];
        [df setDateStyle:NSDateFormatterMediumStyle];
        NSString *str = [df stringFromDate:[datePicker date]];
        monthLabel.text = str; */
        
        ///monthLabel.text = [NSString stringWithFormat:@"%ld", (long)[components month]];
        //dayLabel.text = [NSString stringWithFormat:@"%ld", (long)[components day]];
        //yearLabel.text = [NSString stringWithFormat:@"%ld", (long)[components year]];
        
    }
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.reason);
    }
    
    [self validateForDaysRemaining];
    
}

- (BOOL)validate
{
    return [super validate];
}


- (NSString*)theAnswerAsString
{
    if (dateSetOnce || (self.rating.ratingAnswerFromUI && ![self.rating.ratingAnswerFromUI isEqualToString:@""])) {
        NSCalendar *theCalender = [datePicker calendar];
        NSDateComponents* components = [theCalender components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[datePicker date]];
        return [NSString stringWithFormat:@"%ld/%ld/%ld", (long)[components month], (long)[components day], (long)[components year]];
    }
    
    return nil;
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
    if (!datePickerView.hidden) {
        [self closePicker:nil];
    }
}

-(void)launchDatePicker
{
    
    if (self.myTableViewController &&
        [self.myTableViewController isKindOfClass:[ProductRatingViewController class]]) {
        [(ProductRatingViewController*)self.myTableViewController tellOtherQuestionsToCloseKeyboard:self.rating];
    } else if (self.myTableViewController &&
        [self.myTableViewController isKindOfClass:[HPTCaseCodeViewController class]]) {
        [(HPTCaseCodeViewController*)self.myTableViewController tellOtherQuestionsToCloseKeyboard:self.rating];
    }
    datePickerView.hidden = NO;
    //[self.myTableView setContentOffset:self.myTableView.contentOffset animated:NO];
}

- (IBAction) launchPicker:(id)sender {
   
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(self.questionNumber - 1) inSection:0];
    CGRect rectInTableView = [self.myTableView rectForRowAtIndexPath:indexPath];
    
    [self.myTableView scrollRectToVisible:CGRectMake(0, rectInTableView.origin.y + 100, self.myTableView.frame.size.width, self.myTableView.frame.size.height) animated:YES];
    [self.myTableView setContentOffset:self.myTableView.contentOffset animated:NO];
    [self launchDatePicker];
    
    
}

- (IBAction)closePicker:(id)sender
{
    datePickerView.hidden = YES;
    
    dateSetOnce = YES;
    //fix the date change issue DI-1671
    self.rating.ratingAnswerFromUI = [self theAnswerAsString];
    [self refreshState];
    
    if (validatedOnce) {
        [self validate];
    }
}
- (IBAction)clearPicker:(id)sender
{
    datePickerView.hidden = YES;
    
    self.dateLabel.text = @"";
}
- (void) scannableButtonTouched {
    
}


//get date range to show in the hint
-(BOOL) validateDaysRemainingMinConditionForRating:(Rating*)rating forProduct:(Product*)product{
    
    return YES;
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

@end
