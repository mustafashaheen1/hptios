//
//  ViewController.m
//  CollapseClick
//
//  Created by Ben Gordon on 2/28/13.
//  Copyright (c) 2013 Ben Gordon. All rights reserved.
//

#import "InspectionStatusViewController.h"
#import "DefectsViewCell.h"
#import "InspectionViewControllerWithTableViewController.h"
#import "HomeScreenViewController.h"
#import "Inspection.h"
#import "SKSTableViewCell.h"
#import "Inspection.h"
#import "SavedAudit.h"
#import "ProductViewController.h"
#import "ProductSelectAutoCompleteViewController.h"
#import "ProgramGroup.h"
#import "OrderData.h"
#import "UIAlertView+NSCookbook.h"
#import "ContainerViewController.h"
#import "RowSectionButton.h"
#import "RowSectionPopOverListView.h"
#import "IMResult.h"
#import "FlaggedMessage.h"

#define heightForCells 50
#define pageTitleString @"InspectionStatusViewController"
#define finishingUp @"Finishing Up"
#define widthForModifyButtonTouch 230

@interface InspectionStatusViewController ()

/*!
 *  Method to check CountOfCases. If CountOfCases is zero then show an alertview asking for CountOfCases from the user (only for non order data inspection), else calculate summary and update CountOfCases on the view. Recalculate saved audits once summary is updated.
 */
- (void) ifCountOfCasesIsNotCalculatedForThoseAuditsCalculateThemAndUpdateTheSavedAuditsArray;
/*!
 *  Alertview setup for CountOfCases. If the user enters nothing and hits ok, we show them the Alert again.
 *
 *  @param productName AlertView title
 *  @param savedAudit  Saved Audit object.
 */
- (void) showAlertForCountOfCasesEntering: (NSString *) productName withSavedAudit:(SavedAudit *) savedAudit;
/*!
 *  Method to calculate summary and update CountOfCases on the view.
 *
 *  @param savedAudit    SavedAudit object.
 *  @param countOfCases  countOfCases
 *  @param databaseLocal Database instance
 *
 *  @return is recalculation necessary or not.
 */

- (BOOL) getSummaryAndUpdateCountOfCasesNoMatterWhat: (SavedAudit *) savedAudit withCountOfCases: (int) countOfCases withDatabase: (FMDatabase *) databaseLocal;
/*!
 *  This method takes care of creating fake audits for the products with no audits count
 */

- (void) createSavedAuditsForProductsWithNoAuditsCount;

@end

@implementation InspectionStatusViewController

@synthesize productNameLabel;
@synthesize countOfCasesLabel;
@synthesize imgView;
@synthesize btnToModify;

/*!
 *  Initiate All the dictionaries.
 */
- (void)viewDidLoad
{
    self.summaryDictionary = [NSMutableDictionary dictionary];
    self.keepTrackOfOpenedRows = [NSMutableDictionary dictionary];
    self.summaryDictionaryForChangeStatus = [NSMutableDictionary dictionary];
    self.navigationButtonsTapped = NO;
    self.globalInspectionStatus = [[InspectionStatus alloc]init];
    self.hasDefects = YES;
    self.nonScoreableIndex = 0;
    self.scoreableIndex = 0;
    self.productId = 0;
    self.selected = NO;
    self.previousInspectionStatus = @"";
    [super viewDidLoad];
    
}

- (void) setupNavBar {
    [super setupNavBar];
    self.cancelButton.enabled = NO;
    self.finishButton.enabled = NO;
    self.saveButton.enabled = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.globalInspectionStatus = [[InspectionStatus alloc]init];
    self.pageTitle = pageTitleString;
    UIWindow *win = [[UIApplication sharedApplication] keyWindow];
    self.syncOverlayView = [[SyncOverlayView alloc] initWithFrame:CGRectMake(0, 0, win.frame.size.width, win.frame.size.height)];
    self.syncOverlayView.headingTitleLabel.text = @"Loading View";
    [self.syncOverlayView showActivityView];
    [win addSubview:self.syncOverlayView];
    [self setupNavBar];
    [self resetSearchBox];
    [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:introducingDelayForDuplicates]];
    self.cancelButton.enabled = YES;
    self.finishButton.enabled = YES;
    self.saveButton.enabled = YES;
    //DI-1686 / DI-1728 - hide select product button in order-data
    if([[Inspection sharedInspection] checkForOrderData]){
        //self.productSelectButton.hidden = YES;
        self.listButton.hidden = YES;
    }
    if([CollobarativeInspection isCollaborativeInspectionsEnabled] && [[Inspection sharedInspection] checkForOrderData]){
        CollobarativeInspection* collobarativeInsp = [[Inspection sharedInspection] collobarativeInspection];
        if(!collobarativeInsp) {
            collobarativeInsp = [[CollobarativeInspection alloc]init];
            [Inspection sharedInspection].collobarativeInspection = collobarativeInsp;
            NSString* po = [Inspection sharedInspection].poNumberGlobal;
            [collobarativeInsp initCollabInspectionsForPO:po withBlock:^(BOOL success) {
                
            }];
        }
    }
}

/*!
 *  1) Add a loading indicator right after the view appears.
 *  2) Get all the saved audits from the Inspection class.
 *  3) Check for Order Data. If yes, get all the products the same way as Product select screen (runs in a separate thread).
 *  4) Calculate count of cases for all the saved audits
 *
 *  @param animated animated
 */
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        self.statusValues = [NSArray arrayWithObjects: @"Accept", @"Accept With Issues", @"Reject", nil];
        self.pageTitle = @"InspectionStatusViewController";
        if ([[Inspection sharedInspection] checkForOrderData]) {
            if ([[Inspection sharedInspection].productGroups count] < 1) {
                [Inspection sharedInspection].productGroups = [[User sharedUser].currentStore getProductGroups];
            }
            NSString *poNumber = [Inspection sharedInspection].poNumberGlobal;
            NSSet *set;
            if((![poNumber  isEqual: @""]) && (poNumber != nil)){
                set = [OrderData getItemNumbersForPONumberSelected];
            }else{
                set = [OrderData getItemNumbersForGRNSelected];
            }
             
            NSArray *newProductGroupsArray = [[Inspection sharedInspection] filteredProductGroups:set];
            [Inspection sharedInspection].productGroups = newProductGroupsArray;
            self.productAudits = [[Inspection sharedInspection] getAllSavedAndFakeAuditsForInspection];
        } else
            self.productAudits = [[Inspection sharedInspection] getAllSavedAuditsForInspection];
        [self sortProductAuditsByName];
        self.distinctSupplierNames = [[Inspection sharedInspection] groupSupplierNames:self.productAudits];
        /*for(SavedAudit *audit in self.productAudits){
            NSLog(@"InspectionStatusViewController.m viewDidAppear - self.productAudit audit is: %@", audit.description);
        }*/
        
        [self populateInspectionMinimumDictionary];
        [self initializeCacheWithProductGroups:self.productAudits];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self ifCountOfCasesIsNotCalculatedForThoseAuditsCalculateThemAndUpdateTheSavedAuditsArray];
            [self tableViewSetup];
            [self.syncOverlayView dismissActivityView];
            [self.syncOverlayView removeFromSuperview];
        });
    });
}

-(void)initializeCacheWithProductGroups:(NSMutableArray*)productAudits
{
    self.productAudits = productAudits;
    self.productAuditsCacheForAutoComplete = self.productAudits;
    //self.cacheForAllProducts = self.productGroups;
    //self.productGroupsDidSelectGlobalArray = self.productGroups;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

-(void)resetSearchBox
{
    [self.searchField setText:@""];
    [self.searchField resignFirstResponder];
    self.searchField.delegate = self;
}

-(void)listButtonTouched {
    [self goToProductListScreen];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    [self.table removeFromSuperview];
    self.productAudits = [[NSMutableArray alloc] init];
    [self.productAudits addObjectsFromArray:self.productAuditsCacheForAutoComplete];
    self.productAuditsCacheForAutoComplete = [[NSArray alloc] init];
    self.productAuditsCacheForAutoComplete = self.productAudits;
    [self tableViewSetup];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void) sortProductAuditsByName {
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"productName" ascending:YES];
    NSArray *sortDescriptors = @[sort];
    self.productAudits = [self.productAudits sortedArrayUsingDescriptors:sortDescriptors];
    //return sortedArray;
}

//dict of groupId<->InspectionMinimums for quick access in cellrows
-(void)populateInspectionMinimumDictionary {
    InspectionMinimumsAPI* inspectionMinimum = [[InspectionMinimumsAPI alloc]init];
    if(!self.inspectionMinimums)
        self.inspectionMinimums = [[NSMutableDictionary alloc]init];
    for(SavedAudit *product in self.productAudits){
        InspectionMinimums *minimums = [inspectionMinimum getMinimumInspectionForGroup:product.productGroupId];
        NSString* productGroupIdString = [NSString stringWithFormat:@"%d",product.productGroupId];
        [self.inspectionMinimums setObject:minimums forKey:productGroupIdString];
        
    }
}

//recalculate the savedAudit/self.productaudtis - equivalent of viewDidAppear
-(void) refreshSavedAudits{
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        self.statusValues = [NSArray arrayWithObjects: @"Accept", @"Accept With Issues", @"Reject", nil];
        self.pageTitle = @"InspectionStatusViewController";
        if ([[Inspection sharedInspection] checkForOrderData]) {
            if ([[Inspection sharedInspection].productGroups count] < 1) {
                [Inspection sharedInspection].productGroups = [[User sharedUser].currentStore getProductGroups];
            }
            NSString *poNumber = [Inspection sharedInspection].poNumberGlobal;
            NSSet *set;
            if((![poNumber  isEqual: @""]) && (poNumber != nil)){
                set = [OrderData getItemNumbersForPONumberSelected];
            }else{
                set = [OrderData getItemNumbersForGRNSelected];
            }
            NSArray *newProductGroupsArray = [[Inspection sharedInspection] filteredProductGroups:set];
            [Inspection sharedInspection].productGroups = newProductGroupsArray;
            self.productAudits = [[Inspection sharedInspection] getAllSavedAndFakeAuditsForInspection];
        } else
            self.productAudits = [[Inspection sharedInspection] getAllSavedAuditsForInspection];
        self.distinctSupplierNames = [[Inspection sharedInspection] groupSupplierNames:self.productAudits];
        /*for(SavedAudit *audit in self.productAudits){
            NSLog(@"InspectionStatusViewController.m   refreshAudits - self.productAudit audit is: %@", audit.description);
        }*/
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self ifCountOfCasesIsNotCalculatedForThoseAuditsCalculateThemAndUpdateTheSavedAuditsArray];
            [self tableViewSetup];//??
            [self.syncOverlayView dismissActivityView];
            [self.syncOverlayView removeFromSuperview];
        });
    });
}


-(void) printProductAudits {
    for(SavedAudit *audit in self.productAudits){
        NSLog(@"InspectionStatusViewController.m  - self.productAudit audit is: %@", audit.description);
    }
}

/*!
 *  Table View setup
 */

