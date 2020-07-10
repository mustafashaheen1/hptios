//
//  ProductRatingViewController.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/15/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//\

#import "ProductRatingViewController.h"
#import "RatingAPI.h"
#import "Constants.h"
#import "ProductSelectAutoCompleteViewController.h"
#import "InspectionStatusViewController.h"
#import "Image.h"
#import "Inspection.h"


#define driscollsLotEntryRatingId 159
#define driscollsLotReEntryRatingId 160
#define notApplicable @"NA"

@interface ProductRatingViewController ()

@end

@implementation ProductRatingViewController

@synthesize ratingsTableView;
@synthesize ratingsGlobal;
@synthesize ratingViewCells;
@synthesize inputScanViewCell;
@synthesize selectViewCell;
@synthesize cellBuilder;
@synthesize starRatingViewCell;
@synthesize textRatingViewCell;
@synthesize dateRatingViewCell;
@synthesize numericRatingViewCell;
@synthesize priceRatingViewCell;
@synthesize booleanRatingViewCell;
@synthesize labelRatingViewCell;
@synthesize locationRatingViewCell;
@synthesize descriptionRatingViewCell;
@synthesize delegate;
@synthesize buttonNextStep;
@synthesize selectButtonRatingViewCell;
@synthesize parentView;
@synthesize failedValidationView;
@synthesize currentAuditGlobal;
@synthesize productGlobal; 
@synthesize ratingGlobal;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.pageTitle = @"ProductRatingViewController";
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    if (![self.parentView isEqualToString:defineContainerViewController]) {
        for (int i=0; i < [self.ratingsGlobal count]; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [self tableView: self.ratingsTableView cellForRowAtIndexPath: indexPath];
        }
    }
    
    //[self populateRatingsToDictionary];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.ratingNameForAlertView = @"";
    self.reasonForAlertView = @"";
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 400.0)];//DI-2768
    //fix the issue with the last entry field
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 450.0)];
    }
    buttonNextStep.frame = CGRectMake(37.0, 20.0, 246.0, 37.0);
	self.ratingsTableView.tableFooterView = footerView;
    self.ratingsGlobal = [[NSArray alloc] init];
    self.ratingsDynamic = [[NSMutableArray alloc] init];
    NSInteger numberOfQuestions = [self.ratingsGlobal count];
    self.ratingViewCells = [[NSMutableDictionary alloc] initWithCapacity:numberOfQuestions];
    for (int i = 0; i < numberOfQuestions; i++) {
        [self.ratingViewCells setObject:[NSNull null] forKey:[NSNumber numberWithInt:i]];
    }
    self.failedValidationView = [[FailedValidationView alloc] initWithFrame:CGRectZero];
    failedValidationView.delegate = self;
    
    if ([self.parentView isEqualToString:defineContainerViewController]) {
        for (int i=0; i < [self.ratingsGlobal count]; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [self tableView: self.ratingsTableView cellForRowAtIndexPath: indexPath];
        }
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Image Picker Delegate Methods

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
//    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
//    NSLog(@"image %@", image);
//    //Save to device with currentTime_<pictureCount> format, increment image count for inspection
//    Image *savedImage = [[Image alloc]init];
//    NSString *deviceUrl = [[Inspection sharedInspection].currentAudit getDeviceUrl:self.currentPictureCount];
//    [savedImage setDeviceUrl:deviceUrl];
//    NSString *remoteUrl = [[Inspection sharedInspection].currentAudit getRemoteUrl:self.currentPictureCount];
//    [savedImage setRemoteUrl:remoteUrl];
//    NSString *path = [[Inspection sharedInspection].currentAudit getPath:self.currentPictureCount];
//    [savedImage setPath:path];
//    // save image in CurrentAudit class
//    [[Inspection sharedInspection].currentAudit addImage:savedImage];
//    self.currentPictureCount++;
//    [self dismissViewControllerAnimated:YES completion:nil];
}

//fix UIDatePicker leak
-(void)releaseUIDatePicker
{
   for(int i=0; i<[self.ratingsGlobal count]; i++){
        BaseTableViewCell *baseTableCell = (BaseTableViewCell*)[self.ratingViewCells objectForKey:[NSNumber numberWithInt:i]];
        if(baseTableCell && baseTableCell.rating && [baseTableCell.rating.type isEqualToString:DATE_RATING]){
            DateRatingViewCell *dateTableViewCell = (DateRatingViewCell*)baseTableCell;
            dateTableViewCell.datePicker = nil;
            [dateTableViewCell.datePickerView removeFromSuperview];
            dateTableViewCell.datePickerView = nil;
        }
    }
}

