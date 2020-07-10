//
//  HPTCaseCodeViewController.m
//  Insights
//
//  Created by Mustafa Shaheen on 6/17/20.
//  Copyright © 2020 Yottamark. All rights reserved.
//

#import "HPTCaseCodeViewController.h"
#import "HPTCaseCode.h"
#import "HPTInspection.h"
#import "ScanCodeViewController.h"
#import "HPTHomeViewController.h"
@implementation HPTCaseCodeViewController
@synthesize ratingsTableView;
@synthesize ratingsGlobal;
@synthesize viewModel;
@synthesize starRatingViewCell;
@synthesize textRatingViewCell;
@synthesize descriptionRatingViewCell;
@synthesize dateRatingViewCell;
@synthesize numericRatingViewCell;
@synthesize priceRatingViewCell;
@synthesize booleanRatingViewCell;
@synthesize selectButtonRatingViewCell;
@synthesize labelRatingViewCell;
@synthesize locationRatingViewCell;
@synthesize ratingViewCells;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.ratingNameForAlertView = @"";
    self.reasonForAlertView = @"";
    self.ratingsGlobal = [[NSArray alloc] init];
    self.viewModel = [[HPTCaseCodeModel alloc] init];
    self.ratingsGlobal = [self.viewModel getAllRatings];
    NSInteger numberOfQuestions = [self.ratingsGlobal count];
    self.ratingViewCells = [[NSMutableDictionary alloc] initWithCapacity:numberOfQuestions];
    for (int i = 0; i < numberOfQuestions; i++) {
        [self.ratingViewCells setObject:[NSNull null] forKey:[NSNumber numberWithInt:i]];
    }
    
    [self.ratingsTableView reloadData];
    
    // Do any additional setup after loading the view from its nib.
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.caseCodeList = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.pageTitle = @"PalletShippingRatingViewController";
    [self setupNavBar];
}

- (void) setupNavBar {
    [super setupNavBar];
}