- (void) tableViewSetup {
    self.table = [[SKSTableView alloc] initWithFrame:CGRectMake(0, 85, self.view.frame.size.width, self.view.frame.size.height - 50)];
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        self.table.frame = CGRectMake(0, 85, self.view.frame.size.width, self.view.frame.size.height-70);
    }
    if (IS_IPHONE5) {
        self.table.frame = CGRectMake(0, 85, self.view.frame.size.width, self.view.frame.size.height - 50);
    }
    self.table.SKSTableViewDelegate = self;
    self.table.shouldExpandOnlyOneCell = YES;
    self.table.inspectionStatusViewController = YES;

    [self.view addSubview:self.table];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*!
 *  Save button action. This will popup an alertview asking for an Inspection name if there are more than one audit, else the action will fail.
 */
// rename for the icon (earlier was called -  saveForInspectionStatusTouched)
- (void) saveButtonTouched {
    
   // [self getDefects];
   // if(self.hasDefects)
   // {
        NSArray *savedAudits = self.productAudits;
        
        int count = 0;
        for (SavedAudit *savedAudit in savedAudits) {
            count = count + savedAudit.auditsCount;
            
        }
        if (count > 0) {
            UIAlertView* dialog = [[UIAlertView alloc] initWithTitle:@"Enter Inspection Name" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            [dialog setAlertViewStyle:UIAlertViewStylePlainTextInput];
            [[dialog textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeDefault];
            NSString *inspectionNameLocal = [[Inspection sharedInspection] inspectionName];
            if (inspectionNameLocal && ![inspectionNameLocal isEqualToString:@""]) {
                [[dialog textFieldAtIndex:0] setText:inspectionNameLocal];
            }
            [dialog show];
        } else {
            SCLAlertView *alert = [[SCLAlertView alloc] init];
            UIWindow *win = [[UIApplication sharedApplication] keyWindow];
            [alert showWarning:win.rootViewController title:@"Save failed" subTitle:@"No audits available to save" closeButtonTitle:@"OK" duration:0.0f];
            //[[[UIAlertView alloc] initWithTitle:@"No audits available to save" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        }
   /* }else{
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Warning" message:@"Please add at least one defect for each product that is being Rejected or Accepted with Issues before continuing."
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:@"Submit Anyway", nil];
        [alert setTag:5];
        [alert show];
    }
    */
}

/*!
 *  Method to check CountOfCases. If CountOfCases is zero then show an alertview asking for CountOfCases from the user (only for non order data inspection), else calculate summary and update CountOfCases on the view. Recalculate saved audits once summary is updated.
 */
- (void) ifCountOfCasesIsNotCalculatedForThoseAuditsCalculateThemAndUpdateTheSavedAuditsArray {
   // __block BOOL isRecalculationNecessary = NO;
   // __block BOOL isRecalculationNecessaryLocal = NO;
    dispatch_queue_t backgroundQueue = dispatch_queue_create("com.mycompany.myqueue", 0);
    dispatch_async(backgroundQueue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            for (SavedAudit *savedAudit in self.productAudits) {
                if (savedAudit.countOfCases < OrderDataMinimumCount) {
                    if (![[Inspection sharedInspection] checkForOrderData]) {
                        [self showAlertForCountOfCasesEntering:savedAudit.productName withSavedAudit:savedAudit];
                    }
                } else {
//                    isRecalculationNecessaryLocal = [self getSummaryAndUpdateCountOfCasesNoMatterWhat:savedAudit withCountOfCases:savedAudit.countOfCases withDatabase:nil];
//                    if (isRecalculationNecessaryLocal) {
//                        isRecalculationNecessary = isRecalculationNecessaryLocal;
//                    }
                }
            }
            //if (isRecalculationNecessary) {
                FMDatabase *databaseGroupRatings;
                databaseGroupRatings = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
                [databaseGroupRatings open];
                [self recalculateSavedAuditsWithDatabase:databaseGroupRatings withEdit:NO];
                [databaseGroupRatings close];
           // }
            [self.table reloadData];
        });
    });
}

- (BOOL) checkForCountOfCasesRating: (Product *) product {
    BOOL ratingPresent = NO;
    for (Rating *rating in product.ratings) {
        if([rating.name compare:@"COUNT OF CASES" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            ratingPresent = YES;
        }
    }
    return ratingPresent;
}

/*!
 *  Alertview setup for CountOfCases. If the user enters nothing and hits ok, we show them the Alert again.
 *
 *  @param productName AlertView title
 *  @param savedAudit  Saved Audit object.
 */
- (void) showAlertForCountOfCasesEntering: (NSString *) productName withSavedAudit:(SavedAudit *) savedAudit {
    NSString *text = [NSString stringWithFormat:@"Please enter count of cases for %@.", savedAudit.productName];
    if ([savedAudit.productName isEqualToString:@""]) {
        text = [NSString stringWithFormat:@"Please enter count of cases."];
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:text
                                                    message:@""
                                                   delegate:self
                                          cancelButtonTitle:@"Done"
                                          otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textField = [alert textFieldAtIndex:0];
    textField.keyboardType = UIKeyboardTypeNumberPad;
    [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
        //NSLog(@"%@", [alertView textFieldAtIndex:0].text);
        if (![[alertView textFieldAtIndex:0].text isEqualToString:@""]) {
            NSString *countString = [alertView textFieldAtIndex:0].text;
            int countOfCases = [countString integerValue];
            if (countOfCases > 0) {
                [self getSummaryAndUpdateCountOfCasesNoMatterWhat:savedAudit withCountOfCases:countOfCases withDatabase:nil];
            } else {
                [self showAlertForCountOfCasesEntering:@"" withSavedAudit:savedAudit];
            }
        } else {
            [self showAlertForCountOfCasesEntering:@"" withSavedAudit:savedAudit];
        }
    }];
}

/*!
 *  Method to calculate summary and update CountOfCases on the view.
 *
 *  @param savedAudit    SavedAudit object.
 *  @param countOfCases  countOfCases
 *  @param databaseLocal Database instance
 *
 *  @return is recalculation necessary or not.
 */

- (BOOL) getSummaryAndUpdateCountOfCasesNoMatterWhat: (SavedAudit *) savedAudit withCountOfCases: (int) countOfCases withDatabase: (FMDatabase *) databaseLocal {
    BOOL isRecalculationNecessary = NO;
    if (savedAudit.inspectionStatus && [savedAudit.inspectionStatus isEqualToString:@""]) {
        isRecalculationNecessary = YES;
        int gID = savedAudit.productGroupId;
        int productId = savedAudit.productId;
        Summary *summary = [[Summary alloc] init];
        summary.productName = savedAudit.productName;
        summary.totalCountOfCases = countOfCases;
        __block FMDatabase *database;
        if (!databaseLocal || ![databaseLocal goodConnection]) {
            database = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
            [database open];
        } else {
            database = databaseLocal;
        }
        UserNetworkActivityView *activityView = [UserNetworkActivityView sharedActivityView];
        [activityView setCustomMessage:@"Loading..."];
        if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
            [activityView show:self withOperation:nil showCancel:NO];
        }
        dispatch_queue_t backgroundQueue = dispatch_queue_create("com.mycompany.myqueue", 0);
        dispatch_async(backgroundQueue, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [summary getSummaryOfAudits:[self getProduct:gID withProductID:productId] withGroupId:[NSString stringWithFormat:@"%d", savedAudit.productGroupId] withSplitGroupId:[Inspection sharedInspection].currentSplitGroupId withDatabase:database];
                [summary updateCountOfCasesInDB:[NSString stringWithFormat:@"%d", countOfCases] withInspectionCount:[NSString stringWithFormat:@"%d", self.summary.inspectionCountOfCases] withGroupId:[NSString stringWithFormat:@"%d", savedAudit.productGroupId] withProductId:[NSString stringWithFormat:@"%d", savedAudit.productId] withDatabase:database];
                if (!databaseLocal) {
                    [database close];
                }else
                    [databaseLocal close];
                if (![UserNetworkActivityView sharedActivityView].hidden)
                    [[UserNetworkActivityView sharedActivityView] hide];
            });
        });
    }
    return isRecalculationNecessary;
}

/*!
 *  AlertView return values.
 *
 *  @param alertView   Alertview object
 *  @param buttonIndex Buttonindex tapped
 */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    
    switch (alertView.tag) {
        case 2:
            if (buttonIndex == alertView.cancelButtonIndex) {
                //NSLog(@"cancelling inspection");
            }
            if (buttonIndex == alertView.firstOtherButtonIndex) {
                //NSLog(@"cancelling inspection");
                //[alertView dismissWithClickedButtonIndex:-1 animated:NO];
                [[Inspection sharedInspection] cancelInspection];
                [[Inspection sharedInspection] cleanupCollaborativeInspections];
                
                [self gotoHomeScreen];
            }
            break;
        case 3:
            if (buttonIndex == alertView.cancelButtonIndex) {
                //NSLog(@"cancelling inspection");
            }
            if (buttonIndex == alertView.firstOtherButtonIndex) {
                //NSLog(@"cancelling inspection");
                [self finishButtonTapped];
            }
            break;
        case 4:
            if(buttonIndex == alertView.firstOtherButtonIndex)
            {
                NSString *finish = @"Finish Inspection?";
                NSString *preventString = @"Finishing the inspection will prevent further modifications.";
                NSString *cannotString = @"Cannot finish inspection with no audits completed.";
                if ([[User sharedUser] checkForRetailInsights]) {
                    finish = @"Finish Audit?";
                    preventString = @"Finishing the audit will prevent further modifications.";
                    cannotString = @"Cannot finish audits.";
                }
                if ([self.productAudits count] > 0) {
                    UIAlertView *alert = [[UIAlertView alloc]
                                          initWithTitle:finish message:preventString
                                          delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Ok", nil];
                    [alert setTag:3];
                    [alert show];
                    
                } else {
                    [[[UIAlertView alloc] initWithTitle:finish message:cannotString delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
                }
            }
            break;
        case 5:
            if(buttonIndex == alertView.firstOtherButtonIndex)
            {
                NSArray *savedAudits = self.productAudits;
                
                int count = 0;
                for (SavedAudit *savedAudit in savedAudits) {
                    count = count + savedAudit.auditsCount;
                    
                }
                if (count > 0) {
                    UIAlertView* dialog = [[UIAlertView alloc] initWithTitle:@"Enter Inspection Name" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
                    [dialog setAlertViewStyle:UIAlertViewStylePlainTextInput];
                    [[dialog textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeDefault];
                    NSString *inspectionNameLocal = [[Inspection sharedInspection] inspectionName];
                    if (inspectionNameLocal && ![inspectionNameLocal isEqualToString:@""]) {
                        [[dialog textFieldAtIndex:0] setText:inspectionNameLocal];
                    }
                    [dialog show];
                } else {
                    SCLAlertView *alert = [[SCLAlertView alloc] init];
                    UIWindow *win = [[UIApplication sharedApplication] keyWindow];
                    [alert showWarning:win.rootViewController title:@"Save failed" subTitle:@"No audits available to save" closeButtonTitle:@"OK" duration:0.0f];
                    //[[[UIAlertView alloc] initWithTitle:@"No audits available to save" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
                }
            }
            break;
        default:
            if (buttonIndex == 1) {
                if (![[[alertView textFieldAtIndex:0] text] isEqualToString:@""]) {
                    [[Inspection sharedInspection] saveInspection:[[alertView textFieldAtIndex:0] text]];
                    [self gotoHomeScreen];
                } else {
                    [[[UIAlertView alloc] initWithTitle:@"Name Cant be Empty" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
                }
            }
            break;
    }
}


/*!
 *  Function call to perform finish operation. This method takes care of creating fake audits for the products with no audits count and also finishing up the inspection.
 */

- (void) performFinish {
    if([CollobarativeInspection isCollaborativeInspectionsEnabled]){
        [self performFinishWithCollabInspection];
        return;
    }
    UIWindow *win = [[UIApplication sharedApplication] keyWindow];
    self.syncOverlayView = [[SyncOverlayView alloc] initWithFrame:CGRectMake(0, 0, win.frame.size.width, win.frame.size.height)];
    self.syncOverlayView.headingTitleLabel.text = finisingUp;
    [self.syncOverlayView showActivityView];
    [win addSubview:self.syncOverlayView];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //do not save and submit fake audits - DI-1571
        // [self createSavedAuditsForProductsWithNoAuditsCount];
        [[Inspection sharedInspection] finishInspection];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self gotoHomeScreen];
            [self.syncOverlayView dismissActivityView];
            [self.syncOverlayView removeFromSuperview];
        });
    });
}

-(void) performFinishWithCollabInspection {
    UIWindow *win = [[UIApplication sharedApplication] keyWindow];
    self.syncOverlayView = [[SyncOverlayView alloc] initWithFrame:CGRectMake(0, 0, win.frame.size.width, win.frame.size.height)];
    self.syncOverlayView.headingTitleLabel.text = finisingUp;
    [self.syncOverlayView showActivityView];
    [win addSubview:self.syncOverlayView];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        CollaborativeAPISaveRequest *apiSaveRequest = [[CollaborativeAPISaveRequest alloc]init];
        apiSaveRequest.store_id = (int)[User sharedUser].currentStore.storeID;
        apiSaveRequest.po = [[Inspection sharedInspection] poNumberGlobal];
        apiSaveRequest.status = STATUS_FINSIHED;
        
        NSMutableArray<NSNumber*> *allProducts = [[NSMutableArray<NSNumber*> alloc]init];
        for(SavedAudit *audit in self.productAudits){
            if((audit.auditsCount>0 || audit.userEnteredAuditsCount>0) && (audit.productId!=0))
            [allProducts addObject:[NSNumber numberWithInt:audit.productId]];
        }
        apiSaveRequest.product_ids = allProducts;
        
        CollobarativeInspection* collobarativeInsp = [[Inspection sharedInspection] collobarativeInspection];
        if(collobarativeInsp){
            CollobarativeInspection* collobarativeInsp = [Inspection sharedInspection].collobarativeInspection;
            [collobarativeInsp updateCollaborativeInspection:apiSaveRequest withBlock:^(BOOL success, NSError *error) {
                /*if(success){
                    [[[UIAlertView alloc] initWithTitle:@"Success" message: @"updated" delegate: self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
                }else{
                    [[[UIAlertView alloc] initWithTitle:@"Error" message: error.description delegate: self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
                }*/
                
                //do not save and submit fake audits - DI-1571
                //[self createSavedAuditsForProductsWithNoAuditsCount];
                [[Inspection sharedInspection] finishInspection];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self gotoHomeScreen];
                    [self.syncOverlayView dismissActivityView];
                    [self.syncOverlayView removeFromSuperview];
                });
            }];
        }else { //init collobarative inspections
          //[self initializeCollabInspectionsInstance];
           // [self createSavedAuditsForProductsWithNoAuditsCount];
            [[Inspection sharedInspection] finishInspection];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self gotoHomeScreen];
                [self.syncOverlayView dismissActivityView];
                [self.syncOverlayView removeFromSuperview];
            });
            [[[UIAlertView alloc] initWithTitle:@"Error" message: @"Collaborative Inspection could not be updated" delegate: self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
          }
    });
}

