//
//  DefectsViewController.m
//  DC_Insights_iOS
//
//  Created by John Gifford on 11/13/13.
//  Copyright (c) 2013 Yottamark. All rights reserved.
//

#import "DefectsViewController.h"
#import "CellBuilder.h"
#import "DefectsViewCell.h"
#import "ProductSelectSectionInfo.h"
#import "Defect.h"
#import "SKSTableView.h"
#import "SKSTableViewCell.h"
#import "DefectsTableViewCell.h"
#import "Inspection.h"
#import "DivideEntryView.h"

#define DEFAULT_ROW_HEIGHT 200

static NSString *SectionHeaderViewIdentifier = @"RatingSelectSectionHeader";

@interface DefectsViewController ()

@end

@implementation DefectsViewController

@synthesize defectsTableView;
@synthesize defectsArray;
@synthesize openSectionIndex;
@synthesize tableData;
@synthesize sectionInfoArray;
@synthesize buttonSave;
@synthesize delegate;
@synthesize defectViewCells;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.divideEntryViews = [[NSMutableArray alloc] init];
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    self.severityCount = 0;
    self.globalDefectValues = @"";
    [super viewDidLoad];
    [self transparentBlackBGViewSetup];
    [self alertDefectEntryViewSetup];
    self.openSectionIndex = NSNotFound;
    
    self.defectViewCells = [[NSMutableDictionary alloc] init];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 130.0)];
    //[footerView addSubview:buttonSave];
    buttonSave.frame = CGRectMake(37.0, 20.0, 246.0, 37.0);
	self.defectsTableView.tableFooterView = footerView;
    
    self.defectsTableView.SKSTableViewDelegate = self;
    self.defectsTableView.shouldExpandOnlyOneCell = YES;
    self.defectsTableView.inspectionStatusViewController = YES;
    
        [self sortTheDefectsBasedOnTheGroupName];
}

-(void) addManualInfoNavigationItem{
    if(self.qualityManual){
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithCustomView:self.markButton],[[UIBarButtonItem alloc] initWithCustomView:self.productInfoButton], nil];
    }
}

- (void) productInfoButtonTouched {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveUtilityView" object:self];
    //if ([self checkIfManualPresent]) {
    WebViewForDefectsViewController *webView = [[WebViewForDefectsViewController alloc] initWithNibName:@"WebViewForDefectsViewController" bundle:nil];
    webView.qualityManual = self.qualityManual;
    [self.navigationController pushViewController:webView animated:YES];
}

- (void) sortTheDefectsBasedOnTheGroupName {
    //self.defectsArray = [[Inspection sharedInspection] groupDefects:self.defectsArray];
    self.defectsArray = [[NSArray alloc] init];
    [[Inspection sharedInspection] groupDefects:^(NSArray *array){
        if ([array count] > 0) {
            self.defectsArray = array;
            [self.defectsTableView reloadData];
        }
    } withDefects: self.defectsArrayLocal];
}

- (void) transparentBlackBGViewSetup {
    UIWindow *win = [[UIApplication sharedApplication] keyWindow];
    self.transparentBlackBGView = [[UIView alloc] initWithFrame:CGRectMake(win.bounds.origin.x, win.bounds.origin.y, win.bounds.size.width, win.bounds.size.height)];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.transparentBlackBGView.frame = CGRectMake(win.bounds.origin.x, win.bounds.origin.y, 768, 1024);
    }
    //NSLog(@"%f %f %f %f", self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
    self.transparentBlackBGView.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.5];
}

- (void) alertDefectEntryViewSetup {
    
    self.okAlertButton.layer.cornerRadius = 5.0;
    self.okAlertButton.layer.borderWidth = 1.0;
    self.okAlertButton.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    
    self.cancelAlertButton.layer.cornerRadius = 5.0;
    self.cancelAlertButton.layer.borderWidth = 1.0;
    self.cancelAlertButton.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    for(DivideEntryView *divideEntryView in self.divideEntryViews){
        [divideEntryView removeFromSuperview];
    }
    [self.divideEntryViews removeAllObjects];
    UIWindow *win = [[UIApplication sharedApplication] keyWindow];
    float height = self.severityCount * 100;
    self.alertDefectEntryView.frame = CGRectMake(30, 0, 260, 170 + height);
    
    self.okAlertButton.frame = CGRectMake(self.alertDefectEntryView.frame.size.width + self.alertDefectEntryView.frame.origin.x - 150, self.alertDefectEntryView.frame.origin.y + self.alertDefectEntryView.frame.size.height - 52, 100, 40);
    self.cancelAlertButton.frame = CGRectMake(self.alertDefectEntryView.frame.origin.x - 8, self.alertDefectEntryView.frame.origin.y + self.alertDefectEntryView.frame.size.height - 52, 100, 40);
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.alertDefectEntryView.frame = CGRectMake(250, 200, 260, 170 + height);
        self.okAlertButton.frame = CGRectMake(self.alertDefectEntryView.frame.origin.x - self.alertDefectEntryView.frame.size.width + 30, self.alertDefectEntryView.frame.size.height - 52, 100, 40);
        self.cancelAlertButton.frame = CGRectMake(self.alertDefectEntryView.frame.size.width - 120, self.alertDefectEntryView.frame.size.height - 52, 100, 40);
    } else if (IS_IPHONE5 || IS_IPHONE6) {
        self.alertDefectEntryView.frame = CGRectMake(50, 200, 260, 170 + height);
    }
    
    self.alertDefectEntryView.layer.cornerRadius = 5.0;
    [self.alertDefectEntryView setCenter:CGPointMake(self.transparentBlackBGView.bounds.size.width/2, self.transparentBlackBGView.bounds.size.height/2.5)];
    [self.transparentBlackBGView addSubview:self.alertDefectEntryView];

    
}