- (void)tellOtherQuestionsToCloseKeyboard:(Rating*)currentRating {
    NSArray *ratingsArray = self.ratingsGlobal;
    for (NSInteger i = 0; i < [ratingsArray count]; i++) {
        id existingCell = [ratingViewCells objectForKey:[NSNumber numberWithInt:i]];
        if (existingCell && existingCell != [NSNull null]) {
            BaseTableViewCell *baseTableViewCell = (BaseTableViewCell*)existingCell;
            if (baseTableViewCell.rating.ratingID != currentRating.ratingID) {
                if ([baseTableViewCell.rating.type isEqualToString:@"ESSAY"] && [currentRating.type isEqualToString:@"ESSAY"]) {
                    // Moving from one essay question to the next, pass keyboard control
                    //DebugLog(@"currentQuestion: [%d] telling [%d] to pass", currentRating.ratingID, baseTableViewCell.rating.ratingID);
                    [baseTableViewCell passKeyboardIfOpen];
                    
                } else {
                    //DebugLog(@"currentQuestion: [%d] telling [%d] to close", currentRating.ratingID, baseTableViewCell.rating.ratingID);
                    [baseTableViewCell closeKeyboardIfOpen];
                }
            }
        }
    }
}
// MARK: - SDCBarcodeCaptureListener
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *ratingsLocal = self.ratingsGlobal;
    if (ratingsLocal) {
        return [ratingsLocal count];
    } else
        return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *ratingsLocal = self.ratingsGlobal;
    if (ratingsLocal && [ratingsLocal count] > indexPath.row) {
        Rating *rating = [ratingsLocal objectAtIndex:indexPath.row];
        if (rating && [rating.type isEqualToString:STAR_RATING]) {
            return [StarRatingViewCell myCellHeight:rating];
            
        } else if (rating && [rating.type isEqualToString:TEXT_RATING]) {
            if([rating.name isEqualToString:@"Case Codes"]){
                return [DescriptionRatingViewCell myCellHeight:rating];
            }else{
                return [TextRatingViewCell myCellHeight:rating];
            }
            
        } else if (rating && [rating.type isEqualToString:DATE_RATING]) {
            return [DateRatingViewCell myCellHeight:rating];
            
        } else if (rating && [rating.type isEqualToString:NUMERIC_RATING]) {
            return [NumericRatingViewCell myCellHeight:rating];
            
        } else if (rating && [rating.type isEqualToString:PRICE_RATING]) {
            return [PriceRatingViewCell myCellHeight:rating];
            
        } else if (rating && [rating.type isEqualToString:COMBO_BOX_RATING]) {
            return [SelectButtonRatingViewCell myCellHeight:rating];
            
        } else if (rating && [rating.type isEqualToString:LOCATION_RATING]) {
            return [LocationRatingViewCell myCellHeight:rating];
            
        }else if (rating && [rating.type isEqualToString:BOOLEAN_RATING]) {
            return [PriceRatingViewCell myCellHeight:rating];
        } else if (rating && [rating.type isEqualToString:LABEL_RATING]) {
            return [LabelRatingViewCell myCellHeight:rating];
        }
    }
    
    return 96.0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id existingCell = [ratingViewCells objectForKey:[NSNumber numberWithInt:indexPath.row]];

    BaseTableViewCell *baseTableViewCell;
    NSArray *ratings = self.ratingsGlobal;
    if (ratings && [ratings count] > indexPath.row) {
        Rating *rating = [ratings objectAtIndex:indexPath.row];
        
        if (rating && [rating.type isEqualToString:STAR_RATING]) {
            
            StarRatingViewCell *newCell = [tableView dequeueReusableCellWithIdentifier:kStarRatingViewCellReuseID];
            if (newCell == nil) {
                [[NSBundle mainBundle] loadNibNamed:kStarRatingViewCellNIBFile owner:self options:nil];
                newCell = starRatingViewCell;
                self.starRatingViewCell = nil;
            }
            baseTableViewCell = (BaseTableViewCell*)newCell;
            
        } else if (rating && [rating.type isEqualToString:TEXT_RATING]) {
            
            if([rating.displayName isEqualToString:@"Case Codes"]){
                DescriptionRatingViewCell *newCell = [tableView dequeueReusableCellWithIdentifier:kDescriptionRatingViewCellReuseID];
                if (newCell == nil) {
                    [[NSBundle mainBundle] loadNibNamed:kDescriptionRatingViewCellNIBFile owner:self options:nil];
                    newCell = descriptionRatingViewCell;
                    self.descriptionRatingViewCell = nil;
                }
                baseTableViewCell = (BaseTableViewCell*)newCell;
            }else{
            TextRatingViewCell *newCell = [tableView dequeueReusableCellWithIdentifier:kTextRatingViewCellReuseID];
            if (newCell == nil) {
                [[NSBundle mainBundle] loadNibNamed:kTextRatingViewCellNIBFile owner:self options:nil];
                newCell = textRatingViewCell;
                self.textRatingViewCell = nil;
            }
            baseTableViewCell = (BaseTableViewCell*)newCell;
            }
            
        } else if (rating && [rating.type isEqualToString:DATE_RATING]) {
            
            DateRatingViewCell *newCell = [tableView dequeueReusableCellWithIdentifier:kDateRatingViewCellReuseID];
            if (newCell == nil) {
                [[NSBundle mainBundle] loadNibNamed:kDateRatingViewCellNIBFile owner:self options:nil];
                newCell = dateRatingViewCell;
                self.dateRatingViewCell = nil;
            }
            UIWindow *win = [[UIApplication sharedApplication] keyWindow];
           // newCell.datePickerView.frame = CGRectMake(0, (baseTableViewCell.bounds.origin.y + 200), win.frame.size.width, 260.0);
            baseTableViewCell = (BaseTableViewCell*)newCell;
            
        } else if (rating && [rating.type isEqualToString:NUMERIC_RATING]) {

            NumericRatingViewCell *newCell = [tableView dequeueReusableCellWithIdentifier:kNumericRatingViewCellReuseID];
            if (newCell == nil) {
                [[NSBundle mainBundle] loadNibNamed:kNumericRatingViewCellNIBFile owner:self options:nil];
                newCell = numericRatingViewCell;
                self.numericRatingViewCell = nil;
            }
            baseTableViewCell = (BaseTableViewCell*)newCell;
            
        } else if (rating && [rating.type isEqualToString:PRICE_RATING]) {
            
            PriceRatingViewCell *newCell = [tableView dequeueReusableCellWithIdentifier:kPriceRatingViewCellReuseID];
            if (newCell == nil) {
                [[NSBundle mainBundle] loadNibNamed:kPriceRatingViewCellNIBFile owner:self options:nil];
                newCell = priceRatingViewCell;
                self.priceRatingViewCell = nil;
            }
            baseTableViewCell = (BaseTableViewCell*)newCell;
            
        } else if (rating && [rating.type isEqualToString:COMBO_BOX_RATING]) {
            
            SelectButtonRatingViewCell *newCell = [tableView dequeueReusableCellWithIdentifier:kSelectButtonRatingViewCellReuseID];
            if (newCell == nil) {
                [[NSBundle mainBundle] loadNibNamed:kSelectButtonRatingViewCellNIBFile owner:self options:nil];
                newCell = selectButtonRatingViewCell;
                newCell.delegate = self;
                self.selectButtonRatingViewCell = nil;
            }
            baseTableViewCell = (BaseTableViewCell*)newCell;
        } else if (rating && [rating.type isEqualToString:LOCATION_RATING]) {
                   
                   LocationRatingViewCell *newCell = [tableView dequeueReusableCellWithIdentifier:kLocationRatingViewCellReuseID];
                   if (newCell == nil) {
                       [[NSBundle mainBundle] loadNibNamed:kLocationRatingViewCellNIBFile owner:self options:nil];
                       newCell = locationRatingViewCell;
                       newCell.delegate = self;
                       self.locationRatingViewCell = nil;
                   }
                   baseTableViewCell = (BaseTableViewCell*)newCell;
               } else if (rating && [rating.type isEqualToString:BOOLEAN_RATING]) {
            
            BooleanRatingViewCell *newCell = [tableView dequeueReusableCellWithIdentifier:kBooleanRatingViewCellReuseID];
            if (newCell == nil) {
                [[NSBundle mainBundle] loadNibNamed:kBooleanRatingViewCellNIBFile owner:self options:nil];
                newCell = booleanRatingViewCell;
                self.booleanRatingViewCell = nil;
            }
            baseTableViewCell = (BaseTableViewCell*)newCell;
        } else if (rating && [rating.type isEqualToString:LABEL_RATING]) {
            
            LabelRatingViewCell *newCell = [tableView dequeueReusableCellWithIdentifier:kLabelRatingViewCellReuseID];
            if (newCell == nil) {
                [[NSBundle mainBundle] loadNibNamed:kLabelRatingViewCellNIBFile owner:self options:nil];
                newCell = labelRatingViewCell;
                self.labelRatingViewCell = nil;
            }
            baseTableViewCell = (BaseTableViewCell*)newCell;
        }
        
        if (baseTableViewCell) {
            baseTableViewCell.myTableView = self.ratingsTableView;
            baseTableViewCell.myTableViewController = self;
            baseTableViewCell.rating = rating;
            
            baseTableViewCell.questionNumber = indexPath.row + 1;

            //TODO check if this is needed for all ratings
            //for days validation message
            if([baseTableViewCell.rating.type isEqualToString:DATE_RATING]){
                [baseTableViewCell refreshState];
            }
            
            [ratingViewCells setObject:baseTableViewCell forKey:[NSNumber numberWithInt:indexPath.row]];
            return baseTableViewCell;
        }
    }
    
    UITableViewCell *emptyCell;
    emptyCell = [tableView dequeueReusableCellWithIdentifier:kEmptyTableCellIdentifier];
    if (emptyCell == nil) {
        emptyCell = [[UITableViewCell alloc]
                     initWithStyle:UITableViewCellStyleDefault
                     reuseIdentifier:kEmptyTableCellIdentifier];
        emptyCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return emptyCell;
    
}
- (void) refreshTheView {
   // [self selectPONumberOptionForVendorNameSelected: string];
    [self.ratingsTableView reloadData];
}