/*!
 *  This method takes care of creating fake audits for the products with no audits count
 */

- (void) createSavedAuditsForProductsWithNoAuditsCount {
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
    [database open];
    for(int i=0; i < [self.productAudits count]; i++) {
        // if duplicateAuditCount = 0, then do not duplicate the audit
        SavedAudit *savedAudit = [self.productAudits objectAtIndex:i];
        CurrentAudit *currentAudit = [[CurrentAudit alloc] init];
        Product *product = [[Inspection sharedInspection] getProductForProductId:savedAudit.productId withGroupId:savedAudit.productGroupId];
        //to get the selected sku of the product
        Product *productObjectFromProductGroups = [[Inspection sharedInspection] getProductForProductIdFromProductGroups:savedAudit.productId withGroupId:savedAudit.productGroupId];
        product.selectedSku = productObjectFromProductGroups.selectedSku;
        //NSLog(@"SKU IS: %@ - %@", product.name, product.selectedSku);
        self.globalAuditMasterId = [Inspection sharedInspection].auditMasterId;
        [currentAudit setAllTheCurrentAuditVariables:0 withAuditMasterId:[Inspection sharedInspection].auditMasterId withAuditGroupId:[DeviceManager getCurrentTimeString] withProductID:savedAudit.productId withProductGroupID:savedAudit.productGroupId withProgramID:product.program_id withProgramVersion:[product.program_version integerValue] withDatabase:database];
        currentAudit.auditEndTime = [DeviceManager getCurrentTimeString];
        currentAudit.product = product;
        NSString *auditJSON = [currentAudit generateAuditJson:NO];
        //NSLog(@"JSON Inserted Is: %@", auditJSON);
        if (savedAudit.auditsCount < 1) {
            self.globalAuditMasterId = [Inspection sharedInspection].auditMasterId;
            [database executeUpdate:@"insert into SAVED_AUDITS (AUDIT_MASTER_ID, AUDIT_GROUP_ID, AUDIT_PRODUCT_ID, product_name, AUDIT_JSON, INSP_STATUS, audit_count, productGroup_id, IMAGES) values (?,?,?,?,?,?,?,?,?)", [NSString stringWithFormat:@"%@", [Inspection sharedInspection].auditMasterId], [DeviceManager getCurrentTimeString], [NSString stringWithFormat:@"%d", savedAudit.productId], savedAudit.productName, auditJSON, @"ACCEPT", @"", [NSString stringWithFormat:@"%d", savedAudit.productGroupId], @""];
        }
    }
    [database close];
}

/*!
 *  Cancel inspection method.
 */

- (void) cancelInspectionStatusTouched {
    NSString *cancel = @"Cancel Inspection?";
    NSString *cancelMessage = @"Cancelling the inspection will erase all work done";
    if ([[User sharedUser] checkForRetailInsights]) {
        cancel = @"Cancel Audit?";
        cancelMessage = @"Cancelling the audits will erase all work done";
    }
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:cancel message:cancelMessage
                          delegate:self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"Ok", nil];
    [alert setTag:2];
    [alert show];
//    SCLAlertView *alert = [[SCLAlertView alloc] init];
//    [alert addButton:@"Ok" target:self selector:@selector(cancelButtonTapped)];
//    [alert addButton:@"Cancel" actionBlock:^(void) {
//    }];
//    UIWindow *win = [[UIApplication sharedApplication] keyWindow];
//    [alert showSuccess:win.rootViewController title:cancel subTitle:cancelMessage closeButtonTitle:nil duration:0.0f];
}

- (void) cancelButtonTapped {
    [[Inspection sharedInspection] cancelInspection];
    [[Inspection sharedInspection] cleanupCollaborativeInspections];
    [self gotoHomeScreen];
}

/*!
 *  This method will take the user to the home screen and brings Container View on top of it.
 */

- (void) gotoHomeScreen {
    BOOL homeViewPresent = NO;
    int index = 0;
    for (int i = 0; i < [self.navigationController.viewControllers count]; i++) {
        if ([[self.navigationController.viewControllers objectAtIndex:i] isKindOfClass:[HomeScreenViewController class]]) {
            homeViewPresent = YES;
            index = i;
        }
    }
    HomeScreenViewController *homeScreenViewController;
    if (!homeViewPresent) {
        homeScreenViewController = [[HomeScreenViewController alloc] initWithNibName:@"HomeScreenViewController" bundle:nil];
        [self.navigationController pushViewController:homeScreenViewController animated:NO];
    } else {
        homeScreenViewController = (HomeScreenViewController *) [self.navigationController.viewControllers objectAtIndex:index];
        [self.navigationController popToViewController:homeScreenViewController animated:NO];
    }
    //[homeScreenViewController startNewInspectionButtonTouched:self];
}

- (void) finishForInspectionStatusTouched {
    
   /* [self getDefects];
    if(self.hasDefects)
    {*/
    NSString *finish = @"Finish Inspection?";
    NSString *preventString = @"Finishing the inspection will prevent further modifications.";
    NSString *cannotString = @"Cannot finish inspection with no audits completed.";
    if ([[User sharedUser] checkForRetailInsights]) {
        finish = @"Finish Audit?";
        preventString = @"Finishing the audit will prevent further modifications.";
        cannotString = @"Cannot finish audits.";
    }
    if ([self.productAudits count] > 0) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:finish message:preventString
                              delegate:self
                              cancelButtonTitle:@"Cancel"
                              otherButtonTitles:@"Ok", nil];
        [alert setTag:3];
        [alert show];

    } else {
        [[[UIAlertView alloc] initWithTitle:finish message:cannotString delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
    }
   /* }else{
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Warning" message:@"Please add at least one defect for each product that is being Rejected or Accepted with Issues before continuing."
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:@"Submit Anyway", nil];
        [alert setTag:4];
        [alert show];
    }*/
}

- (void)finishButtonTapped
{
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    UIWindow *win = [[UIApplication sharedApplication] keyWindow];
    [alert showNotice:win.rootViewController title:finishingUp subTitle:@"Please wait.." closeButtonTitle:nil duration:1.0f];
    [self performSelector:@selector(performFinish) withObject:self afterDelay:1];
    //NSLog(@"First button tapped");
}
- (int) getUserEnteredChangedFromDB:(NSString *) groupId withAuditMasterId:(NSString *) auditMasterId withProductId: (NSString *) productId withProductGroupId: (NSString *) productGroupId withDatabase: (FMDatabase *) databaseLocal {
    NSString *queryAllSummary = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%@' AND %@='%@' AND %@='%@' AND %@='%@'", TBL_SAVED_SUMMARY, COL_AUDIT_MASTER_ID, auditMasterId, COL_AUDIT_GROUP_ID, groupId, COL_PRODUCT_ID, productId, COL_PRODUCT_GROUP_ID, productGroupId];
    FMResultSet *results;
    int changed;
    FMDatabase *database;
    if (!databaseLocal || ![databaseLocal goodConnection]) {
        database = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
        [database open];
    } else {
        database = databaseLocal;
    }
    results = [database executeQuery:queryAllSummary];
    while ([results next]) {
        changed = [results intForColumn:COL_NOTIFICATION_CHANGED];
    }
    if (!databaseLocal) {
        [database close];
    }
    return changed;
}
- (void) updateNotificationInDB:(BOOL) notification withGroupId:(NSString *) groupId withAuditMasterID:(NSString *)auditMasterId withProductId: (NSString *) productId withProductGroupId: (NSString *) productGroupId withDatabase: (FMDatabase *) databaseLocal withSplitGroupId: (NSString *) splitGroupId withInspectionStatus: (NSString *) inspectionStatus {

    int changed = [self getUserEnteredChangedFromDB:groupId withAuditMasterId:auditMasterId withProductId:productId withProductGroupId:productGroupId withDatabase:databaseLocal];
    if(changed == 0){
    if(![inspectionStatus  isEqual: @""]){
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

          NSArray *allInspectionStatuses = [userDefaults objectForKey:@"allInspectionStatuses"];
          NSArray *allIds = [userDefaults objectForKey:@"allIds"];
          NSArray *notifications = [userDefaults objectForKey:@"notifications"];
          NSArray *allDefaultStatuses = [userDefaults objectForKey:@"allDefaultStatuses"];
          NSArray *defaultIds = [userDefaults objectForKey:@"defaultIds"];
          
          
          NSString *tempStatus = inspectionStatus;
          int count = allDefaultStatuses.count;
          int index = 4;
          for(int i = 0; i < count; i = i + 1)
          {
              NSString *tempDefaultString = allDefaultStatuses[i];
              if([tempStatus isEqualToString: tempDefaultString]){
                  index = [defaultIds[i] intValue];
                  break;
              }
          }
          for(int i = 0; i < count; i = i + 1){
              int tempId = [allIds[i] intValue];
              if(index == tempId){
                  Boolean tempNotification = [notifications[i] boolValue];
                  if(tempNotification == YES){
                      notification = YES;
                  }else{
                      notification= NO;
                  }
                  break;
              }
          }
      
    NSString *queryAllSummary = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%@ AND %@=%@ AND %@=%@", TBL_SAVED_SUMMARY, COL_AUDIT_MASTER_ID, auditMasterId, COL_AUDIT_GROUP_ID, groupId,COL_SPLIT_GROUP_ID,splitGroupId];
    FMResultSet *results;
    NSString *queryForUpdate = @"";
    FMDatabase *database;
    if (!databaseLocal || ![databaseLocal goodConnection]) {
        database = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
        [database open];
    } else {
        database = databaseLocal;
    }
    results = [database executeQuery:queryAllSummary];
    while ([results next]) {
        [userDefaults setBool:notification forKey:@"notification"];
        NSError *err = nil;
        NSString *summary = [results stringForColumn:COL_SUMMARY];
        AuditApiSummary *summaryJson = [[AuditApiSummary alloc] initWithString:summary error:&err];
        summaryJson.sendNotification = notification;
        NSString *updatedSummary = [summaryJson toJSONString];
        queryForUpdate = [NSString stringWithFormat:@"UPDATE %@ SET %@='%@', %@='%@' WHERE %@=%@ AND %@=%@ AND %@=%@ AND %@=%@", TBL_SAVED_SUMMARY, COL_SUMMARY, updatedSummary, COL_USERENTERED_NOTIFICATION, [NSString stringWithFormat:@"%d", notification], COL_AUDIT_MASTER_ID, auditMasterId, COL_PRODUCT_ID, productId, COL_PRODUCT_GROUP_ID, productGroupId,COL_SPLIT_GROUP_ID,splitGroupId];
        [database executeUpdate:queryForUpdate];
    }
    if (!databaseLocal) {
        [database close];
    }
    }
    }
}

/*!
 *  Tableview setup for rows and subrows.
 */
#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.distinctSupplierNames count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *supplierName = [self.distinctSupplierNames objectAtIndex:section];
    int i = 0;
    for (SavedAudit *saved in self.productAudits) {
        if ([saved.supplierName isEqualToString:supplierName]) {
            i++;
        }
    }
    return i;
}