- (void) setupNavBar {
    [super setupNavBar];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.pageTitle = @"DefectsViewController";
    [self setupNavBar];
    [self addManualInfoNavigationItem];

    
    if ((self.sectionInfoArray == nil) ||
        ([self.sectionInfoArray count] != [self numberOfSectionsInTableView:self.defectsTableView])) {
        
        // For each play, set up a corresponding SectionInfo object to contain the default height for each row.
		NSMutableArray *infoArray = [[NSMutableArray alloc] init];
        
		for (Defect *defect in self.defectsArray) {
            
			ProductSelectSectionInfo *sectionInfo = [[ProductSelectSectionInfo alloc] init];
            sectionInfo.defect = defect;
			sectionInfo.open = NO;
            
            NSNumber *defaultRowHeight = @(DEFAULT_ROW_HEIGHT);
            NSInteger countOfSubProducts = 1;
            for (NSInteger i = 0; i < countOfSubProducts; i++) {
                [sectionInfo insertObject:defaultRowHeight inRowHeightsAtIndex:i];
            }
			[infoArray addObject:sectionInfo];
		}
        
		self.sectionInfoArray = infoArray;
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sectionHeaderView:(RatingSelectSectionHeader *)sectionHeaderView alertViewOpened:(NSIndexPath *)indexPath
{
    //NSLog(@"indexoath %d indexpathglobal %d", indexPath.row, self.indexPathOpenedForAlertView.row);
    [self.defectsTableView collapseCurrentlyExpandedIndexPaths];
    RatingSelectSectionHeader *cell = (RatingSelectSectionHeader *)[self.defectsTableView cellForRowAtIndexPath:indexPath];
    NSDictionary *dict = [self.defectsArray objectAtIndex:indexPath.section];
    NSArray *array = [dict allValues];
    NSMutableArray *defects = [NSMutableArray arrayWithArray:[array objectAtIndex:0]];
    Defect *defect = (Defect *)[defects objectAtIndex:indexPath.row];
    self.severityButtonLabelText = @"";
    //Defect *defect = (Defect *)[self.defectsArray objectAtIndex:indexPath.row];
    self.indexPathOpenedForAlertView = indexPath;
    //NSLog(@"indexoath %d indexpathglobal %d", indexPath.row, self.indexPathOpenedForAlertView.row);
    self.defectAlertLabel.text = defect.name;
    self.percentageTextField.text = @"";
    if (![defect.coverage_type isEqualToString:@"Boolean"]) {
        if ([defect.severities count] == 1) {
            Severity *aSeverity = [defect.severities objectAtIndex:0];
            self.severityButtonLabelText = [NSString stringWithFormat:@"%@", aSeverity.name];
        }
        if ([defect.coverage_type isEqualToString:@"Percentage"]) {
            self.severityCount = 0;
            [self alertDefectEntryViewSetup];
            if (defect.isSetFromUI) {
                for(Severity *tempSeverity in defect.severities)
                {
                    self.percentageTextField.text = [NSString stringWithFormat:@"%.2f", tempSeverity.inputOrCalculatedPercentage];
                    self.severityButtonLabelText = [NSString stringWithFormat:@"%@", tempSeverity.name];
                }
            }
            [self.percentageTextField becomeFirstResponder]; //show up keyboard automatically
            [self percentageEntryViewSetup];
        } else {
            self.severityCount = defect.severities.count;
            [self alertDefectEntryViewSetup];
            if (defect.isSetFromUI) {
                
                int yCordinate = 50;
                for(Severity *tempSeverity in defect.severities){
                    DivideEntryView *divideEntryView = [[NSBundle mainBundle] loadNibNamed:@"DivideEntryView" owner:self options:nil].firstObject;
                    divideEntryView.severityNameLabel.text = tempSeverity.name;
                    if(tempSeverity.inputNumerator > 0){
                     divideEntryView.leftDivideTextField.text = [[NSNumber numberWithFloat:tempSeverity.inputNumerator] stringValue];
                        divideEntryView.rightDivideTextField.text = [[NSNumber numberWithFloat:tempSeverity.inputDenominator] stringValue];
                    }else{
                        divideEntryView.leftDivideTextField.text = @"";
                        divideEntryView.rightDivideTextField.text = @"";
                    }
                    [divideEntryView loadView];
                    [self.divideEntryViews addObject:divideEntryView];
                    divideEntryView.frame = CGRectMake(20, yCordinate, 220, 125);
                    yCordinate += 125;
                    [self.alertDefectEntryView addSubview:divideEntryView];
                    self.severityButtonLabelText = [NSString stringWithFormat:@"%@", tempSeverity.name];
                }
                 
            }else{
                 int yCordinate = 50;
                for(Severity *tempSeverity in defect.severities){
                    DivideEntryView *divideEntryView = [[NSBundle mainBundle] loadNibNamed:@"DivideEntryView" owner:self options:nil].firstObject;
                    divideEntryView.severityNameLabel.text = tempSeverity.name;
                    divideEntryView.leftDivideTextField.text = @"";
                    divideEntryView.rightDivideTextField.text = @"";
                    divideEntryView.percentageLabel.text = @"";
                    [divideEntryView loadView];
                    [self.divideEntryViews addObject:divideEntryView];
                    divideEntryView.frame = CGRectMake(20, yCordinate, 220, 125);
                    yCordinate += 125;
                    [self.alertDefectEntryView addSubview:divideEntryView];
                }
                
            }
        }
        NSString *sectionRow = [NSString stringWithFormat:@"%d|%d", indexPath.section, indexPath.row];
        RatingSelectSectionHeader *existingCell = [self.defectViewCells objectForKey:sectionRow];
        if (existingCell) {
            if (existingCell.globalSeverities.count > 0) {
                 NSString *tempString = @"";
                 for(Severity *tempSeverity in existingCell.globalSeverities){
                     
                     NSString *temp3 = [NSString stringWithFormat:@"%@\n", tempSeverity.name];
                     tempString = [tempString stringByAppendingString:temp3];
                 }
                 
                  self.severityButtonLabelText = [NSString stringWithFormat:@"%@", tempString];
            }
            if ([existingCell.coverageType isEqualToString:@"Percentage"]) {
                NSString *tempString = @"";
                for(Severity *tempSeverity in existingCell.globalSeverities){
                    
                    if(tempSeverity.inputOrCalculatedPercentage > 0)
                    {
                    NSString *temp3 = [NSString stringWithFormat:@"%.2f", tempSeverity.inputOrCalculatedPercentage];
                    tempString = [tempString stringByAppendingString:temp3];
                    }
                }
                self.percentageTextField.text = [NSString stringWithFormat:@"%@", tempString];
            } else if ([existingCell.coverageType isEqualToString:@"Numerator/Denominator"]){
                for(Severity *tempSeverity in existingCell.globalSeverities){
                    
                    if(tempSeverity.inputNumerator > 0 && tempSeverity.inputDenominator > 0){
                        for(DivideEntryView *divideEntryView in self.divideEntryViews){
                        if(tempSeverity.name == divideEntryView.severityNameLabel.text){
                            divideEntryView.leftDivideTextField.text = [NSString stringWithFormat:@"%.2f", tempSeverity.inputNumerator];
                            divideEntryView.rightDivideTextField.text = [NSString stringWithFormat:@"%.2f", tempSeverity.inputDenominator];
                            divideEntryView.calculatePercentage;
                        }
                        }
                    }
                }
                
            }
        }
         UIWindow *win = [[UIApplication sharedApplication] keyWindow];
        [win addSubview:self.transparentBlackBGView];
    } else {
        NSString *sectionRow = [NSString stringWithFormat:@"%d|%d", indexPath.section, indexPath.row];
        [self.defectViewCells setObject:cell forKey:sectionRow];
    }
}


- (void)sectionHeaderView:(RatingSelectSectionHeader *)sectionHeaderView alertViewClosed:(NSIndexPath *)indexPath
{
    RatingSelectSectionHeader *cell = (RatingSelectSectionHeader *)[self.defectsTableView cellForRowAtIndexPath:indexPath];
    NSDictionary *dict = [self.defectsArray objectAtIndex:indexPath.section];
    NSArray *array = [dict allValues];
    NSMutableArray *defects = [NSMutableArray arrayWithArray:[array objectAtIndex:0]];
    Defect *defect = (Defect *)[defects objectAtIndex:indexPath.row];
    //Defect *defect = (Defect *)[self.defectsArray objectAtIndex:indexPath.row];
    if (![defect.coverage_type isEqualToString:@"Boolean"]) {
        cell.defectValuesButton.hidden = YES;
        cell.defectValuesLabel.hidden = YES;
        [self.transparentBlackBGView removeFromSuperview];
    }
    if (!cell.checked) {
        cell.defect.isSetFromUI = NO;
        NSString *sectionRow = [NSString stringWithFormat:@"%d|%d", indexPath.section, indexPath.row];
        [self.defectViewCells setObject:cell forKey:sectionRow];
    }
    
    [self.percentageTextField resignFirstResponder];
   // [self.leftDivideTextField resignFirstResponder];
}

- (IBAction) cancelButtonTouched:(id)sender {
    //NSLog(@"indexoathgloabla %d", self.indexPathOpenedForAlertView.row);
    RatingSelectSectionHeader *cell = (RatingSelectSectionHeader *)[self.defectsTableView cellForRowAtIndexPath:self.indexPathOpenedForAlertView];
    cell.defectValuesButton.hidden = YES;
    cell.defectValuesLabel.hidden = YES;
    for(Severity *sev in cell.globalSeverities){
        sev.inputDenominator = 0.0;
        sev.inputNumerator = 0.0;
        sev.inputOrCalculatedPercentage = 0.0;
    }
    [cell toggleCheckMarkOpenWithUserAction:YES];
    
}

- (IBAction) okButtonTouched:(id)sender {
    self.globalDefectValues = @"";
    RatingSelectSectionHeader *cell = (RatingSelectSectionHeader *)[self.defectsTableView cellForRowAtIndexPath:self.indexPathOpenedForAlertView];
    NSDictionary *dict = [self.defectsArray objectAtIndex:self.indexPathOpenedForAlertView.section];
    NSArray *array = [dict allValues];
    NSMutableArray *defects = [NSMutableArray arrayWithArray:[array objectAtIndex:0]];
    Defect *defect = (Defect *)[defects objectAtIndex:self.indexPathOpenedForAlertView.row];
    NSLog(@"%@", [self.severityButtonLabelText lowercaseString]);
        if ([defect.coverage_type isEqualToString:@"Percentage"]) {
            if ([self.percentageTextField.text isEqualToString:@""]) {
                [[[UIAlertView alloc] initWithTitle: @"Missing Values" message: @"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            } else if(![self isValidNumber:self.percentageTextField.text]){
                [[[UIAlertView alloc] initWithTitle: @"Enter Numeric Value" message: @"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }else if([self.percentageTextField.text floatValue] <= 0){
                [[[UIAlertView alloc] initWithTitle: @"Percentage cannot be 0" message: @"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }else {
                Severity *tempSeverity = [[Severity alloc] init];
                cell.defectValuesButton.hidden = NO;
                cell.defectValuesLabel.hidden = NO;
                tempSeverity.name = self.severityButtonLabelText;
                NSString *tempPercentage = self.percentageTextField.text;
                tempSeverity.inputOrCalculatedPercentage = [tempPercentage floatValue];
                [cell.globalSeverities removeAllObjects];
                [cell.globalSeverities addObject:tempSeverity];
                [cell.defectValuesLabel setText:[NSString stringWithFormat:@"%@%% %@", self.percentageTextField.text, self.severityButtonLabelText]];
                [self.transparentBlackBGView removeFromSuperview];
            }
        } else {
            int missingCount = 0;
            int i = 0;
            for(DivideEntryView *divideEntryView in self.divideEntryViews){
                if ([divideEntryView.leftDivideTextField.text isEqualToString:@""] || [divideEntryView.rightDivideTextField.text isEqualToString:@""]) {
                    missingCount += 1;
                    //if(cell.globalSeverities.count == i + 1){
                    if((cell.globalSeverities.count > 0) && (i < cell.globalSeverities.count))
                        [cell.globalSeverities removeObjectAtIndex:i];
                   // }
                }
                else{
                if ([divideEntryView.leftDivideTextField.text floatValue] > [divideEntryView.rightDivideTextField.text floatValue]) {
                    [[[UIAlertView alloc] initWithTitle: @"Incorrect Ratio" message: @"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                }else if(![self isValidNumber:divideEntryView.leftDivideTextField.text] || ![self isValidNumber:divideEntryView.rightDivideTextField.text]){
                    [[[UIAlertView alloc] initWithTitle: @"Enter Numeric Value" message: @"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                }else {
                        cell.defectValuesButton.hidden = NO;
                        cell.defectValuesLabel.hidden = NO;
                        Severity *tempSeverity = [[Severity alloc] init];
                        tempSeverity.name = divideEntryView.severityNameLabel.text;//self.selectSeverityAlertButton.titleLabel.text;
                        tempSeverity.inputNumerator = [divideEntryView.leftDivideTextField.text floatValue];
                        tempSeverity.inputDenominator = [divideEntryView.rightDivideTextField.text floatValue];
                        tempSeverity.inputOrCalculatedPercentage = [divideEntryView calculatePercentage];
                    BOOL found = NO;
                    for(Severity *tempSeverity2 in cell.globalSeverities){
                        if(tempSeverity2.name == tempSeverity.name){
                            tempSeverity2.inputDenominator = tempSeverity.inputDenominator;
                            tempSeverity2.inputNumerator = tempSeverity.inputNumerator;
                            tempSeverity2.inputOrCalculatedPercentage = tempSeverity.inputOrCalculatedPercentage;
                            found = YES;
                        }
                    }
                    if(found == NO){
                        [cell.globalSeverities addObject:tempSeverity];
                    }
                        NSString *temp2 = [NSString stringWithFormat:@"%@ / %@ (%.2f%%) %@ ", divideEntryView.leftDivideTextField.text, divideEntryView.rightDivideTextField.text, [divideEntryView calculatePercentage], divideEntryView.severityNameLabel.text];
                        self.globalDefectValues = [self.globalDefectValues stringByAppendingString:temp2];
                    
                    [self.transparentBlackBGView removeFromSuperview];
                
                    [cell.defectValuesLabel setText:self.globalDefectValues];
                    
                }
            }
                i += 1;
            }
                if(missingCount == self.divideEntryViews.count){
                    [[[UIAlertView alloc] initWithTitle: @"Missing Values" message: @"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                }
        }
    
    NSString *sectionRow = [NSString stringWithFormat:@"%d|%d", self.indexPathOpenedForAlertView.section, self.indexPathOpenedForAlertView.row];
    if (cell) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            cell.defectValuesButton.frame = CGRectMake(cell.bounds.size.width - 250, cell.bounds.origin.y, 250, cell.bounds.size.height);
            cell.defectValuesLabel.frame = CGRectMake(cell.bounds.size.width - 250, cell.bounds.origin.y, 250, cell.bounds.size.height);
            [cell.defectValuesLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:12]];
        }else{
        cell.defectValuesButton.frame = CGRectMake(cell.bounds.size.width - 200, cell.bounds.origin.y, 200, cell.bounds.size.height);
        cell.defectValuesLabel.frame = CGRectMake(cell.bounds.size.width - 200, cell.bounds.origin.y, 200, cell.bounds.size.height);
        [cell.defectValuesLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:12]];
        }
        [self.defectViewCells setObject:cell forKey:sectionRow];
    }
}

-(BOOL)isValidNumber:(NSString*)text{
    //NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *nonNumberSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
    NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:text];
    BOOL valid = [nonNumberSet isSupersetOfSet:inStringSet];
    return valid;
}





- (void) resignFirstResponders {
    [self.percentageTextField resignFirstResponder];
   // [self.leftDivideTextField resignFirstResponder];
   // [self.rightDivideTextField resignFirstResponder];
}

#pragma mark - UIPopoverListViewDataSource

- (UITableViewCell *)popoverListView:(UIPopoverListView *)popoverListView
                    cellForIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    NSDictionary *dict = [self.defectsArray objectAtIndex:self.indexPathOpenedForAlertView.section];
    NSArray *array = [dict allValues];
    NSMutableArray *defects = [NSMutableArray arrayWithArray:[array objectAtIndex:0]];
    Defect *defect = (Defect *)[defects objectAtIndex:self.indexPathOpenedForAlertView.row];

    //Defect *defect = (Defect *)[self.defectsArray objectAtIndex:self.indexPathOpenedForAlertView.row];
    [defect.severities objectAtIndex:indexPath.row];
    if ([defect.severities count] >0) {
        Severity *severity = [defect.severities objectAtIndex:indexPath.row];
        cell.textLabel.text = severity.name;
    }
    return cell;
}

- (NSInteger)popoverListView:(UIPopoverListView *)popoverListView
       numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *dict = [self.defectsArray objectAtIndex:self.indexPathOpenedForAlertView.section];
    NSArray *array = [dict allValues];
    NSMutableArray *defects = [NSMutableArray arrayWithArray:[array objectAtIndex:0]];
    Defect *defect = (Defect *)[defects objectAtIndex:self.indexPathOpenedForAlertView.row];

    //Defect *defect = (Defect *)[self.defectsArray objectAtIndex:self.indexPathOpenedForAlertView.row];
    return [defect.severities count];
}

#pragma mark - UIPopoverListViewDelegate
- (void)popoverListView:(UIPopoverListView *)popoverListView
     didSelectIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [self.defectsArray objectAtIndex:self.indexPathOpenedForAlertView.section];
    NSArray *array = [dict allValues];
    NSMutableArray *defects = [NSMutableArray arrayWithArray:[array objectAtIndex:0]];
    Defect *defect = (Defect *)[defects objectAtIndex:self.indexPathOpenedForAlertView.row];

    //Defect *defect = (Defect *)[self.defectsArray objectAtIndex:self.indexPathOpenedForAlertView.row];
    if ([defect.severities count] > 0) {
        Severity *severity = [defect.severities objectAtIndex:indexPath.row];
        self.severityButtonLabelText = severity.name;
    }
}

- (CGFloat)popoverListView:(UIPopoverListView *)popoverListView
   heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (void) percentageEntryViewSetup {
    self.percentageEntryView.frame = CGRectMake(20, 50, 220, 42);
    [self.alertDefectEntryView addSubview:self.percentageEntryView];
}


//<100 = Around x% of your sample
// > 100 - Exceeds 100%

#pragma mark - UITableViewDataSource

- (UIView *)tableView:(SKSTableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    //    RatingSelectSectionHeader *sectionHeaderView = [self.defectsTableView dequeueReusableHeaderFooterViewWithIdentifier:SectionHeaderViewIdentifier];
    //
    //    ProductSelectSectionInfo *sectionInfo = (self.sectionInfoArray)[section];
    //    sectionHeaderView.defectValuesButton.hidden = YES;
    //    sectionHeaderView.defectValuesLabel.hidden = YES;
    //    sectionInfo.headerViewRating = sectionHeaderView;
    //
    //    sectionHeaderView.titleLabel.text = sectionInfo.defect.name;
    //    sectionHeaderView.section = section;
    //    sectionHeaderView.delegate = self;
    
    UIView *sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    sectionHeaderView.backgroundColor = [UIColor darkGrayColor];
    
    NSDictionary *dict;
    if ([self.defectsArray count] > 0) {
        dict = [self.defectsArray objectAtIndex:section];
    }
    NSArray *keys;
    NSString *sectionName = @"";
    if ([[dict allValues] count] > 0) {
        keys = [[dict allValues] objectAtIndex:0];
    }
    if ([keys count] > 0) {
        Defect *defect = [keys objectAtIndex:0];
        sectionName = defect.defectGroupName;
    }
    UILabel *nameOftheGroup = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, self.view.frame.size.width, 44)];
    nameOftheGroup.text = sectionName;
    nameOftheGroup.textColor = [UIColor whiteColor];
    nameOftheGroup.backgroundColor = [UIColor clearColor];
    nameOftheGroup.font = [UIFont fontWithName:@"Helvetica" size:16.0];
    [sectionHeaderView addSubview:nameOftheGroup];
    
    return sectionHeaderView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.defectsArray count];
}

- (NSInteger)tableView:(SKSTableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.defectsArray count] > 0) {
        NSDictionary *dict = [self.defectsArray objectAtIndex:section];
        NSArray *array = [dict allValues];
        NSMutableArray *defects = [NSMutableArray arrayWithArray:[array objectAtIndex:0]];
        return [defects count];
    }
    return 0;
}

- (NSInteger)tableView:(SKSTableView *)tableView numberOfSubRowsAtIndexPath:(NSIndexPath *)indexPath
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *sectionRow1 = [NSString stringWithFormat:@"%d|%d", indexPath.section, indexPath.row];
    id existingCell = [self.defectViewCells objectForKey:sectionRow1];
    if (existingCell && existingCell != [NSNull null]) {
        return (RatingSelectSectionHeader *)existingCell;
    }

    RatingSelectSectionHeader *cell = [tableView dequeueReusableCellWithIdentifier:nil];
    if(cell==nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"RatingSelectSectionHeader" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.delegate = self;
    cell.expandable = YES;
    cell.indexPath = indexPath;
    
    NSDictionary *dict = [self.defectsArray objectAtIndex:indexPath.section];
    NSArray *array = [dict allValues];
    NSMutableArray *defects = [NSMutableArray arrayWithArray:[array objectAtIndex:0]];
    Defect *defect = (Defect *)[defects objectAtIndex:indexPath.row];

    cell.defect = defect;
    cell.titleLabel.text = defect.name;
    if (defect.display && ![defect.display isEqualToString:@""]) {
        cell.titleLabel.text = defect.display;
    }
    cell.titleLabel.numberOfLines = 2;
    cell.coverageType = defect.coverage_type;
    NSArray *severities = defect.severities;
    NSString *sevLabelAppend = @"";
    for (int i=0; i < [severities count]; i++) {
        Severity *sev = [severities objectAtIndex:i];
        if (i == 0) {
            sevLabelAppend = [sevLabelAppend stringByAppendingString:sev.name];
        } else {
            sevLabelAppend = [sevLabelAppend stringByAppendingString:@", "];
            sevLabelAppend = [sevLabelAppend stringByAppendingString:sev.name];
        }
    }
    cell.severityLabel.text = sevLabelAppend;
//    if ([[sevLabelAppend lowercaseString] isEqualToString:@"major"]) {
//        cell.severityLabel.textColor = [UIColor redColor];
//    } else if ([[sevLabelAppend lowercaseString] isEqualToString:@"minor"]) {
//        cell.severityLabel.textColor = [UIColor greenColor];
//    }
    
    if (!defect.isSetFromUI) {
        cell.defectValuesButton.hidden = YES;
        cell.defectValuesLabel.hidden = YES;
    }
    
    if (defect.isSetFromUI) {
        cell.globalSeverities = defect.severities;
        cell.checkMarkButton.selected = !cell.checkMarkButton.selected;
        cell.checked = YES;
        [cell.checkMarkButton setImage:[UIImage imageNamed:@"checkBoxMarked.png"] forState:UIControlStateSelected];
        if ([cell.defect.coverage_type isEqualToString:@"Percentage"]) {
            NSString *severityString = @"";
            for(Severity *severity in defect.severities){
                if(severity.inputOrCalculatedPercentage != 0){
                    NSString *temp = [NSString stringWithFormat:@"%.2f%% \n %@", severity.inputOrCalculatedPercentage, severity.name];
                    severityString = [severityString stringByAppendingString:temp];
                }
            }
            [cell.defectValuesLabel setText:severityString];
        } else if ([cell.defect.coverage_type isEqualToString:@"Boolean"]) {
            cell.defectValuesButton.hidden = YES;
            cell.defectValuesLabel.hidden = YES;
        } else {
            NSString *severityString = @"";
            for(Severity *severity in defect.severities){
                if(severity.inputOrCalculatedPercentage != 0){
                    NSString *temp = [NSString stringWithFormat:@"%.2f / %.2f (%.2f%%) \n %@", severity.inputNumerator, severity.inputDenominator, severity.inputOrCalculatedPercentage,severity.name];
                    severityString = [severityString stringByAppendingString:temp];
                }
            }
            [cell.defectValuesLabel setText:severityString];
        }
    }
    
     if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
         cell.defectValuesButton.frame = CGRectMake(cell.bounds.size.width - 200, cell.bounds.origin.y, 200, cell.bounds.size.height);
         cell.defectValuesLabel.frame = CGRectMake(cell.bounds.size.width - 200, cell.bounds.origin.y, 200, cell.bounds.size.height);
         [cell.defectValuesLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:12]];
     }
    
    [cell addSubview:cell.collapseButtonImageView];
    [cell addSubview:cell.checkMarkButton];
    [cell addSubview:cell.defectValuesButton];
    [cell addSubview:cell.defectValuesLabel];
    
    NSString *sectionRow = [NSString stringWithFormat:@"%d|%d", indexPath.section, indexPath.row];
    [self.defectViewCells setObject:cell forKey:sectionRow];
    
    //cell.checkMarkButton.frame = CGRectMake(cell.frame.origin.x + 20, cell.frame.origin.y, 20, 20);
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        cell.defectValuesButton.frame = CGRectMake(cell.bounds.size.width - 250, cell.bounds.origin.y, 250, cell.bounds.size.height);
        cell.defectValuesLabel.frame = CGRectMake(cell.bounds.size.width - 250, cell.bounds.origin.y, 250, cell.bounds.size.height);
        [cell.defectValuesLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:12]];
    }else{
    cell.defectValuesButton.frame = CGRectMake(cell.bounds.size.width - 200, cell.bounds.origin.y, 200, cell.bounds.size.height);
    cell.defectValuesLabel.frame = CGRectMake(cell.bounds.size.width - 200, cell.bounds.origin.y, 200, cell.bounds.size.height);
    [cell.defectValuesLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:12]];
    }
    [self.defectViewCells setObject:cell forKey:sectionRow];
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForSubRowAtIndexPath:(NSIndexPath *)indexPath
{
    DefectsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if(cell == nil)
    {
        cell = [[DefectsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    NSDictionary *dict = [self.defectsArray objectAtIndex:indexPath.section];
    NSArray *array = [dict allValues];
    NSMutableArray *defects = [NSMutableArray arrayWithArray:[array objectAtIndex:0]];
    Defect *defect = (Defect *)[defects objectAtIndex:indexPath.row];
    cell.defect = defect;
    return  cell;
}

- (CGFloat)tableView:(SKSTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Returns 60.0 points for all subrows.
    return 60.0f;
}

- (CGFloat)tableView:(SKSTableView *)tableView heightForSubRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Returns 60.0 points for all subrows.
    NSDictionary *dict = [self.defectsArray objectAtIndex:indexPath.section];
    NSArray *array = [dict allValues];
    NSMutableArray *defects = [NSMutableArray arrayWithArray:[array objectAtIndex:0]];
    Defect *defect = (Defect *)[defects objectAtIndex:indexPath.row];
    DefectsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if(cell == nil)
    {
        cell = [[DefectsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.defect = defect;
    int height = [cell calculateHeightForTheInspectionDefectCell];
    return height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if ([self.defectsArray count] == 1) {
        NSDictionary *dict = [self.defectsArray objectAtIndex:0];
        NSArray *keys = [dict allKeys];
        if ([[keys objectAtIndex:0] isEqualToString:OtherDefectGroup]) {
            return 0;
        }
        return 44;
    }
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSLog(@"index %d", indexPath.row);
//    id existingCell = [self.defectViewCells objectForKey:[NSNumber numberWithInt:indexPath.row]];
//    if (existingCell != [NSNull null] && [existingCell isKindOfClass:[RatingSelectSectionHeader class]]) {
//        RatingSelectSectionHeader *cell = (RatingSelectSectionHeader *)[tableView cellForRowAtIndexPath:indexPath];
//        if (cell.isExpanded) {
//            [cell.collapseButtonImageView setImage:[UIImage imageNamed:@"minus.png"]];
//        } else {
//            [cell.collapseButtonImageView setImage:[UIImage imageNamed:@"plus.png"]];
//        }
//    }
}

- (IBAction) saveButtonTouched:(id)sender {
    CGRect frame = CGRectMake(0, self.defectsTableView.contentSize.height - self.defectsTableView.bounds.size.height, self.defectsTableView.bounds.size.width, self.defectsTableView.bounds.size.height);

    [UIView animateWithDuration:2.0
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{ [self.defectsTableView scrollRectToVisible:frame animated:YES]; }
                     completion:^(BOOL finished) {
                         [self performSelector:@selector(saveDefects) withObject:nil afterDelay:1];
                     }];
   // [self saveDefects];
   
}

-(void) saveDefects {
    [[self delegate] saveTheDefectsInTheRating:[self createDefectObjectsFromTableCells]];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) markButtonTouched {
    //fix DI
    CGRect frame = CGRectMake(0, self.defectsTableView.contentSize.height - self.defectsTableView.bounds.size.height, self.defectsTableView.bounds.size.width, self.defectsTableView.bounds.size.height);

    [UIView animateWithDuration:2.0
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{ [self.defectsTableView scrollRectToVisible:frame animated:YES]; }
                     completion:^(BOOL finished) {
                         [self performSelector:@selector(saveDefects) withObject:nil afterDelay:0.5];
                     }];
    //[[self delegate] saveTheDefectsInTheRating:[self createDefectObjectsFromTableCells]];
    //[self.navigationController popViewControllerAnimated:YES];
}

- (NSArray *) createDefectObjectsFromTableCells {
    NSMutableArray *defectsArrayLocal = [[NSMutableArray alloc] init];
    NSArray *allTheKeys = [self.defectViewCells allKeys];
    if ([self.defectViewCells count] > 0) {
        for (int i = 0; i < [allTheKeys count]; i ++) {
            RatingSelectSectionHeader *defectCell = [self.defectViewCells objectForKey:[allTheKeys objectAtIndex:i]];
            
            Defect *defect = [[Defect alloc] init];
            defect = defectCell.defect;
            Severity *severity = [[Severity alloc] init];
            defect.isSetFromUI = NO;
            if (defectCell.checked) {
                defect.isSetFromUI = YES;
                if ([defectCell.coverageType isEqualToString:@"Boolean"]) {
                    
                        severity.name = @"";
                        severity.isSelected = YES;
                        [defectCell.globalSeverities addObject:severity];
                    
                    
                } else if ([defectCell.coverageType isEqualToString:@"Percentage"]) {
                    for(Severity *tempSeverity in defectCell.globalSeverities){
                        severity.inputOrCalculatedPercentage = [[NSString stringWithFormat:@"%.2f", tempSeverity.inputOrCalculatedPercentage] floatValue];
                        severity.name = tempSeverity.name;
                        severity.inputNumerator = [[NSString stringWithFormat:@"%.2f", tempSeverity.inputOrCalculatedPercentage] floatValue];
                        severity.inputDenominator = 100;

                        
                        //[defectCell.globalSeverities addObject:severity];
                    }
                    
                } else {
                    for(Severity *tempSeverity in defectCell.globalSeverities){
                        severity.inputNumerator = tempSeverity.inputNumerator;
                        severity.inputDenominator = tempSeverity.inputDenominator;
                        severity.inputOrCalculatedPercentage = [[NSString stringWithFormat:@"%.2f", tempSeverity.inputOrCalculatedPercentage] floatValue];
                        severity.name = tempSeverity.name;
                        
                        //[defectCell.globalSeverities addObject:severity];
                    }
                    
                }
                //defect.severity = severity;
                for(Severity *tempSeverity in defect.severities){
                    for(Severity *tempSeverity2 in defectCell.globalSeverities){
                        if(tempSeverity.name == tempSeverity2.name){
                            tempSeverity2.criteriaAcceptWithIssues = tempSeverity.criteriaAcceptWithIssues;
                            tempSeverity2.criteriaReject = tempSeverity.criteriaReject;
                            tempSeverity2.thresholdTotal = tempSeverity.thresholdTotal;
                            tempSeverity2.thresholdAcceptWithIssues = tempSeverity.thresholdAcceptWithIssues;
                            tempSeverity2.id = tempSeverity.id;
                            break;
                        }
                    }
                }
                defect.severities = defectCell.globalSeverities;
                
            }
            [defectsArrayLocal addObject:defect];
        }
    }
    return [defectsArrayLocal copy];
}

@end