-(void) setCaseCodes{
    
    for(int i = 0; i < [self.descriptionRatingViewCell.caseCodes count]; i++){
        HPTCaseCode *caseCode = [[HPTCaseCode alloc] init];
        NSString *finalString = [self.descriptionRatingViewCell.caseCodes objectAtIndex:i];
        caseCode.caseCode = finalString;
        caseCode.quantity = [self.descriptionRatingViewCell.quantities objectAtIndex:i];
        caseCode.gtin = [finalString substringWithRange:NSMakeRange(2, 16)];
        caseCode.prefixType = [finalString substringWithRange:NSMakeRange(16, 18)];
        caseCode.date = [finalString substringWithRange:NSMakeRange(18, 24)];
        caseCode.lotNumber = [finalString substringWithRange:NSMakeRange(26, 26)];
        [self.caseCodeList addObject:caseCode];
        [self.viewModel.caseCodes addObject:caseCode];
    }
    
}
- (void) saveButtonTouched {
    CGRect frame = CGRectMake(0, self.ratingsTableView.contentSize.height - self.ratingsTableView.bounds.size.height, self.ratingsTableView.bounds.size.width, self.ratingsTableView.bounds.size.height);
    
     
     [UIView animateWithDuration:2.0
                           delay:0
                         options:UIViewAnimationOptionCurveEaseInOut
                      animations:^{ [self.ratingsTableView scrollRectToVisible:frame animated:YES]; }
                      completion:^(BOOL finished) {
                          [self performSelector:@selector(performAfterDelay) withObject:nil afterDelay:1];
                      }];
}
-(void) scanButtonTouched{
    ScanCodeViewController *caseCodeViewController = [[ScanCodeViewController alloc] initWithNibName:kScanCaseCodeViewNIBName bundle:nil];
    caseCodeViewController.caseCodes = self.descriptionRatingViewCell.caseCodes;
    caseCodeViewController.quantities = self.descriptionRatingViewCell.quantities;
    caseCodeViewController.sscc = self.sscc;
    [self.navigationController pushViewController:caseCodeViewController animated:YES];
}