- (NSInteger)tableView:(SKSTableView *)tableView numberOfSubRowsAtIndexPath:(NSIndexPath *)indexPath
{
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    sectionHeaderView.backgroundColor = [UIColor lightGrayColor];
    
    NSDictionary *dict;
    NSArray *keys;
    NSString *sectionName = @"";
    keys = [dict allKeys];
    if ([keys count] > 0) {
        sectionName = [keys objectAtIndex:0];
    }
    NSString *sup = [self.distinctSupplierNames objectAtIndex:section];

    NSString* tag = @"Supplier";
    NSString* customerName = [User sharedUser].userSelectedCustomerName;
    
    if((!sup || [sup isEqualToString:@""])){ //if supplier name is blank
            if(customerName && ![customerName isEqualToString:@""])
        tag = @"Customer Name";
        sup = customerName;
    }
    
    UILabel *supplier = [[UILabel alloc] initWithFrame:CGRectMake(10, 4, self.view.frame.size.width/2, 16)];
    supplier.text = tag;
    supplier.textColor = [UIColor blackColor];
    supplier.backgroundColor = [UIColor clearColor];
    supplier.font = [UIFont fontWithName:@"Helvetica-Bold" size:16.0];
    [sectionHeaderView addSubview:supplier];
    
    UILabel *poNumber = [[UILabel alloc] initWithFrame:CGRectMake(10, 24, self.view.frame.size.width/2, 16)];
    NSString *po = [Inspection sharedInspection].poNumberGlobal;
    if((![po  isEqual: @""]) && (po != nil)){
        poNumber.text = @"PONumber";
    }else{
        poNumber.text = @"GRN";
    }
    
    poNumber.textColor = [UIColor blackColor];
    poNumber.backgroundColor = [UIColor clearColor];
    poNumber.font = [UIFont fontWithName:@"Helvetica-Bold" size:15.0];
    [sectionHeaderView addSubview:poNumber];
    
    UILabel *supplierName = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 70, 4, self.view.frame.size.width/2 + 50, 16)];
    supplierName.text = sup;
    supplierName.textColor = [UIColor blackColor];
    supplierName.backgroundColor = [UIColor clearColor];
    supplierName.textAlignment = NSTextAlignmentRight;
    supplierName.font = [UIFont fontWithName:@"Helvetica" size:14.0];
    [sectionHeaderView addSubview:supplierName];
    
    UILabel *poNumberText = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 20, 24, self.view.frame.size.width/2, 16)];
    if ([[Inspection sharedInspection] isOtherSelected]) {
        poNumberText.text = @"";
    } else {
        NSString *po = [Inspection sharedInspection].poNumberGlobal;
        if((![po  isEqual: @""]) && (po != nil)){
            poNumberText.text = [[Inspection sharedInspection] poNumberGlobal];
        }else{
            poNumberText.text = [[Inspection sharedInspection] grnGlobal];
        }
        
    }
    poNumberText.textColor = [UIColor blackColor];
    poNumberText.backgroundColor = [UIColor clearColor];
    poNumberText.textAlignment = NSTextAlignmentRight;
    poNumberText.font = [UIFont fontWithName:@"Helvetica" size:14.0];
    [sectionHeaderView addSubview:poNumberText];
    
    return sectionHeaderView;

}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([[Inspection sharedInspection] isOtherSelected]) {
        return 0;
    } else {
        return 44.0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SKSTableViewCell";
    
    SKSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell = [[SKSTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];

    //NSLog(@"InspectionStatusViewController.m  = row/section section %d row %d",indexPath.section,indexPath.row);
    NSString *supplierName = [self.distinctSupplierNames objectAtIndex:indexPath.section];
    NSMutableArray *localProductAudits = [[NSMutableArray alloc] init];
    for (SavedAudit *saved in self.productAudits) {
        if ([saved.supplierName isEqualToString:supplierName]) {
            [localProductAudits addObject:saved];
        }
    }
    SavedAudit *savedAudit = [localProductAudits objectAtIndex:indexPath.row];
    
    int countOfCasesLocal = savedAudit.countOfCases;
    self.productNameLabel = [[UILabel alloc ]initWithFrame:CGRectMake(30.0, 0.0, 300.0, 43.0)];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.productNameLabel = [[UILabel alloc ]initWithFrame:CGRectMake(30.0, 0.0, 400.0, 43.0)];
    }else if((IS_IPHONE5) || IS_IPHONE4){
        self.productNameLabel = [[UILabel alloc ]initWithFrame:CGRectMake(30.0, 0.0, 200.0, 43.0)];
    }
    if(savedAudit.isFlagged == YES)
    {
        productNameLabel.textColor = [UIColor redColor];
    }
    else{
        productNameLabel.textColor = [UIColor blackColor];
    }
    productNameLabel.font = [UIFont fontWithName:@"Helvetica" size:(14.0)];
    productNameLabel.text = savedAudit.productName;
    [cell addSubview:productNameLabel];
    
    self.countOfCasesLabel = [[UILabel alloc ]initWithFrame:CGRectMake(0.0, 20.0, 60.0, 43.0)];
    if(savedAudit.isFlagged == YES)
    {
        countOfCasesLabel.textColor = [UIColor redColor];
    }
    else{
        countOfCasesLabel.textColor = [UIColor blackColor];
    }
    
    countOfCasesLabel.textAlignment =  NSTextAlignmentRight;
    countOfCasesLabel.font = [UIFont fontWithName:@"Helvetica" size:(12.0)];
    [cell addSubview:countOfCasesLabel];
    
    //DI-978 - show warning message if the audit counts are less than specified in portal
  /*  NSString *message =[savedAudit getWarningMessage];
    //NSLog(@"Message is: %@",message);
    UIImageView *warningIcon = [[UIImageView alloc] initWithFrame:CGRectMake(80, 30.0, 20, 20)];
    UILabel *warningMessage = [[UILabel alloc ]initWithFrame:CGRectMake(100.0, 30.0, 300.0, 20.0)];
    warningMessage.font = [UIFont fontWithName:@"Helvetica" size:(12.0)];
    warningMessage.text = message;

    if([message containsString:@"required"]) {
        warningMessage.textColor = [UIColor redColor];
        [warningIcon setImage:[UIImage imageNamed:@"delete_icon.png"]];
        [cell addSubview:warningIcon];
        [cell addSubview:warningMessage];
    } else if([message containsString:@"recommended"]) {
        warningMessage.textColor = [UIColor orangeColor];
        [warningIcon setImage:[UIImage imageNamed:@"ic_warning_yellow.png"]];
        [cell addSubview:warningIcon];
        [cell addSubview:warningMessage];
    }
    */
    //DI-2609 - Tiered inspection minimums
    if(savedAudit.userEnteredAuditsCount > 0){
    NSString* productGroupIdString = [NSString stringWithFormat:@"%d",savedAudit.productGroupId];
    InspectionMinimums *minimum = [self.inspectionMinimums objectForKey:productGroupIdString];
    IMResult* inspectionMinimumsResult = [savedAudit getResultForInspectionMinimum:minimum];
    if(inspectionMinimumsResult && !inspectionMinimumsResult.isPass){
    UIImageView *warningIcon = [[UIImageView alloc] initWithFrame:CGRectMake(80, 30.0, 20, 20)];
    UILabel *warningMessage = [[UILabel alloc ]initWithFrame:CGRectMake(100.0, 30.0, 300.0, 20.0)];
    warningMessage.font = [UIFont fontWithName:@"Helvetica" size:(12.0)];
    warningMessage.text = inspectionMinimumsResult.message;
        if(inspectionMinimumsResult.requiredOrRecommended == REQUIRED) {
            warningMessage.textColor = [UIColor redColor];
            [warningIcon setImage:[UIImage imageNamed:@"delete_icon.png"]];
            [cell addSubview:warningIcon];
            [cell addSubview:warningMessage];
        } else if(inspectionMinimumsResult.requiredOrRecommended == RECOMMENDED) {
            warningMessage.textColor = [UIColor orangeColor];
            [warningIcon setImage:[UIImage imageNamed:@"ic_warning_yellow.png"]];
            [cell addSubview:warningIcon];
            [cell addSubview:warningMessage];
        }
    }
    }
    
    if (!self.imgView)
        self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 10, 20, 25)];
    
    if (!self.btnToModify)
        self.btnToModify = [[RowSectionButton alloc] initWithFrame:CGRectMake(20, 0, widthForModifyButtonTouch, 60)];
    self.btnToModify.row = indexPath.row; // savedAudit.productId;
    self.btnToModify.section = indexPath.section;
    [self.btnToModify addTarget:self action:@selector(btnToModifyPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    int auditsCountGlobal = 0;
    if (savedAudit.userEnteredAuditsCount > 0 && aggregateSamplesMode) {
        auditsCountGlobal = savedAudit.userEnteredAuditsCount;
    } else {
        auditsCountGlobal = savedAudit.auditsCount;
    }
    
    //if fake audit - means product with no inspections yet
    BOOL isFakeAudit = NO;
    if(auditsCountGlobal==0)
        isFakeAudit = YES;
    
    //for distinct samples it will always be the audits count
    //if(!distinctSamples)
       // auditsCountGlobal = savedAudit.auditsCount;
    
    if (countOfCasesLocal > 0) {
        countOfCasesLabel.text = [NSString stringWithFormat:@"%d/%d", auditsCountGlobal, countOfCasesLocal];
    } else {
        countOfCasesLabel.text = [NSString stringWithFormat:@"%d", auditsCountGlobal];
    }
    if((![savedAudit.previousInspectionStatus  isEqual: @""])){
        if(([[savedAudit.inspectionStatus lowercaseString] isEqualToString:@"accept"]) || ([[savedAudit.inspectionStatus lowercaseString] isEqualToString:@"reject"]) || ([[savedAudit.inspectionStatus lowercaseString] isEqualToString:@"accept with issues"])){
            
            
            if ([[savedAudit.inspectionStatus lowercaseString] isEqualToString:@"accept"]) {
                countOfCasesLabel.textColor = [UIColor colorWithRed:0 green:0.4 blue:0.2 alpha:1]; /*#006633*/ //[UIColor greenColor];
                [imgView setImage:[UIImage imageNamed:@"ic_accept_green.png"]];
            } else if ([[savedAudit.inspectionStatus lowercaseString] isEqualToString:@"reject"]) {
                countOfCasesLabel.textColor = [UIColor redColor];
                [imgView setImage:[UIImage imageNamed:@"ic_remove_red.png"]];
            } else if ([[savedAudit.inspectionStatus lowercaseString] isEqualToString:@"accept with issues"]) {
                countOfCasesLabel.textColor = [UIColor orangeColor];
                [imgView setImage:[UIImage imageNamed:@"ic_warning_yellow.png"]];
            } else {
                countOfCasesLabel.textColor = [UIColor blueColor];; //[UIColor colorWithRed:0 green:0.4 blue:0.2 alpha:1];; //[UIColor greenColor];
                [imgView setImage:[UIImage imageNamed:@"ic_accept_green.png"]];
            }
        }
        else{
        if ([[savedAudit.previousInspectionStatus lowercaseString] isEqualToString:@"accept"]) {
            countOfCasesLabel.textColor = [UIColor colorWithRed:0 green:0.4 blue:0.2 alpha:1]; /*#006633*/ //[UIColor greenColor];
            [imgView setImage:[UIImage imageNamed:@"ic_accept_green.png"]];
        } else if ([[savedAudit.previousInspectionStatus lowercaseString] isEqualToString:@"reject"]) {
            countOfCasesLabel.textColor = [UIColor redColor];
            [imgView setImage:[UIImage imageNamed:@"ic_remove_red.png"]];
        } else if ([[savedAudit.previousInspectionStatus lowercaseString] isEqualToString:@"accept with issues"]) {
            countOfCasesLabel.textColor = [UIColor orangeColor];
            [imgView setImage:[UIImage imageNamed:@"ic_warning_yellow.png"]];
        } else {
            countOfCasesLabel.textColor = [UIColor blueColor];; //[UIColor colorWithRed:0 green:0.4 blue:0.2 alpha:1];; //[UIColor greenColor];
            [imgView setImage:[UIImage imageNamed:@"ic_accept_green.png"]];
        }
        }
    }else{
    if ([[savedAudit.inspectionStatus lowercaseString] isEqualToString:@"accept"]) {
        countOfCasesLabel.textColor = [UIColor colorWithRed:0 green:0.4 blue:0.2 alpha:1]; /*#006633*/ //[UIColor greenColor];
        [imgView setImage:[UIImage imageNamed:@"ic_accept_green.png"]];
    } else if ([[savedAudit.inspectionStatus lowercaseString] isEqualToString:@"reject"]) {
        countOfCasesLabel.textColor = [UIColor redColor];
        [imgView setImage:[UIImage imageNamed:@"ic_remove_red.png"]];
    } else if ([[savedAudit.inspectionStatus lowercaseString] isEqualToString:@"accept with issues"]) {
        countOfCasesLabel.textColor = [UIColor orangeColor];
        [imgView setImage:[UIImage imageNamed:@"ic_warning_yellow.png"]];
    } else {
        countOfCasesLabel.textColor = [UIColor blueColor];; //[UIColor colorWithRed:0 green:0.4 blue:0.2 alpha:1];; //[UIColor greenColor];
        [imgView setImage:[UIImage imageNamed:@"ic_accept_green.png"]];
    }
    }
    if(savedAudit.isFlagged == YES)
    {
       // [imgView setImage:[UIImage imageNamed:@"redflag.png"]];
        self.flaggedProductButton = [[RowSectionButton alloc] initWithFrame:CGRectMake(cell.bounds.size.width, 10, 20, 25)];
        [self.flaggedProductButton setBackgroundImage:[UIImage imageNamed:@"redflag.png"] forState:normal];
        self.flaggedProductButton.row = indexPath.row;
        self.productName = savedAudit.productName;
        self.allFlaggedProductMessages = savedAudit.allFlaggedProductMessages;
        [self.flaggedProductButton addTarget:self action:@selector(showFlaggedProductMessage:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:self.flaggedProductButton];
    }
    UIImageView *imageView;
    if (imageView == nil) {
        imageView = imgView;
        self.imgView = nil;
    }
   
    UIButton *buttonForModify;
    if (buttonForModify == nil) {
        buttonForModify = btnToModify;
        self.btnToModify = nil;
    }
    [cell addSubview:buttonForModify];
    cell.tag = indexPath.row;
    
    //for fake entries change color and disable expanding the summary
    if(isFakeAudit){
        productNameLabel.textColor = [UIColor grayColor];
        countOfCasesLabel.textColor = [UIColor grayColor];
        cell.expandable = NO;
        [imgView setImage:nil];
    }else{
         [cell addSubview:imageView];
         cell.expandable = YES;
    }
    /*
    if(savedAudit.globalInspectionStatus.allInspectionStatuses.count != 0)
    {
        if(savedAudit.globalInspectionStatus.defaultIds.count != 0)
        {
        self.globalInspectionStatus = savedAudit.globalInspectionStatus;
            self.statusValues = self.globalInspectionStatus.allInspectionStatuses;
        NSString *tempStatus = savedAudit.inspectionStatus;
        int count = self.globalInspectionStatus.allDefaultStatuses.count;
        int index;
        for(int i = 0; i < count; i = i + 1)
        {
            NSString *tempDefaultString = self.globalInspectionStatus.allDefaultStatuses[i];
            if([tempStatus isEqualToString: tempDefaultString]){
                index = [self.globalInspectionStatus.defaultIds[i] intValue];
                break;
            }
        }
        for(int i = 0; i < count; i = i + 1){
            int tempId = [self.globalInspectionStatus.allIds[i] intValue];
            if(index == tempId){
                Boolean tempNotification = [self.globalInspectionStatus.notifications[i] boolValue];
                if(tempNotification == YES){
                    self.globalNotification = YES;
                }else{
                    self.globalNotification = NO;
                }
                break;
            }
        }
            
        }
        else{
            
            tableView.reloadData;
        }
    }else{
        
        //tableView.reloadData;
    }
   */
   // dispatch_queue_t backgroundQueue = dispatch_queue_create("com.mycompany.myqueue", 0);
    //dispatch_async(backgroundQueue, ^{
        FMDatabase *database;
        database = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
        [database open];

        [self updateNotificationInDB:false withGroupId:[NSString stringWithFormat:@"%d", savedAudit.productGroupId] withAuditMasterID:[[Inspection sharedInspection] auditMasterId] withProductId:[NSString stringWithFormat:@"%d", savedAudit.productId] withProductGroupId:[NSString stringWithFormat:@"%d", savedAudit.productGroupId] withDatabase:database withSplitGroupId:savedAudit.splitGroupId withInspectionStatus: savedAudit.inspectionStatus] ;
        
        [database close];
  //  });
    return cell;
}

- (void) showFlaggedProductMessage:(RowSectionButton*)sender {
    
    //NSString *flaggedProductMessageToShow = productListItem.orderData.Message;
    
    //DI-2933 - use the messages array to render text/html message
    SavedAudit *savedAudit = self.productAudits[sender.row];
    NSMutableArray *flaggedMessageArray = savedAudit.allFlaggedProductMessages;
    NSString* flaggedProductName = savedAudit.productName;
    
    //if only 1 message then show the alertview
    //    if([flaggedMessageArray count]==1){
    //        UIAlertView* dialog = [[UIAlertView alloc] initWithTitle:flaggedProductName message:flaggedProductMessageToShow delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    //        [dialog show];
    //    }else {
    CGRect windowRect = self.view.window.frame;
    CGFloat windowWidth = windowRect.size.width;
    CGFloat windowHeight = windowRect.size.height;
    
    FlaggedMessage *flaggedMessagesView = [[FlaggedMessage alloc] initWithFrame:CGRectMake(10, 100, windowWidth-20, 400)];
    flaggedMessagesView.backgroundColor= [UIColor lightGrayColor];
    flaggedMessagesView.flaggedMessages = flaggedMessageArray;
    [flaggedMessagesView parseRawMessages];
    //int height = [flaggedMessagesView getHeightForContent];
    //[flaggedMessagesView setFrame:CGRectMake(20,100, windowWidth-10, height)];
    flaggedMessagesView.label.text = flaggedProductName;
    [self.view addSubview:flaggedMessagesView];
    //  }
}
- (void) btnToModifyPressed: (RowSectionButton *) sender {
    RowSectionButton* myButton = (RowSectionButton*)sender;
    [self modifyInspectionWithTag:myButton.row withSection:myButton.section withAuditCount:0];
}

//TODO convert subtable to a view (instead of table view) and create method to read height
-(int)calculateHeightForSubRowAtIndexPath:(NSIndexPath*)indexPath{
    int height = 0;
    //InspectionSubTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InspectionSubTableViewCell"];
    //if(!cell)
     InspectionSubTableViewCell *cell = [[InspectionSubTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"InspectionSubTableViewCell"];
    Summary *summaryLocal = [self.summaryDictionary objectForKey:[NSString stringWithFormat:@"%d", indexPath.row]];
    cell.summary = summaryLocal;
    [cell calculateHeightForTheInspectionDefectCell2];
    height = [cell getTotalHeightForTableView];
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForSubRowAtIndexPath:(NSIndexPath *)indexPath
{
    InspectionSubTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InspectionSubTableViewCell"];
    if(!cell)
        cell = [[InspectionSubTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"InspectionSubTableViewCell"];
    NSString *supplierName = [self.distinctSupplierNames objectAtIndex:indexPath.section];
    NSMutableArray *localProductAudits = [[NSMutableArray alloc] init];
    for (SavedAudit *saved in self.productAudits) {
        if ([saved.supplierName isEqualToString:supplierName]) {
            [localProductAudits addObject:saved];
        }
    }
    SavedAudit *savedAudit = [localProductAudits objectAtIndex:indexPath.row];
    cell.delegate = self;
    cell.savedAudit = savedAudit;
    cell.parentTableView = self.table;
    /*NSArray *keys = [self.summaryDictionary allKeys];
    for (NSString *key in keys) {
        Summary *summaryLocal = [self.summaryDictionary objectForKey:key];
        if (summaryLocal.groupId == savedAudit.productGroupId) {
            if (summaryLocal.productId == savedAudit.productId && summaryLocal.productId == savedAudit.productId) {
                cell.summary = summaryLocal;
            }
        }
    }*/
    //NSLog(@"row = %d, subrow = %d, section = %d", [indexPath row], [indexPath subRow], [indexPath section]);
    //no need of above since the key is the row
    Summary *summaryLocal = [self.summaryDictionary objectForKey:[NSString stringWithFormat:@"%d", indexPath.row]];
    cell.summary = summaryLocal;
    
    cell.globalProduct = self.globalProduct;
    cell.modifyInspectionButton.row = indexPath.row; // savedAudit.productId;
    cell.modifyInspectionButton.section = indexPath.section;
    cell.changeStatusButton.row = savedAudit.productId;
    cell.changeStatusButton.section = indexPath.section;
    cell.closeButton.row = indexPath.row;
    cell.closeButton.section = indexPath.section;
    [cell.modifyInspectionButton addTarget:self action:@selector(modifyInspectionButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [cell.changeStatusButton addTarget:self action:@selector(changeStatusButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [cell.closeButton addTarget:self action:@selector(showSummaryDetails:) forControlEvents:UIControlEventTouchUpInside];
    
    return  cell;
}

-(void) showSummaryDetails: (RowSectionButton *) sender{
     RowSectionButton* myButton = (RowSectionButton*)sender;
    int row = myButton.row;
    int section = myButton.section;
    NSString *supplierName = [self.distinctSupplierNames objectAtIndex:section];
    NSMutableArray *localProductAudits = [[NSMutableArray alloc] init];
    for (SavedAudit *saved in self.productAudits) {
        //NSLog(@"Saved Audits are: %@",[saved toJSONString]);
        if ([saved.supplierName isEqualToString:supplierName]) {
            [localProductAudits addObject:saved];
        }
    }
    
    SummaryDetailsTableViewCell *cell = [[SummaryDetailsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"InspectionSubTableViewCell"];
  
    SavedAudit *savedAudit = [localProductAudits objectAtIndex:row];
    
    cell.delegate = self;
    cell.savedAudit = savedAudit;
    cell.parentTableView = self.table;
//    NSArray *keys = [self.summaryDictionary allKeys];
//    for (NSString *key in keys) {
//        Summary *summaryLocal = [self.summaryDictionary objectForKey:key];
//        if (summaryLocal.groupId == savedAudit.productGroupId) {
//            if (summaryLocal.productId == savedAudit.productId) {
//                cell.productId = summaryLocal.productId;
//                cell.summary = summaryLocal;
//            }
//        }
//    }
    //fix DI-1811
    //the summary does not have splitGroupId
    NSString* rowString = [NSString stringWithFormat:@"%d",row];
    Summary *summaryLocal =[self.summaryDictionary objectForKey:rowString];
    cell.summary =summaryLocal;
    cell.productId = summaryLocal.productId;
    
    cell.globalProduct = self.globalProduct;
    cell.summaryScreenRow = row;
    cell.summaryScreenSection = section;
    [cell initSamplesStructure];
    [self.view addSubview:cell];
    //add with transition
    /*[UIView transitionWithView:self.window
     duration:1.0
     options:UIViewAnimationOptionTransitionFlipFromLeft //any animation
     animations:^ { [self.window addSubview:cell]; }
     completion:nil];*/
}

- (CGFloat)tableView:(SKSTableView *)tableView heightForSubRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Returns 60.0 points for all subrows.
//    if (IS_IPHONE5) {
//        return 372.0f;
//    } else if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ){
//        return 550.0f;
//    } else {
//        return 322.0;
//    }
    //return calculated height in order to avoid scrolling within the subview
    return [self calculateHeightForSubRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(SKSTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Returns 60.0 points for all subrows.
    if (IS_IPHONE5) {
        return 50.0f;
    } else {
        return 50.0;
    }
}

//called when clicked on any row and it expands
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:1 forKey:@"didSelect"];

    self.selected = NO;
    [userDefaults synchronize];
    SKSTableViewCell *cell = (SKSTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [Inspection sharedInspection].currentSplitGroupId = @""; //reset split groupId
    
    //fix crash DI-2109
    if (![cell respondsToSelector:@selector(isExpanded)])
        return;
    
    if (cell.expanded) {
        //[self.table collapseCurrentlyExpandedIndexPaths];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        UIWindow *win = [[UIApplication sharedApplication] keyWindow];
        SyncOverlayView *sync = [[SyncOverlayView alloc] initWithFrame:CGRectMake(0, 0, win.frame.size.width, win.frame.size.height)];
        sync.headingTitleLabel.text = @"Generating Summary";
        [sync showActivityView];
        [win addSubview:sync];
        __block FMDatabase *databaseGroupRatings;
        databaseGroupRatings = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
        [databaseGroupRatings open];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //SKSTableViewCell *cell = (SKSTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
            NSString *supplierName = [self.distinctSupplierNames objectAtIndex:indexPath.section];
            NSMutableArray *localProductAudits = [[NSMutableArray alloc] init];
            for (SavedAudit *saved in self.productAudits) {
                if ([saved.supplierName isEqualToString:supplierName]) {
                    [localProductAudits addObject:saved];
                }
            }
            SavedAudit *product = [localProductAudits objectAtIndex:indexPath.row];
            [Inspection sharedInspection].currentSplitGroupId = product.splitGroupId; //set split groupId
            int gID = product.productGroupId;
            int productId = product.productId;
            Summary *summary = [[Summary alloc] init];
            summary.productName = product.productName;
            summary.productId = productId;
            summary.groupId = gID;
            summary.totalCountOfCases = product.countOfCases;
            //if (product.userEnteredAuditsCount > 0 && !aggregateSamplesMode) {
                /*summary.numberOfInspections = product.userEnteredAuditsCount;
                [summary updateNumberOfInspectionsInDB:summary.numberOfInspections withGroupId:[NSString stringWithFormat:@"%d", product.productGroupId] withAuditMasterID:[[Inspection sharedInspection] auditMasterId] withProductId:[NSString stringWithFormat:@"%d", product.productId] withDatabase:databaseGroupRatings];*/
            //}
           // [NSThread sleepForTimeInterval:5.0f];
            self.globalProduct = [self getProduct:gID withProductID:productId];
            
           SavedAudit *savedAudit = [[self productAudits] objectAtIndex:indexPath.row];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

            NSArray *allInspectionStatuses = [userDefaults objectForKey:@"allInspectionStatuses"];
            NSArray *allIds = [userDefaults objectForKey:@"allIds"];
            NSArray *notifications = [userDefaults objectForKey:@"notifications"];
            NSArray *allDefaultStatuses = [userDefaults objectForKey:@"allDefaultStatuses"];
            NSArray *defaultIds = [userDefaults objectForKey:@"defaultIds"];
            self.globalInspectionStatus = savedAudit.globalInspectionStatus;
            self.statusValues = allInspectionStatuses;
            int i = 0;
            int count = allIds.count;
            while(i < count){
                int ID = [allIds[i] intValue];
                if(ID == 4){
                    self.nonScoreableIndex = i;
                    break;
                }
                i += 1;
            }
             i = 0;
            while(i < count){
                int ID = [allIds[i] intValue];
                if(ID != 4){
                    self.scoreableIndex = i;
                    break;
                }
                i += 1;
            }
         /*   if(self.statusValues.count == 0){
                [self.table reloadData];
            }*/
            
            //get old summary
            self.globalAuditMasterId = [Inspection sharedInspection].auditMasterId;
            AuditApiSummary* summaryFromDB = [summary getSummaryFromDBForGroupId:[NSString stringWithFormat:@"%d", product.productGroupId] withAuditMasterID:[[Inspection sharedInspection] auditMasterId] withProductId:[NSString stringWithFormat:@"%d", product.productId] withSplitGroupId:product.splitGroupId];
            if(summaryFromDB.failedDateValidation)
                summary.failedDateValidation = YES;
            
            //TODO check if recalculate necessary
            [summary getSummaryOfAudits:self.globalProduct withGroupId:[NSString stringWithFormat:@"%d", product.productGroupId] withSplitGroupId:[Inspection sharedInspection].currentSplitGroupId withDatabase:databaseGroupRatings];
            
           
            
            [self.summaryDictionary setObject:summary forKey:[NSString stringWithFormat:@"%d", indexPath.row]];
            self.summaryGlobal = summary;
            [self.summaryDictionaryForChangeStatus setObject:self.summaryGlobal forKey:[NSNumber numberWithInt:indexPath.row]];
            self.currentGroupId = gID;
            self.currentProductId = productId;
          /*  dispatch_queue_t backgroundQueue = dispatch_queue_create("com.mycompany.myqueue", 0);
            dispatch_async(backgroundQueue, ^{
                FMDatabase *database;
                database = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
                [database open];
                    [self.summaryGlobal updateNotificationInDB:self.summaryGlobal.sendNotification withGroupId:[NSString stringWithFormat:@"%d", self.globalProduct.group_id] withAuditMasterID:[[Inspection sharedInspection] auditMasterId] withProductId:[NSString stringWithFormat:@"%d", self.currentProductId] withProductGroupId:[NSString stringWithFormat:@"%d", self.globalProduct.group_id] withDatabase:database withSplitGroupId: savedAudit.splitGroupId];
                
                [database close];
            });*/
            [databaseGroupRatings close];
            [sync dismissActivityView];
            [sync removeFromSuperview];
            [self.table reloadData];
        });
    }
}

- (void) getDefects
{
    UIWindow *win = [[UIApplication sharedApplication] keyWindow];
    SyncOverlayView *sync = [[SyncOverlayView alloc] initWithFrame:CGRectMake(0, 0, win.frame.size.width, win.frame.size.height)];
    sync.headingTitleLabel.text = @"Generating Summary";
    [sync showActivityView];
    [win addSubview:sync];
    __block FMDatabase *databaseGroupRatings;
    databaseGroupRatings = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
    [databaseGroupRatings open];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        for (NSString *supplierName in self.distinctSupplierNames)
        {
            NSMutableArray *localProductAudits = [[NSMutableArray alloc] init];
            for (SavedAudit *saved in self.productAudits) {
                if ([saved.supplierName isEqualToString:supplierName]) {
                    [localProductAudits addObject:saved];
                }
            }
            for (SavedAudit *product in localProductAudits)
            {
                [Inspection sharedInspection].currentSplitGroupId = product.splitGroupId; //set split groupId
                int gID = product.productGroupId;
                int productId = product.productId;
                Summary *summary = [[Summary alloc] init];
                summary.productName = product.productName;
                summary.productId = productId;
                summary.groupId = gID;
                summary.totalCountOfCases = product.countOfCases;
  
                self.globalProduct = [self getProduct:gID withProductID:productId];
                
                //get old summary
                self.globalAuditMasterId = [Inspection sharedInspection].auditMasterId;
                AuditApiSummary* summaryFromDB = [summary getSummaryFromDBForGroupId:[NSString stringWithFormat:@"%d", product.productGroupId] withAuditMasterID:[[Inspection sharedInspection] auditMasterId] withProductId:[NSString stringWithFormat:@"%d", product.productId] withSplitGroupId:product.splitGroupId];
                if(summaryFromDB.failedDateValidation)
                    summary.failedDateValidation = YES;
                
                //TODO check if recalculate necessary
                [summary getSummaryOfAudits:self.globalProduct withGroupId:[NSString stringWithFormat:@"%d", product.productGroupId] withSplitGroupId:[Inspection sharedInspection].currentSplitGroupId withDatabase:databaseGroupRatings];
                
                if(![summary.inspectionStatus  isEqual: @"Accept"])
                {
                    if(summary.allTotalsList.count == 0)
                    {
                        [databaseGroupRatings close];
                        [sync dismissActivityView];
                        [sync removeFromSuperview];
                        self.hasDefects = NO;
                    }
                }
                
            }
        }
        [databaseGroupRatings close];
        [sync dismissActivityView];
        [sync removeFromSuperview];
        self.hasDefects = YES;
    });
    
}
- (void)tableView:(SKSTableView *)tableView didSelectSubRowAtIndexPath:(NSIndexPath *)indexPath {
}

/*!
 *  Get product object with the groupId and productId
 *
 *  @param groupId   GroupId
 *  @param productId ProductId
 *
 *  @return returns a product object
 */
- (Product *) getProduct:(int) groupId withProductID:(int) productId {
    Store *store = [[User sharedUser] currentStore];
    
    NSArray *groups = [Inspection sharedInspection].productGroups;
    BOOL program = YES;
    for (int i=0; i < [groups count]; i++) {
        if (![[groups objectAtIndex:i] isKindOfClass:[ProgramGroup class]]) {
            program = NO;
            break;
        }
    }
    if (!program) {
        groups = [store getAllGroupsOfProductsForTheStore];
    }
    for (ProgramGroup *pg in groups) {
        if (pg.programGroupID == groupId) {
            NSArray *products = [pg getAllProducts];
            for (Product *p in products) {
                if (productId == p.product_id) {
                    [p getAllRatings];
                    NSMutableArray *ratingsForProductWithDefects = [[NSMutableArray alloc] init];
                    for (Rating *rating in p.ratings) {
                        [rating getAllDefects];
                        [ratingsForProductWithDefects addObject:rating];
                    }
                    p.ratings = [[NSArray alloc] init];
                    p.ratings = [ratingsForProductWithDefects copy];
                    return p;
                }
            }
        }
    }
    return nil;
}

-(void) startCollaborativeInspectionForProduct:(int)productId withViewController:(ViewController*)productViewController{
    
    CollobarativeInspection* collobarativeInsp = [Inspection sharedInspection].collobarativeInspection;
    if(!collobarativeInsp) {
        collobarativeInsp = [[CollobarativeInspection alloc]init];
        [Inspection sharedInspection].collobarativeInspection = collobarativeInsp;
    }
    /*UIWindow *win = [[UIApplication sharedApplication] keyWindow];
    self.syncOverlayView = [[SyncOverlayView alloc] initWithFrame:CGRectMake(0, 0, win.frame.size.width, win.frame.size.height)];
    self.syncOverlayView.headingTitleLabel.text = @"Starting Inspection...";
    [self.syncOverlayView showActivityView];
    [win addSubview:self.syncOverlayView];*/
    
    [collobarativeInsp startInspectionForProduct:productId inPO:[Inspection sharedInspection].poNumberGlobal withBlock:^(BOOL success) {
        [self.navigationController popToViewController:productViewController animated:YES];
        if (![UserNetworkActivityView sharedActivityView].hidden)
            [[UserNetworkActivityView sharedActivityView] hide];

       // [self.syncOverlayView dismissActivityView];
       // [self.syncOverlayView removeFromSuperview];
        
    }];
    
}


/*!
 *  Modify inspection method for the audits.
 *
 *  @param sender self
 */
- (void) modifyInspectionButtonTouched: (RowSectionButton *) sender {
    int row = [sender row];
    int section = [sender section];
    [self modifyInspectionWithTag:row withSection:section withAuditCount:0];
}

//tag is productId and section is the specified audit count to go to
- (void) modifyInspectionWithTag: (int) tag withSection:(int) section withAuditCount:(int)auditCount {
    BOOL productViewControllerPresent = NO;
    //iterate through existing viewcontrollers for ProductViewController and popToViewController
    for (int i = 0; i < [self.navigationController.viewControllers count]; i++) {
        if ([[self.navigationController.viewControllers objectAtIndex:i] isKindOfClass:[ProductViewController class]]) {
            productViewControllerPresent = YES;
            ProductViewController *productViewController = (ProductViewController *) [self.navigationController.viewControllers objectAtIndex:i];
            SavedAudit *savedAudit = [[SavedAudit alloc] init];
            [Inspection sharedInspection].currentSplitGroupId = @"";
            /*for (SavedAudit *saved in self.productAudits) {
                if (saved.productId == tag) {
                    [Inspection sharedInspection].currentSplitGroupId = saved.splitGroupId;
                    savedAudit = saved;
                }
            }*/
            
            NSString *supplierName = [self.distinctSupplierNames objectAtIndex:section];
            NSMutableArray *localProductAudits = [[NSMutableArray alloc] init];
            for (SavedAudit *saved in self.productAudits) {
                if ([saved.supplierName isEqualToString:supplierName]) {
                    [localProductAudits addObject:saved];
                }
            }
            savedAudit = [localProductAudits objectAtIndex:tag];
            if(auditCount>0)
                savedAudit.auditNumberToShow = auditCount;
            [Inspection sharedInspection].currentSplitGroupId = savedAudit.splitGroupId;

            if([[Inspection sharedInspection].currentSplitGroupId length]==0)
                [Inspection sharedInspection].currentSplitGroupId = [DeviceManager getCurrentTimeString];
                 
            productViewController.savedAudit = savedAudit;
            productViewController.parentView = defineInspectionStatusViewController;
            UserNetworkActivityView *activityView = [UserNetworkActivityView sharedActivityView];
            [activityView setCustomMessage:@"Loading View"];
            if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
                [activityView show:self withOperation:nil showCancel:NO];
            }
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                //[productViewController refreshState]; //move to main queue
                dispatch_async(dispatch_get_main_queue(), ^{
                    if([CollobarativeInspection isCollaborativeInspectionsEnabled]){
                        //[self startCollaborativeInspectionForProduct:(int)productViewController.product.product_id withViewController:productViewController];
                        CollobarativeInspection* collobarativeInsp = [Inspection sharedInspection].collobarativeInspection;
                        if(!collobarativeInsp) {
                            collobarativeInsp = [[CollobarativeInspection alloc]init];
                            [Inspection sharedInspection].collobarativeInspection = collobarativeInsp;
                        }
                        [collobarativeInsp startInspectionForProduct:(int)productViewController.product.product_id inPO:[Inspection sharedInspection].poNumberGlobal withBlock:^(BOOL success) {
                            [productViewController refreshState];
                            [self.navigationController popToViewController:productViewController animated:YES];
                            if (![UserNetworkActivityView sharedActivityView].hidden)
                                [[UserNetworkActivityView sharedActivityView] hide];
                        }];
                    }else{
                        [productViewController refreshState];
                        [self.navigationController popToViewController:productViewController animated:YES];
                        if (![UserNetworkActivityView sharedActivityView].hidden)
                            [[UserNetworkActivityView sharedActivityView] hide];
                    }
                    /*[productViewController refreshState];
                     [self.navigationController popToViewController:productViewController animated:YES];
                     if (![UserNetworkActivityView sharedActivityView].hidden)
                     [[UserNetworkActivityView sharedActivityView] hide];*/
                });
            });
        }
    }
    //if ProductViewController not present - push new
    if (!productViewControllerPresent) {
        ProductViewController *productViewController = [[ProductViewController alloc] initWithNibName:@"ProductViewController" bundle:nil];
        SavedAudit *savedAudit = [[SavedAudit alloc] init];
        [Inspection sharedInspection].currentSplitGroupId = @"";
        /*for (SavedAudit *saved in self.productAudits) {
            if (saved.productId == tag) {
                savedAudit = saved;
                [Inspection sharedInspection].currentSplitGroupId = saved.splitGroupId;
            }
        }*/
        if(auditCount>0)
            savedAudit.auditNumberToShow = section;
        NSString *supplierName = [self.distinctSupplierNames objectAtIndex:section];
        NSMutableArray *localProductAudits = [[NSMutableArray alloc] init];
        for (SavedAudit *saved in self.productAudits) {
            if ([saved.supplierName isEqualToString:supplierName]) {
                [localProductAudits addObject:saved];
            }
        }
        savedAudit = [localProductAudits objectAtIndex:tag];
        if(auditCount>0)
            savedAudit.auditNumberToShow = auditCount;
        [Inspection sharedInspection].currentSplitGroupId = savedAudit.splitGroupId;
        
        if([[Inspection sharedInspection].currentSplitGroupId length]==0)
            [Inspection sharedInspection].currentSplitGroupId = [DeviceManager getCurrentTimeString];
        
        productViewController.savedAudit = savedAudit;
        productViewController.parentView = defineInspectionStatusViewController;
        UIWindow *win = [[UIApplication sharedApplication] keyWindow];
        self.syncOverlayView = [[SyncOverlayView alloc] initWithFrame:CGRectMake(0, 0, win.frame.size.width, win.frame.size.height)];
        self.syncOverlayView.headingTitleLabel.text = @"Loading...";
        [self.syncOverlayView showActivityView];
        [win addSubview:self.syncOverlayView];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            //[productViewController refreshState]; // this will automatically be called with viewDidLoad
            dispatch_async(dispatch_get_main_queue(), ^{
                if([CollobarativeInspection isCollaborativeInspectionsEnabled]){
                    //[self startCollaborativeInspectionForProduct:(int)productViewController.product.product_id withViewController:productViewController];
                    CollobarativeInspection* collobarativeInsp = [Inspection sharedInspection].collobarativeInspection;
                    if(!collobarativeInsp) {
                        collobarativeInsp = [[CollobarativeInspection alloc]init];
                        [Inspection sharedInspection].collobarativeInspection = collobarativeInsp;
                    }
                    [collobarativeInsp startInspectionForProduct:(int)productViewController.product.product_id inPO:[Inspection sharedInspection].poNumberGlobal withBlock:^(BOOL success) {
                        [self.navigationController pushViewController:productViewController animated:YES];
                        [self.syncOverlayView dismissActivityView];
                        [self.syncOverlayView removeFromSuperview];
                    }];
                }else{
                    [self.navigationController pushViewController:productViewController animated:YES];
                    [self.syncOverlayView dismissActivityView];
                    [self.syncOverlayView removeFromSuperview];
                }
            });
        });
    }
}

- (void) changeStatusButtonTouched: (RowSectionButton *) sender {
    [self containerOptionButtonSelected:sender];
}

- (IBAction)startSearch:(id)sender {
    [self.searchField resignFirstResponder];
    if (![[NSString stringWithFormat:@"%@", self.searchField.text] isEqualToString:@""] && self.searchField.text) {
        [self searchAndRefreshTableViewWithString:self.searchField.text];
    } else {
        self.productAudits = [[NSMutableArray alloc] init];
        [self.productAudits arrayByAddingObjectsFromArray:self.productAuditsCacheForAutoComplete];
    }
    //self.productGroupsDidSelectGlobalArray = [[NSArray alloc] init];
    //self.productGroupsDidSelectGlobalArray = self.productGroups;
    [self tableViewSetup];
}

- (void) searchAndRefreshTableViewWithString: (NSString *) string {
    self.productAudits = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.productAuditsCacheForAutoComplete count]; i++) {
        if ([[self.productAuditsCacheForAutoComplete objectAtIndex:i] isKindOfClass:[SavedAudit class]]) {
            SavedAudit *savedAudit = [self.productAuditsCacheForAutoComplete objectAtIndex:i];
            NSRange substringRange = [[savedAudit.productName lowercaseString] rangeOfString:[string lowercaseString]];
            if (substringRange.length != 0) {
                [self.productAudits addObject:savedAudit];
            }
        }
    }
}

