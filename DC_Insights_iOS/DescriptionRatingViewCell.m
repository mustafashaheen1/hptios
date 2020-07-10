//
//  DescriptionRatingViewCell.m
//  Insights
//
//  Created by Mustafa Shaheen on 6/29/20.
//  Copyright © 2020 Yottamark. All rights reserved.
//

#import "DescriptionRatingViewCell.h"
#import "ProductRatingViewController.h"
#import "HPTCaseCodeViewController.h"
#import "AppDelegate.h"
#import "ViewController.h"
#import "Inspection.h"
#import "CaseCodesTableViewCell.h"
@implementation DescriptionRatingViewCell

@synthesize theAnswer;
@synthesize caseCodesTableView;
@synthesize caseCodes;
@synthesize quantities;
- (id)init
{
    self = [super init];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.caseCodes = [[NSMutableArray alloc] init];
        self.quantities = [[NSMutableArray alloc] init];
    }
    
    
    return self;
}

+ (CGFloat) myCellHeight:(Rating*)theRating
{
    CGFloat questionViewHeight = [BaseTableViewCell myQuestionViewHeight:theRating];
    return (250 + questionViewHeight);
}

#pragma mark - Refresh state Method

- (void) addAdditionalButtons {
    theAnswer.delegate = self;
    [self setFrames];
    [super addAdditionalButtons];
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
    
    [theAnswer resignFirstResponder];
}

- (void)refreshState
{
    [super refreshState];
    [self addAdditionalButtons];

    if (!fontsSet) {
        [self configureFonts];
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
        [theAnswer resignFirstResponder];
    
}


- (void)passKeyboardIfOpen
{
        [theAnswer nextResponder];
    
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
    [theAnswer resignFirstResponder];
        
    if (validatedOnce) {
        [self validate];
    }
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.caseCodes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CaseCodesTableViewCell *newCell = [tableView dequeueReusableCellWithIdentifier:kCaseCodeViewCellReuseID];
    
    newCell.code.text = [self.caseCodes objectAtIndex:indexPath.row];
    [newCell.quantity setTitle:[self.quantities objectAtIndex:indexPath.row] forState:UIControlStateNormal];
    newCell.quantity.tag = indexPath.row;
    newCell.remove.tag = indexPath.row;
    [newCell.quantity addTarget:self action:@selector(changeQuantity:) forControlEvents:UIControlEventTouchUpInside];
    [newCell.remove addTarget:self action:@selector(removeCode:) forControlEvents:UIControlEventTouchUpInside];
    
    return newCell;
    
}
- (void) changeQuantity:(UIButton *) sender {
    
    UIAlertView* dialog = [[UIAlertView alloc] initWithTitle:@"Enter quantity for pallet tag" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [dialog setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [[dialog textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
    self.globalTag = sender.tag;
    //[[dialog textFieldAtIndex:0] setText:self.numberOfProductsInspected.text];
    [dialog setTag:2];
    [dialog show];
}

- (void) removeCode:(UIButton *) sender {
    
    [self.caseCodes removeObjectAtIndex:sender.tag];
    [self.caseCodesTableView reloadData];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == alertView.cancelButtonIndex) {
        //NSLog(@"cancelling inspection");
    }
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        NSString* valueEntered =[[alertView textFieldAtIndex:0] text];
        BOOL isEmpty =[valueEntered isEqualToString:@""] || [valueEntered integerValue]<=0;
        /*int countOfCasesEnteredByUser = self.countOfCasesEnteredByTheUser;
        int countOfCasesFromRating = [self.countOfCasesFromRatingValue integerValue];
        BOOL isGreaterThanCountOfCases = NO;
        if(countOfCasesFromRating>0)
            isGreaterThanCountOfCases = [valueEntered integerValue]>countOfCasesFromRating;
        else
            isGreaterThanCountOfCases = [valueEntered integerValue]>countOfCasesEnteredByUser;*/
        if(isEmpty)
             [[[UIAlertView alloc] initWithTitle:@"Quantity can't be 0 or empty" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        else if([valueEntered integerValue]>999)
            [[[UIAlertView alloc] initWithTitle:@"Quantity should be less than 999" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        /*else if(isGreaterThanCountOfCases)
             [[[UIAlertView alloc] initWithTitle:@"Inspection Samples should be less than the count of cases" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];*/
        else {
            //NSLog(@"cancelling inspection");
            [self.quantities setObject:[[alertView textFieldAtIndex:0] text] atIndexedSubscript:self.globalTag];
            [self.caseCodesTableView reloadData];
        }
    }
}
@end