#pragma mark - User Actions

- (void) performAfterDelay {
    
    //NSLog(@"%f %f %f", self.ratingsTableView.contentSize.height - self.ratingsTableView.bounds.size.height, self.ratingsTableView.bounds.size.width, self.ratingsTableView.bounds.size.height);
    NSArray *ratingsLocal = self.ratingsGlobal;
    BOOL passesValidation = YES;
    BOOL passesLotCodeValidation = YES;
    BOOL passesPictureValidation = YES;
    BOOL passesDefectValidation = YES;
    BaseTableViewCell *baseQuestionCellForFirstFailure;
    BaseTableViewCell *baseQuestionCellForLots;
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
    NSString *driscollsLotCode = notApplicable;
    NSString *driscollsLotReentryCode = notApplicable;
    //To check lot code
    for (NSInteger i = 0; i < [self.ratingsGlobal count]; i++) {
        baseQuestionCellForLots = (BaseTableViewCell*)[ratingViewCells objectForKey:[NSNumber numberWithInt:i]];
        if (baseQuestionCellForLots.rating.ratingID == driscollsLotEntryRatingId) {
            driscollsLotCode = [baseQuestionCellForLots theAnswerAsString];
            driscollsLotCode = [driscollsLotCode stringByTrimmingCharactersInSet:
                                       [NSCharacterSet whitespaceCharacterSet]];
        } else if (baseQuestionCellForLots.rating.ratingID == driscollsLotReEntryRatingId) {
            driscollsLotReentryCode = [baseQuestionCellForLots theAnswerAsString];
            driscollsLotReentryCode = [driscollsLotReentryCode stringByTrimmingCharactersInSet:
                                [NSCharacterSet whitespaceCharacterSet]];
        }
    }
    if (![driscollsLotCode isEqualToString:notApplicable] && ![driscollsLotReentryCode isEqualToString:notApplicable]) {
        if (![driscollsLotCode isEqualToString:driscollsLotReentryCode]) {
            passesValidation = NO;
            passesLotCodeValidation = NO;
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
                if (baseTableCell.rating.optionalSettings.picture || pictureCountForContainer) {
                    if ([responseValue integerValue] <= rating.pictureAndDefectThresholds.picture) {
                        if ([parentView isEqualToString:@"ProductViewController"]) {
                            if (self.currentAuditGlobal && self.currentAuditGlobal.currentPictureCount < 1) {
                                passesPictureValidation = NO;
                            }
                        } else {
                            if (pictureCountForContainer < 1) {
                                passesPictureValidation = NO;
                            }
                        }
                    }
                }
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
                            [delegate proceedToNextGroup:ratingsMutableArray withSuccess:NO];
                            [NSUserDefaultsManager saveBOOLToUserDefaults:YES withKey:@"alertShownOnce"];
                            //[self releaseUIDatePicker];
                        }
                    } else {
                        if (![NSUserDefaultsManager getBOOLFromUserDeafults:@"alertShownOnce"]) {
                            [[[UIAlertView alloc] initWithTitle: [NSString stringWithFormat:@"You need to complete a defect for %@ to proceed", rating.name] message: @"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                            [delegate proceedToNextGroup:ratingsMutableArray withSuccess:NO];
                            [NSUserDefaultsManager saveBOOLToUserDefaults:YES withKey:@"alertShownOnce"];
                            //[self releaseUIDatePicker];
                        }
                    }
                }
            } else {
                if (baseTableCell.rating.optionalSettings.picture) {
                    if (self.currentAuditGlobal.currentPictureCount < 1) {
                        passesPictureValidation = NO;
                    }
                }
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
                            [delegate proceedToNextGroup:ratingsMutableArray withSuccess:NO];
                            [NSUserDefaultsManager saveBOOLToUserDefaults:YES withKey:@"alertShownOnce"];
                            //[self releaseUIDatePicker];
                        }
                    } else {
                        if (![NSUserDefaultsManager getBOOLFromUserDeafults:@"alertShownOnce"]) {
                            [[[UIAlertView alloc] initWithTitle: [NSString stringWithFormat:@"You need to complete a defect for %@ to proceed", rating.name] message: @"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                            [delegate proceedToNextGroup:ratingsMutableArray withSuccess:NO];
                            [NSUserDefaultsManager saveBOOLToUserDefaults:YES withKey:@"alertShownOnce"];
                            //[self releaseUIDatePicker];
                        }
                    }
                }
            }
        }
        
        if (passesValidation) {
            [delegate proceedToNextGroup:ratingsMutableArray withSuccess:YES];
            [self releaseUIDatePicker];
        }
    } else {
        if (passesLotCodeValidation) {
            [delegate proceedToNextGroup:ratingsMutableArray withSuccess:NO];
            failedValidationView.titleLabel.text = @"OOPS!";
            failedValidationView.subtitleLabel.text = @"YOU HAVEN'T FINISHED THIS QUESTION";
            
            if ([baseQuestionCellForFirstFailure isKindOfClass:[NumericRatingViewCell class]]) {
                failedValidationView.bottomLabel.text = @"Check the value and try again";
            } else if ([baseQuestionCellForFirstFailure isKindOfClass:[SelectViewCell class]]) {
                failedValidationView.bottomLabel.text = @"Please Select a Value";
            } else if ([baseQuestionCellForFirstFailure isKindOfClass:[TextRatingViewCell class]]) {
                failedValidationView.bottomLabel.text = @"You must complete the required field in order to advance to the next step.";
            }
            //[failedValidationView openView];
            [[[UIAlertView alloc] initWithTitle: [NSString stringWithFormat:@"Please select \"%@\".", self.ratingNameForAlertView] message: self.reasonForAlertView delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            self.ratingNameForAlertView = @"";
        } else {
            [delegate proceedToNextGroup:ratingsMutableArray withSuccess:NO];
            //[self releaseUIDatePicker];
            [[[UIAlertView alloc] initWithTitle: [NSString stringWithFormat:@"Lot codes don't match, please correct to continue."] message: @"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }

}

- (IBAction)submitAnswersTouched:(id)sender;
{
    CGRect frame = CGRectMake(0, self.ratingsTableView.contentSize.height - self.ratingsTableView.bounds.size.height, self.ratingsTableView.bounds.size.width, self.ratingsTableView.bounds.size.height);
   
    [self initMissingTableViewCells];
    
    [UIView animateWithDuration:2.0
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{ [self.ratingsTableView scrollRectToVisible:frame animated:YES]; }
                     completion:^(BOOL finished) {
                         [self performSelector:@selector(performAfterDelay) withObject:nil afterDelay:1];
                     }];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [NSUserDefaultsManager saveBOOLToUserDefaults:NO withKey:@"alertShownOnce"];
    if (buttonIndex == 0) {
        NSInteger indexOfFirstFailure = -1;
        BOOL passesPictureValidation = YES;
        BOOL passesDefectValidation = YES;

        for (NSInteger i = 0; i < [self.ratingsGlobal count]; i++) {
            BaseTableViewCell *baseQuestionCell = (BaseTableViewCell*)[ratingViewCells objectForKey:[NSNumber numberWithInt:i]];
            if ([baseQuestionCell.rating.type isEqualToString:PRICE_RATING]) {
                if (![baseQuestionCell validateForPriceAndNumericRating]) {
                    indexOfFirstFailure = i;
                    break;
                }
            } else if ([baseQuestionCell.rating.type isEqualToString:NUMERIC_RATING]) {
                if (![baseQuestionCell validateForNumericRating]) {
                    indexOfFirstFailure = i;
                    break;
                }
            } else  {
                if (![baseQuestionCell validate]) {
                    indexOfFirstFailure = i;
                    break;
                }
            }
            NSString *responseValue = [baseQuestionCell theAnswerAsString];
            if (responseValue == nil)
                responseValue = @"";

            Rating *rating = [[Rating alloc] init];
            rating = baseQuestionCell.rating;
            rating.ratingAnswerFromUI = responseValue;
            int pictureCountForContainer = [[User sharedUser].allImages count];

            if ([baseQuestionCell.rating.type isEqualToString:STAR_RATING]) {
                if (baseQuestionCell.rating.optionalSettings.picture) {
                    if ([responseValue integerValue] <= rating.pictureAndDefectThresholds.picture) {
                        if (pictureCountForContainer < 1) {
                            passesPictureValidation = NO;
                        }
                        if (self.currentAuditGlobal && self.currentAuditGlobal.currentPictureCount < 1) {
                            passesPictureValidation = NO;
                        }
                    }
                }
                if (baseQuestionCell.rating.optionalSettings.defects) {
                    if ([responseValue integerValue] <= rating.pictureAndDefectThresholds.defects) {
                        NSArray *defectsSet = baseQuestionCell.rating.defectsFromUI;
                        passesDefectValidation = NO;
                        for (Defect *defect in defectsSet) {
                            if (defect.isSetFromUI) {
                                passesDefectValidation = YES;
                                break;
                            }
                        }
                    }
                }
                if (!passesDefectValidation && !passesPictureValidation) {
                    indexOfFirstFailure = i;
                    break;
                }
            }
            else {
                if (baseQuestionCell.rating.optionalSettings.picture) {
                    if (self.currentAuditGlobal.currentPictureCount < 1) {
                        passesPictureValidation = NO;
                    }
                }
                if (baseQuestionCell.rating.optionalSettings.defects) {
                    NSArray *defectsSet = baseQuestionCell.rating.defectsFromUI;
                    passesDefectValidation = NO;
                    for (Defect *defect in defectsSet) {
                        if (defect.isSetFromUI) {
                            passesDefectValidation = YES;
                            break;
                        }
                    }
                }
                if (!passesDefectValidation && !passesPictureValidation) {
                    indexOfFirstFailure = i;
                    break;
                }
            }
        }
        
        if (indexOfFirstFailure > -1) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexOfFirstFailure inSection:0];
            [self.ratingsTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    }
}

-(BOOL) isValidForDaysRemaining:(Rating*)rating withProduct:(Product*)product {
    return [self.currentAuditGlobal validateDaysRemainingMinConditionForRating:rating forProduct:product];
}

- (void) scannableButtonTouched {
    [[[UIAlertView alloc] initWithTitle: @"Feature Coming Soon" message: @"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}


#pragma mark - Table view data source

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

//Since the data depends on the UI to scroll and get the information
-(void) initMissingTableViewCells {
    for(int i=0; i<[self.ratingsGlobal count]; i++){
        BaseTableViewCell *baseTableCell = (BaseTableViewCell*)[self.ratingViewCells objectForKey:[NSNumber numberWithInt:i]];
        if(!baseTableCell){
            //NSLog(@"ProductRatingViewController.m - calling calling for %d", i);
        NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
        [self tableView:self.ratingsTableView cellForRowAtIndexPath:path];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id existingCell = [ratingViewCells objectForKey:[NSNumber numberWithInt:indexPath.row]];
    if (existingCell && existingCell != [NSNull null]) {
        BaseTableViewCell *baseTableViewCell = (BaseTableViewCell *)existingCell;
        if ([self.parentView isEqualToString:defineContainerViewController] && [[baseTableViewCell.rating.order_data_field lowercaseString] isEqualToString:@"ponumber"]) {
            [baseTableViewCell refreshState];
        } else if ([self.parentView isEqualToString:defineContainerViewController] && [[baseTableViewCell.rating.order_data_field lowercaseString] isEqualToString:@"vendorname"]) {
            [baseTableViewCell refreshState];
        }else if ([self.parentView isEqualToString:defineContainerViewController] && [[baseTableViewCell.rating.order_data_field lowercaseString] isEqualToString:@"loadid"]) {
            [baseTableViewCell refreshState];
        } else if ([self.parentView isEqualToString:defineContainerViewController] && [[baseTableViewCell.rating.order_data_field lowercaseString] isEqualToString:@"grn"]) {
                   [baseTableViewCell refreshState];
        }
        return baseTableViewCell;
    }
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
            
            TextRatingViewCell *newCell = [tableView dequeueReusableCellWithIdentifier:kTextRatingViewCellReuseID];
            if (newCell == nil) {
                [[NSBundle mainBundle] loadNibNamed:kTextRatingViewCellNIBFile owner:self options:nil];
                newCell = textRatingViewCell;
                self.textRatingViewCell = nil;
            }
            baseTableViewCell = (BaseTableViewCell*)newCell;
            
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
            
            baseTableViewCell.currentAudit = self.currentAuditGlobal;

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

- (void) populateRatingsToDictionary {
    
    UITableView *tableView;
    NSArray *ratings = self.ratingsGlobal;
    for (int i=0; i < [ratings count]; i++) {
        BaseTableViewCell *baseTableViewCell;
        Rating *rating = [ratings objectAtIndex:i];
        rating.productId = self.productGlobal.product_id; //associate the productId to rating ??? need this ??
        if (rating && [rating.type isEqualToString:STAR_RATING]) {
            StarRatingViewCell *newCell = [tableView dequeueReusableCellWithIdentifier:kStarRatingViewCellReuseID];
            if (newCell == nil) {
                [[NSBundle mainBundle] loadNibNamed:kStarRatingViewCellNIBFile owner:self options:nil];
                newCell = starRatingViewCell;
                self.starRatingViewCell = nil;
            }
            baseTableViewCell = (BaseTableViewCell*)newCell;
        } else if (rating && [rating.type isEqualToString:TEXT_RATING]) {
            TextRatingViewCell *newCell = [tableView dequeueReusableCellWithIdentifier:kTextRatingViewCellReuseID];
            if (newCell == nil) {
                [[NSBundle mainBundle] loadNibNamed:kTextRatingViewCellNIBFile owner:self options:nil];
                newCell = textRatingViewCell;
                self.textRatingViewCell = nil;
            }
            baseTableViewCell = (BaseTableViewCell*)newCell;
        } else if (rating && [rating.type isEqualToString:DATE_RATING]) {
            DateRatingViewCell *newCell = [tableView dequeueReusableCellWithIdentifier:kDateRatingViewCellReuseID];
            if (newCell == nil) {
                [[NSBundle mainBundle] loadNibNamed:kDateRatingViewCellNIBFile owner:self options:nil];
                newCell = dateRatingViewCell;
                self.dateRatingViewCell = nil;
            }
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
            baseTableViewCell.rating = rating;
            baseTableViewCell.myTableView = self.ratingsTableView;
            baseTableViewCell.myTableViewController = self;
            baseTableViewCell.questionNumber = i + 1;
            [ratingViewCells setObject:baseTableViewCell forKey:[NSNumber numberWithInt:i]];
        }
        UITableViewCell *emptyCell;
        emptyCell = [tableView dequeueReusableCellWithIdentifier:kEmptyTableCellIdentifier];
        if (emptyCell == nil) {
            emptyCell = [[UITableViewCell alloc]
                         initWithStyle:UITableViewCellStyleDefault
                         reuseIdentifier:kEmptyTableCellIdentifier];
            emptyCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
}

- (void) refreshTheView {
   // [self selectPONumberOptionForVendorNameSelected: string];
    [self.ratingsTableView reloadData];
}

- (void) refreshTheView:(NSString *) string {
    [self selectPONumberOptionForVendorNameSelected: string];
    [self.ratingsTableView reloadData];
}

- (void) refreshTheViewForVendorName: (NSString *) string {
    [self selectVendorNameForPONumberSelected: string];
    [self.ratingsTableView reloadData];
}

//reset the supplier and PO in container screen
-(void)resetView{
    NSMutableDictionary *dictionaryLocal = [[NSMutableDictionary alloc] init];
    for (NSNumber *key in self.ratingViewCells) {
        BaseTableViewCell *baseTableViewCellLocal = [self.ratingViewCells objectForKey:key];
        if ([baseTableViewCellLocal isKindOfClass:[SelectButtonRatingViewCell class]]) {
            if ([self.parentView isEqualToString:defineContainerViewController] && [[baseTableViewCellLocal.rating.order_data_field lowercaseString] isEqualToString:@"ponumber"]) {
                [baseTableViewCellLocal reset];
            }
            if ([self.parentView isEqualToString:defineContainerViewController] && [[baseTableViewCellLocal.rating.order_data_field lowercaseString] isEqualToString:@"vendorname"]) {
                [baseTableViewCellLocal reset];
            }
            if ([self.parentView isEqualToString:defineContainerViewController] && [[baseTableViewCellLocal.rating.order_data_field lowercaseString] isEqualToString:@"grn"]) {
                [baseTableViewCellLocal reset];
            }
        }
    }
    self.ratingViewCells = dictionaryLocal;
    //[self.ratingsTableView reloadData];
}

-(NSString*)getParentView{
    return self.parentView;
}
//check if an order-data rating is present
-(BOOL)isContainerRatingPresentWithOrderDataField:(NSString*)orderDataKey {
    
    for (NSNumber *key in self.ratingViewCells) {
        BaseTableViewCell *baseTableViewCellLocal = [self.ratingViewCells objectForKey:key];
        if ([baseTableViewCellLocal isKindOfClass:[SelectButtonRatingViewCell class]]) {
            if ([self.parentView isEqualToString:defineContainerViewController] && [[baseTableViewCellLocal.rating.order_data_field lowercaseString] isEqualToString:orderDataKey]) {
                return YES;
            }
        }
    }
    return NO;
}

//TODO migrate resetView to this method
-(void)resetOrderDataComboRatingWithKey:(NSString*)orderDataKey {
    for (NSNumber *key in self.ratingViewCells) {
        BaseTableViewCell *baseTableViewCellLocal = [self.ratingViewCells objectForKey:key];
        if ([baseTableViewCellLocal isKindOfClass:[SelectButtonRatingViewCell class]]) {
            if ([self.parentView isEqualToString:defineContainerViewController] && [[baseTableViewCellLocal.rating.order_data_field lowercaseString] isEqualToString:orderDataKey]) {
                [baseTableViewCellLocal reset];
            }
        }
    }
    [self.ratingsTableView reloadData];
}

- (void) selectPONumberOptionForVendorNameSelected: (NSString *) string {
    NSMutableDictionary *dictionaryLocal = [[NSMutableDictionary alloc] init];
    for (NSNumber *key in self.ratingViewCells) {
        BaseTableViewCell *baseTableViewCellLocal = [self.ratingViewCells objectForKey:key];
        if ([baseTableViewCellLocal isKindOfClass:[SelectButtonRatingViewCell class]]) {
            if ([self.parentView isEqualToString:defineContainerViewController] && [[baseTableViewCellLocal.rating.order_data_field lowercaseString] isEqualToString:@"ponumber"]) {
                baseTableViewCellLocal.rating.ratingAnswerFromUI = string;
                //NSLog(@"key si %@", key);
                [dictionaryLocal setObject:baseTableViewCellLocal forKey:key];
            }
            if ([self.parentView isEqualToString:defineContainerViewController] && [[baseTableViewCellLocal.rating.order_data_field lowercaseString] isEqualToString:@"grn"]) {
                baseTableViewCellLocal.rating.ratingAnswerFromUI = string;
                //NSLog(@"key si %@", key);
                [dictionaryLocal setObject:baseTableViewCellLocal forKey:key];
            }
        }
    }
    self.ratingViewCells = dictionaryLocal;
}
//1
- (void) setOrderDataComboRatingValue:(NSString *) string withOrderDataKey:(NSString*)orderDatakey {
    NSMutableDictionary *dictionaryLocal = [[NSMutableDictionary alloc] init];
    for (NSNumber *key in self.ratingViewCells) {
        BaseTableViewCell *baseTableViewCellLocal = [self.ratingViewCells objectForKey:key];
        if ([baseTableViewCellLocal isKindOfClass:[SelectButtonRatingViewCell class]]) {
          //  if ([self.parentView isEqualToString:defineContainerViewController] && [[baseTableViewCellLocal.rating.order_data_field lowercaseString] isEqualToString:orderDatakey]) {
            if ([self.parentView isEqualToString:defineContainerViewController] && [[baseTableViewCellLocal.rating.order_data_field lowercaseString] isEqualToString:@"loadid"]) {
                baseTableViewCellLocal.rating.ratingAnswerFromUI = string;
                //NSLog(@"key si %@", key);
                [dictionaryLocal setObject:baseTableViewCellLocal forKey:key];
            }
        }
    }
   // self.ratingViewCells = dictionaryLocal;
}

//2
- (void) selectVendorNameForPONumberSelected: (NSString *) string {
    NSMutableDictionary *dictionaryLocal = [[NSMutableDictionary alloc] init];
    for (NSNumber *key in self.ratingViewCells) {
        BaseTableViewCell *baseTableViewCellLocal = [self.ratingViewCells objectForKey:key];
        if ([baseTableViewCellLocal isKindOfClass:[SelectButtonRatingViewCell class]]) {
            if ([self.parentView isEqualToString:defineContainerViewController] && [[baseTableViewCellLocal.rating.order_data_field lowercaseString] isEqualToString:@"vendorname"]) {
                baseTableViewCellLocal.rating.ratingAnswerFromUI = string;
                //NSLog(@"key si %@", key);
                [dictionaryLocal setObject:baseTableViewCellLocal forKey:key];
            } else if ([self.parentView isEqualToString:defineContainerViewController] && [[baseTableViewCellLocal.rating.order_data_field lowercaseString] isEqualToString:@"ponumber"]) {
                baseTableViewCellLocal.rating.ratingAnswerFromUI = [[User sharedUser] temporaryPONumberFromUserClass];
                [dictionaryLocal setObject:baseTableViewCellLocal forKey:key];
            }
            else if ([self.parentView isEqualToString:defineContainerViewController] && [[baseTableViewCellLocal.rating.order_data_field lowercaseString] isEqualToString:@"grn"]) {
                           baseTableViewCellLocal.rating.ratingAnswerFromUI = [[User sharedUser] temporaryGRNFromUserClass];
                           [dictionaryLocal setObject:baseTableViewCellLocal forKey:key];
                       }
        }
    }
    self.ratingViewCells = dictionaryLocal;
}
/*
#pragma mark - Container OrderData

-(NSArray*)getOrderDataByContainer {
    return self.filteredOrderDataByContainer;
}
*/

#pragma mark - TableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *ratingsLocal = self.ratingsGlobal;
    if (ratingsLocal && [ratingsLocal count] > indexPath.row) {
        Rating *rating = [ratingsLocal objectAtIndex:indexPath.row];
        if (rating && [rating.type isEqualToString:STAR_RATING]) {
            return [StarRatingViewCell myCellHeight:rating];
            
        } else if (rating && [rating.type isEqualToString:TEXT_RATING]) {
            return [TextRatingViewCell myCellHeight:rating];
            
        } else if (rating && [rating.type isEqualToString:DATE_RATING]) {
            return [DateRatingViewCell myCellHeight:rating];
            
        } else if (rating && [rating.type isEqualToString:NUMERIC_RATING]) {
            return [NumericRatingViewCell myCellHeight:rating];
            
        } else if (rating && [rating.type isEqualToString:PRICE_RATING]) {
            return [PriceRatingViewCell myCellHeight:rating];
            
        } else if (rating && [rating.type isEqualToString:COMBO_BOX_RATING]) {
            return [SelectButtonRatingViewCell myCellHeight:rating];
            
        } else if (rating && [rating.type isEqualToString:BOOLEAN_RATING]) {
            return [PriceRatingViewCell myCellHeight:rating];
        } else if (rating && [rating.type isEqualToString:LABEL_RATING]) {
            return [LabelRatingViewCell myCellHeight:rating];
        }
    }
    
    return 96.0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 0.0;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    id existingCell = [self.ratingViewCells objectForKey:[NSNumber numberWithInt:indexPath.row]];
//    if (existingCell && existingCell != [NSNull null]) {
//        
//        if ([existingCell isKindOfClass:[DateRatingViewCell class]]) {
//            [self.ratingsTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
//            [(DateRatingViewCell*)existingCell launchDatePicker];
//        }
//    }
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	return nil;
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

- (void)viewDidDisappear:(BOOL)animated {
    
    //NSLog(@"unload");
}

//- (IBAction)previousButton:(id)sender {
//    [self.navigationController popViewControllerAnimated:YES];
//}
//
//- (IBAction)doneButton:(id)sender {
//    [self.navigationController popViewControllerAnimated:YES];
//}


#pragma mark - FailedValidationViewProtocol Methods


- (void)failedValidationClosed
{
    NSInteger indexOfFirstFailure = -1;
    for (NSInteger i = 0; i < [self.ratingsGlobal count]; i++) {
        BaseTableViewCell *baseQuestionCell = (BaseTableViewCell*)[ratingViewCells objectForKey:[NSNumber numberWithInt:i]];
        if ([baseQuestionCell.rating.type isEqualToString:PRICE_RATING]) {
            if (![baseQuestionCell validateForPriceAndNumericRating]) {
                indexOfFirstFailure = i;
                break;
            }
        } else if ([baseQuestionCell.rating.type isEqualToString:NUMERIC_RATING]) {
            if (![baseQuestionCell validateForNumericRating]) {
                indexOfFirstFailure = i;
                break;
            }
        } else  {
            if (![baseQuestionCell validate]) {
                indexOfFirstFailure = i;
                break;
            }
        }
    }
    
    if (indexOfFirstFailure > -1) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexOfFirstFailure inSection:0];
        [self.ratingsTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (void)checkCountOfCases:(Rating *)currentRating withCount:(NSString *)count{
    if ([parentView isEqualToString:@"ProductViewController"]) {
        [delegate checkCountOfCases:currentRating withCount:count];
    }
}

@end