- (IBAction)containerOptionButtonSelected:(RowSectionButton *)sender {
    CGFloat xWidth = self.view.frame.size.width - 20.0f;
    CGFloat yHeight = popupDefaultHeight;
    if ([self.statusValues count] < 5) {
        int heightAfterCalculation = [self.statusValues count] * 60.0f;
        heightAfterCalculation = heightAfterCalculation + 40;
        yHeight = heightAfterCalculation;
    }
    CGFloat yOffset = (self.view.frame.size.height - yHeight)/2.0f;
    RowSectionPopOverListView *poplistview = [[RowSectionPopOverListView alloc] initWithFrame:CGRectMake(10, yOffset, xWidth, yHeight)];
    poplistview.delegate = self;
    poplistview.datasource = self;
    poplistview.row = sender.row;
    poplistview.section = sender.section;
    poplistview.listView.scrollEnabled = TRUE;
    [poplistview setTitle:@"  Select Status"];
    [poplistview show];
}

- (IBAction)productSelectButtonTouched:(id)sender {
    [self goToProductListScreen];
}

-(void)goToProductListScreen {
    BOOL productSelectPresent = NO;
    for (int i = 0; i < [self.navigationController.viewControllers count]; i++) {
        if ([[self.navigationController.viewControllers objectAtIndex:i] isKindOfClass:[ProductSelectAutoCompleteViewController class]]) {
            productSelectPresent = YES;
            ProductSelectAutoCompleteViewController *productSelectAutoCompleteViewController = (ProductSelectAutoCompleteViewController *) [self.navigationController.viewControllers objectAtIndex:i];
            [self.navigationController popToViewController:productSelectAutoCompleteViewController animated:YES];
        }
    }
    if (!productSelectPresent) {
        ProductSelectAutoCompleteViewController *productSelectAutoCompleteViewController = [[ProductSelectAutoCompleteViewController alloc] initWithNibName:@"ProductSelectAutoCompleteViewController" bundle:nil];
        [self.navigationController pushViewController:productSelectAutoCompleteViewController animated:YES];
    }
}

