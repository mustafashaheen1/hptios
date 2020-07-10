//
//  LocationRatingViewCell.m
//  Insights
//
//  Created by Mustafa Shaheen on 7/1/20.
//  Copyright © 2020 Yottamark. All rights reserved.
//

#import "LocationRatingViewCell.h"

@implementation LocationRatingViewCell

@synthesize selectOptionButton;
@synthesize comboItems;
@synthesize poplistview;
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
    return (120 + questionViewHeight);
}

#pragma mark - Refresh state Method

- (void)configureFonts
{
    [super configureFonts];
    
    fontsSet = YES;
    self.selectOptionButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.selectOptionButton.layer.borderWidth = 1.0;
    self.selectOptionButton.layer.borderColor = [[UIColor blackColor] CGColor];
    self.selectOptionButton.layer.cornerRadius = 1.0;
    //self.selectOptionButton.frame = CGRectMake(20, 2, 280, 38);
}

- (void) addAdditionalButtons {
    [super addAdditionalButtons];
}

- (void)refreshState
{
    [super refreshState];
    [self addAdditionalButtons];
    self.cellTitle = @"selectOptionButton";
    self.comboItems = [[NSMutableArray alloc] init];
    self.comboItemsGlobal = [[NSMutableArray alloc] init];
    NSString *orderDataField = self.rating.order_data_field;

    [self.comboItemsGlobal addObjectsFromArray:self.rating.content.locationRatingModel.comboItems];
    self.comboItems = self.comboItemsGlobal;


    /* UIWindow *win = [[UIApplication sharedApplication] keyWindow];
     [win addSubview:utilityButtonView];
     
     utilityButtonView.frame = CGRectMake(0, (win.bounds.size.height - 260.0), (win.bounds.size.width), 44.0);*/
    
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
     self.utilityButtonView.tintColor = nil;*/
    
    if (!fontsSet) {
        [self configureFonts];
    }
    if (self.rating.ratingAnswerFromUI && ![self.rating.ratingAnswerFromUI isEqualToString:@""]) {
        self.selectLabel.text = [NSString stringWithFormat:@"%@", self.rating.ratingAnswerFromUI];
    } else {
        self.selectLabel.text = [NSString stringWithFormat:@"Select Option"];
    }
    if (![self.rating.ratingAnswerFromUI isEqualToString:@""] && self.rating.ratingAnswerFromUI) {

            self.selectLabel.text = self.rating.ratingAnswerFromUI;

    } else {
        self.selectLabel.text = @"Select Option";
    }
    
    self.selectOptionButton.enabled = YES;
    
    
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneTap)];
    
    UIBarButtonItem *clearButton = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStyleBordered target:self action:@selector(clearTap)];
    
    NSString *reqSysVer = @"7.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending) {
        doneButton.tintColor = [UIColor whiteColor];
        clearButton.tintColor = [UIColor whiteColor];
    }
    
    UIToolbar* keyboardToolbar = [[UIToolbar alloc] init];
    [keyboardToolbar sizeToFit];
    UIBarButtonItem *flexBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                      target:nil action:nil];
    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                      target:self action:@selector(doneTap)];
    keyboardToolbar.items = @[flexBarButton, doneBarButton];
}
- (NSString*)theAnswerAsString
{
    NSString *theAnswer = @"";
 
    
    NSMutableArray *optionsArray = [[NSMutableArray alloc] init];
    [optionsArray addObjectsFromArray:self.comboItems];
    for (int i = 0; i < [optionsArray count]; i++) {
        if (self.selectLabel && [self.selectLabel.text isEqualToString:[optionsArray objectAtIndex:i]]) {
            theAnswer = [NSString stringWithFormat:@"%@", [optionsArray objectAtIndex:i]];
        }
    }
    
    return theAnswer;
}

- (IBAction)bringTheOptions:(UIButton *)sender {
    [self.comboItemsGlobal addObjectsFromArray:self.rating.content.locationRatingModel.comboItems];
    self.comboItems = self.comboItems;
    [self selectOptions:self.comboItems withTitle:@"  Select Option"];
}
- (void)prepareForReuse
{
    [super prepareForReuse];
}

- (void) selectOptions: (NSArray *) comboItemsLocal withTitle: (NSString *) title {
    CGFloat xWidth = self.myTableViewController.view.frame.size.width - 20.0f;
    CGFloat yHeight = popupDefaultHeight;
    if ([comboItemsLocal count] < 5) {
        int heightAfterCalculation = ([comboItemsLocal count]+1) * 60.0f; //+1 to accomodate the Other
        heightAfterCalculation = heightAfterCalculation + 40;
        yHeight = heightAfterCalculation;
    }
    CGFloat yOffset = (self.myTableViewController.view.frame.size.height - yHeight)/2.0f;
    
    BOOL refreshButtonNeeded = NO;
    if ([self.comboItems count] > 1) {
        poplistview = [[UIPopoverListView alloc] initWithFrame:CGRectMake(10, yOffset, xWidth, yHeight) withTextField:YES isRefreshNeeded:refreshButtonNeeded];
    } else {
        poplistview = [[UIPopoverListView alloc] initWithFrame:CGRectMake(10, yOffset, xWidth, yHeight)];
    }
    
    [self.myTableViewController.view endEditing:YES]; //dismiss any keyboard thats open on the screen
    poplistview.delegate = self;
    poplistview.datasource = self;
    poplistview.listView.scrollEnabled = TRUE;
    poplistview.isNumeric = self.rating.is_numeric;
    
    [poplistview setTitle:title];
    [poplistview show];
}
  - (UITableViewCell *)popoverListView:(UIPopoverListView *)popoverListView
                    cellForIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"PopUpCell";

    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];

        NSString *item =[self.comboItems objectAtIndex:indexPath.row];
        //cell.textLabel.text = item;
        cell.textLabel.text = item;
        BOOL isDateRow = NO;
        //DI-1976 - show dates for PO numbers
        NSString *orderDataField = self.rating.order_data_field;
    return cell;
}
- (NSInteger)popoverListView:(UIPopoverListView *)popoverListView
       numberOfRowsInSection:(NSInteger)section
{
        return [self.comboItems count];
}
#pragma mark - UIPopoverListViewDelegate
- (void)popoverListView:(UIPopoverListView *)popoverListView
     didSelectIndexPath:(NSIndexPath *)indexPath
{
    self.selectLabel.text = [comboItems objectAtIndex:indexPath.row];
}
- (void)popoverListViewCancel:(UIPopoverListView *)popoverListView {
}

-(void)reset{
    self.comboItems = [[NSMutableArray alloc]init];
    self.comboItemsGlobal = [[NSMutableArray alloc]init];
}

- (CGFloat)popoverListView:(UIPopoverListView *)popoverListView
   heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //if PO Row with Date - increase height - DI-2073
    if (popoverListView == self.poplistview) {
        NSString *item =[self.comboItems objectAtIndex:indexPath.row];
        NSString *orderDataField = self.rating.order_data_field;
    }
    
    return 60.0f;
}
@end