- (void) performAfterDelay {
    
    //NSLog(@"%f %f %f", self.ratingsTableView.contentSize.height - self.ratingsTableView.bounds.size.height, self.ratingsTableView.bounds.size.width, self.ratingsTableView.bounds.size.height);
    NSArray *ratingsLocal = self.ratingsGlobal;
    BOOL passesValidation = YES;
    BOOL passesPictureValidation = YES;
    BOOL passesDefectValidation = YES;
    BaseTableViewCell *baseQuestionCellForFirstFailure;
    for (NSInteger i = 0; i < [ratingsLocal count]; i++) {
        id existingCell = [self.ratingViewCells objectForKey:[NSNumber numberWithInt:i]];
        Rating *rating = [ratingsLocal objectAtIndex:i];
        if (existingCell && existingCell != [NSNull null]) {
            BaseTableViewCell *baseLocalTableViewCell = (BaseTableViewCell*)existingCell;
            if ([baseLocalTableViewCell.rating.type isEqualToString:PRICE_RATING]) {
                BOOL thisRowPassesValidation = [(BaseTableViewCell*)existingCell validateForPriceAndNumericRating];
                passesValidation = thisRowPassesValidation && passesValidation;
                if ([self.ratingNameForAlertView isEqualToString:@""] && !passesValidation) {
                    if([rating.displayName isEqualToString:@""] || !rating.displayName)
                    self.ratingNameForAlertView = rating.name;
                    else
                        self.ratingNameForAlertView = rating.displayName;
                    self.reasonForAlertView = @"Check the condition";
                }
            } else if ([baseLocalTableViewCell.rating.type isEqualToString:NUMERIC_RATING]) {
                BOOL thisRowPassesValidation = [(BaseTableViewCell*)existingCell validateForNumericRating];
                passesValidation = thisRowPassesValidation && passesValidation;
                if ([self.ratingNameForAlertView isEqualToString:@""] && !passesValidation) {
                    if([rating.displayName isEqualToString:@""] || !rating.displayName)
                        self.ratingNameForAlertView = rating.name;
                    else
                        self.ratingNameForAlertView = rating.displayName;
                    self.reasonForAlertView = [NSString stringWithFormat:@" [ %.2f  to  %.2f] ", baseLocalTableViewCell.rating.content.numericRatingModel.min_value, baseLocalTableViewCell.rating.content.numericRatingModel.max_value];
                }
            }
            else {
                BOOL thisRowPassesValidation = [(BaseTableViewCell*)existingCell validate] || rating.optionalSettings.optional;
                //thisRowPassesValidation = YES;
                passesValidation = thisRowPassesValidation && passesValidation;
                if ([self.ratingNameForAlertView isEqualToString:@""] && !passesValidation) {
                    if([rating.displayName isEqualToString:@""] || !rating.displayName)
                        self.ratingNameForAlertView = rating.name;
                    else
                        self.ratingNameForAlertView = rating.displayName;
                    self.reasonForAlertView = @"Check the condition";
                }
            }
        }
    }
    for (NSInteger i = 0; i < [self.ratingsGlobal count]; i++) {
        baseQuestionCellForFirstFailure = (BaseTableViewCell*)[ratingViewCells objectForKey:[NSNumber numberWithInt:i]];
        if ([baseQuestionCellForFirstFailure.rating.type isEqualToString:PRICE_RATING]) {
            if (![baseQuestionCellForFirstFailure validateForPriceAndNumericRating]) {
                break;
            }
        } else if ([baseQuestionCellForFirstFailure.rating.type isEqualToString:NUMERIC_RATING]) {
            if (![baseQuestionCellForFirstFailure validateForNumericRating]) {
                break;
            }
        } else  {
            if (![baseQuestionCellForFirstFailure validate]) {
                break;
            }
        }
    }

    NSMutableArray *ratingsMutableArray;
    if (passesValidation) {
        ratingsMutableArray = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < [ratingsLocal count]; i++) {
            BaseTableViewCell *baseTableCell = (BaseTableViewCell*)[self.ratingViewCells objectForKey:[NSNumber numberWithInt:i]];
            //DebugLog(@"\n\n theCell (VALIDATION): %@\n\n", [baseTableCell class]);
            NSString *responseValue = @"";
            //NSLog(@"type is %@", baseTableCell.rating.type);
            if ([baseTableCell.rating.type isEqualToString:PRICE_RATING]) {
                responseValue = [baseTableCell theAnswerAsStringForNumericAndPriceRating];
            } else if ([baseTableCell.rating.type isEqualToString:NUMERIC_RATING]) {
                responseValue = [baseTableCell theAnswerAsStringForNumericRating];
            } else  {
                responseValue = [baseTableCell theAnswerAsString];
            }
            if (responseValue == nil)
                responseValue = @"";
            
            Rating *rating = [[Rating alloc] init];
            rating = baseTableCell.rating;
            rating.ratingAnswerFromUI = responseValue;
            [ratingsMutableArray addObject:rating];
            int pictureCountForContainer = [[User sharedUser].allImages count];
            
            if (!rating.optionalSettings.optional) {
            }
            if ([baseTableCell.rating.type isEqualToString:STAR_RATING]) {
                if (baseTableCell.rating.optionalSettings.defects) {
                    if ([responseValue integerValue] <= rating.pictureAndDefectThresholds.defects) {
                        NSArray *defectsSet = baseTableCell.rating.defectsFromUI;
                        passesDefectValidation = NO;
                        for (Defect *defect in defectsSet) {
                            if (defect.isSetFromUI) {
                                passesDefectValidation = YES;
                                break;
                            }
                        }
                    }
                }
                if (passesDefectValidation && passesPictureValidation) {
                    //[delegate proceedToNextGroup:ratingsMutableArray];
                } else {
                    passesValidation = NO;
                    if (passesDefectValidation) {
                        if (![NSUserDefaultsManager getBOOLFromUserDeafults:@"alertShownOnce"]) {
                            [[[UIAlertView alloc] initWithTitle: @"You need to take a picture to proceed" message: @"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                            [self proceedToNextGroup:ratingsMutableArray withSuccess:NO];
                            [NSUserDefaultsManager saveBOOLToUserDefaults:YES withKey:@"alertShownOnce"];
                            //[self releaseUIDatePicker];
                        }
                    } else {
                        if (![NSUserDefaultsManager getBOOLFromUserDeafults:@"alertShownOnce"]) {
                            [[[UIAlertView alloc] initWithTitle: [NSString stringWithFormat:@"You need to complete a defect for %@ to proceed", rating.name] message: @"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                            [self proceedToNextGroup:ratingsMutableArray withSuccess:NO];
                            [NSUserDefaultsManager saveBOOLToUserDefaults:YES withKey:@"alertShownOnce"];
                            //[self releaseUIDatePicker];
                        }
                    }
                }
            } else {

                if (baseTableCell.rating.optionalSettings.defects) {
                    NSArray *defectsSet = baseTableCell.rating.defectsFromUI;
                    passesDefectValidation = NO;
                    for (Defect *defect in defectsSet) {
                        if (defect.isSetFromUI) {
                            passesDefectValidation = YES;
                            break;
                        }
                    }
                }
                if (passesDefectValidation && passesPictureValidation) {
                    //[delegate proceedToNextGroup:ratingsMutableArray];
                } else {
                    passesValidation = NO;
                    if (passesDefectValidation) {
                        if (![NSUserDefaultsManager getBOOLFromUserDeafults:@"alertShownOnce"]) {
                            [[[UIAlertView alloc] initWithTitle: @"You need to take a picture to proceed" message: @"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                            [self proceedToNextGroup:ratingsMutableArray withSuccess:NO];
                            [NSUserDefaultsManager saveBOOLToUserDefaults:YES withKey:@"alertShownOnce"];
                            //[self releaseUIDatePicker];
                        }
                    } else {
                        if (![NSUserDefaultsManager getBOOLFromUserDeafults:@"alertShownOnce"]) {
                            [[[UIAlertView alloc] initWithTitle: [NSString stringWithFormat:@"You need to complete a defect for %@ to proceed", rating.name] message: @"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                            [self proceedToNextGroup:ratingsMutableArray withSuccess:NO];
                            [NSUserDefaultsManager saveBOOLToUserDefaults:YES withKey:@"alertShownOnce"];
                            //[self releaseUIDatePicker];
                        }
                    }
                }
            }
        }
        
        if (passesValidation) {
            [self proceedToNextGroup:ratingsMutableArray withSuccess:YES];
        }
    }

}
- (void) proceedToNextGroup:(NSArray *) ratingsReponses withSuccess:(BOOL)success {
    [self setCaseCodes];
    if (success) {
        if(self.caseCodeList.count == 0){
            
        }else{
            [self.viewModel setValuesFromViews:self.ratingsGlobal];
            
            HPTInspection *hptInspection = [[HPTInspection alloc] init];
            AuditApiData *auditApiData = [hptInspection getApiObjectFromViewModel:self.viewModel];
            [hptInspection saveToDB:auditApiData];
        }
        
    } else {
        [self.syncOverlayView dismissActivityView];
        [self.syncOverlayView removeFromSuperview];
    }
}
-(void) goBack{
    HPTHomeViewController *caseCodeViewController = [[HPTHomeViewController alloc] initWithNibName:@"HPTHomeViewController" bundle:nil];
    [self.navigationController pushViewController:caseCodeViewController animated:YES];
}
-(void) printButtonTouched{
    
}
@end