#pragma mark - UIPopoverListViewDataSource

- (UITableViewCell *)popoverListView:(UIPopoverListView *)popoverListView
                    cellForIndexPath:(NSIndexPath *)indexPath
{
    BOOL isDateRow = NO;
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    if ([self.statusValues count] >0) {
        NSString *statusValue = [self.statusValues objectAtIndex:indexPath.row];
        UILabel* textLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 20, cell.bounds.size.width, 20)];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                textLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 20, cell.bounds.size.width, 20)];
            }
        if((indexPath.row == self.nonScoreableIndex) || (indexPath.row == self.scoreableIndex)){
            isDateRow = YES;
        }else
            cell.textLabel.text = statusValue;
            if(isDateRow){
                UIView *greyBackground = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 5)];
               // textLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, cell.bounds.size.width, 20)];
                
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    greyBackground = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 5)];
                   // textLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, cell.bounds.size.width, 20)];
                }
                [greyBackground setBackgroundColor:[UIColor lightGrayColor]];
                textLabel.text = statusValue;
                [cell addSubview:greyBackground];                
            }
            [cell addSubview:textLabel];
        }
    return cell;
}

- (NSInteger)popoverListView:(UIPopoverListView *)popoverListView
       numberOfRowsInSection:(NSInteger)section
{
    return [self.statusValues count];
}

#pragma mark - UIPopoverListViewDelegate
/*!
 *  Picker to select the inspection status
 */
- (void)popoverListView:(UIPopoverListView *)popoverListView
     didSelectIndexPath:(NSIndexPath *)indexPath
{
    if ([self.statusValues count] > 0) {
        dispatch_queue_t backgroundQueue = dispatch_queue_create("com.mycompany.myqueue", 0);
        dispatch_async(backgroundQueue, ^{
            NSString *statusChange = [self.statusValues objectAtIndex:indexPath.row];

            NSString *auditMasterId = [[Inspection sharedInspection] auditMasterId];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

            NSArray *allInspectionStatuses = [userDefaults objectForKey:@"allInspectionStatuses"];
            NSArray *allIds = [userDefaults objectForKey:@"allIds"];
            NSArray *notifications = [userDefaults objectForKey:@"notifications"];
            NSArray *allDefaultStatuses = [userDefaults objectForKey:@"allDefaultStatuses"];
            NSArray *defaultIds = [userDefaults objectForKey:@"defaultIds"];
            //self.summaryGlobal.sendNotification = sendNotification;
           id selectedId = [allIds objectAtIndex:indexPath.row];
            for(int i = 0; i < defaultIds.count; i++){
                if(selectedId == defaultIds[i]){
                    if([selectedId intValue] != 4){
                        statusChange = allDefaultStatuses[i];
                        
                        self.selected = NO;
                    }else{
                        if(!self.selected)
                        {
                            self.previousInspectionStatus = self.summaryGlobal.inspectionStatus;
                        self.summaryGlobal.previousInspectionStatus = self.summaryGlobal.inspectionStatus;
                        self.productId = self.summaryGlobal.productId;
                            self.selected = YES;
                        }
                        
                    }
                    break;
                }
            }
            self.summaryGlobal.inspectionStatus = statusChange;
            [self.summaryGlobal updateInspectionColumnStatusInDB:statusChange withGroupId:[NSString stringWithFormat:@"%d", self.currentGroupId] withAuditMasterID:auditMasterId withProductId:[NSString stringWithFormat:@"%d", self.currentProductId] withProductGroupId:[NSString stringWithFormat:@"%d", self.currentGroupId] withSplitGroupId:[Inspection sharedInspection].currentSplitGroupId withDatabase:nil];
            [self recalculateSavedAuditsWithDatabase:nil withEdit:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.table reloadData];
            });
        });
    }
}

- (CGFloat)popoverListView:(UIPopoverListView *)popoverListView
   heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (void) recalculateSavedAuditsWithDatabase: (FMDatabase *) databaseLocal withEdit:(BOOL) edited {
    NSMutableArray *savedAuditsLocal = [[NSMutableArray alloc] init];
    FMResultSet *resultsGroupRatingsForSavedAudit;
    FMDatabase *databaseGroupRatings;
    if (!databaseLocal || ![databaseLocal goodConnection]) {
        databaseGroupRatings = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
        [databaseGroupRatings open];
    } else {
        databaseGroupRatings = databaseLocal;
    }
    for (SavedAudit *savedAudit in self.productAudits) {
        self.globalAuditMasterId = [Inspection sharedInspection].auditMasterId;
        NSString *queryStringForSavedAudit = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%d' AND %@='%d' AND %@='%@' AND %@='%@'", TBL_SAVED_SUMMARY, COL_PRODUCT_ID, savedAudit.productId, COL_PRODUCT_GROUP_ID, savedAudit.productGroupId, COL_AUDIT_MASTER_ID, [Inspection sharedInspection].auditMasterId, COL_SPLIT_GROUP_ID,savedAudit.splitGroupId];
        resultsGroupRatingsForSavedAudit = [databaseGroupRatings executeQuery:queryStringForSavedAudit];
        while ([resultsGroupRatingsForSavedAudit next]) {
            AuditApiSummary *summary = [[AuditApiSummary alloc] initWithString:[resultsGroupRatingsForSavedAudit stringForColumn:COL_SUMMARY] error:nil];
            savedAudit.inspectionStatus = summary.inspectionStatus;
            NSString *userEnteredInspectionSamples = [resultsGroupRatingsForSavedAudit stringForColumn:COL_USERENTERED_SAMPLES];
            //if ([[[NSUserDefaultsManager getObjectFromUserDeafults:selectedProgramName] lowercaseString] isEqualToString:@"aldi"]) {
            if (aggregateSamplesMode) {
                if (userEnteredInspectionSamples && ![userEnteredInspectionSamples isEqualToString:@""]) {
                    if (savedAudit.userEnteredAuditsCount == 0) {
                        savedAudit.userEnteredAuditsCount = [userEnteredInspectionSamples integerValue];
                    } else {
                        if (edited) {
                            savedAudit.userEnteredAuditsCount = [userEnteredInspectionSamples integerValue];
                        }
                    }
                }
            } else {
                if (userEnteredInspectionSamples && ![userEnteredInspectionSamples isEqualToString:@""]) {
                    savedAudit.userEnteredAuditsCount = [userEnteredInspectionSamples integerValue];
                }
            }
            if ([[resultsGroupRatingsForSavedAudit stringForColumn:COL_COUNT_OF_CASES] integerValue] > 0) {
                savedAudit.countOfCases = [[resultsGroupRatingsForSavedAudit stringForColumn:COL_COUNT_OF_CASES] integerValue];
            }
        }
        if(self.productId == savedAudit.productId){
            savedAudit.previousInspectionStatus = self.previousInspectionStatus;
        }
        [savedAuditsLocal addObject:savedAudit];
    }
    if (!databaseLocal) {
        [databaseGroupRatings close];
    }else
        [databaseLocal close];
    self.productAudits = [savedAuditsLocal copy];
}

/*!
 *  Delegate call back from the sub row to update countOfCases and reload table view.
 */
- (void) updateCountOfCasesAndReloadTableView {
    UIWindow *win = [[UIApplication sharedApplication] keyWindow];
    self.syncOverlayView = [[SyncOverlayView alloc] initWithFrame:CGRectMake(0, 0, win.frame.size.width, win.frame.size.height)];
    self.syncOverlayView.headingTitleLabel.text = @"Calculating..";
    [self.syncOverlayView showActivityView];
    [win addSubview:self.syncOverlayView];
    dispatch_queue_t backgroundQueue = dispatch_queue_create("com.mycompany.myqueue", 0);
    dispatch_async(backgroundQueue, ^{
        [self recalculateSavedAuditsWithDatabase:nil withEdit:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self sortProductAuditsByName];
            [self.table reloadData];
            [self.syncOverlayView dismissActivityView];
            [self.syncOverlayView removeFromSuperview];
        });
    });
}

- (void) recalculateSavedAuditsWithDatabase: (FMDatabase *) databaseLocal {
    
}

/*InspectionStatusViewController
 
 SKSTableViewCell
	-InspectionSubTableViewCell
 SKSTableViewCell
	-InspectionSubTableViewCell - UITableViewCell
                                - UITableViewCell with Button
                                - InspectionDefectTableTableViewCell
 
 
 SummaryDetailsTableViewCell
	- UITableViewCell
	- InspectionDefectTableTableViewCell
*/

@end
