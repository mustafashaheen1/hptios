//
//  ProductViewController.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/18/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "ProductViewController.h"
#import "Inspection.h"
#import "InspectionStatusViewController.h"
#import "WebviewForProductViewController.h"
#import "DBConstants.h"
#import "InspectionStatusViewControllerRetailViewController.h"
#import "ProductSelectAutoCompleteViewController.h"
#import "CrashLogHandler.h"
#import "CollaborativeInspection.h"
#import "FlaggedMessage.h"
#define yCoordinateForRatingView 63

@interface ProductViewController ()

@end

@implementation ProductViewController

@synthesize container;
@synthesize productRatingView;
@synthesize labelHolderButton;
@synthesize product;
@synthesize productRatingsArray;
@synthesize currentAudit;
@synthesize duplicateButtonTouchedButton;
@synthesize userEnteredInspectionSamples;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) setupNavBar {
    [super setupNavBar];
}

- (void)viewWillAppear:(BOOL)animated
{
    //[self addDeleteButtonToTheToolBar];
    self.pageTitle = @"ProductViewController";
    [super viewWillAppear:animated];
    [self setupNavBar];
    [self cameraButtonIconDecide];
   
    //[self addProductManualNavigationItem];
//    if (![self checkIfManualPresent]) {
//        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithCustomView:self.saveButton], [[UIBarButtonItem alloc] initWithCustomView:self.cameraButton],[[UIBarButtonItem alloc] initWithCustomView:self.duplicateButton], nil];
//    }
    [self chooseBackButtonToBePresent];
    [self removePreviousAndNextAuditButtonsIfDistinctSamplesIsOff];
    if (aggregateSamplesMode) {
        [self popoulateArray];
        if(![[Inspection sharedInspection] checkForOrderData]){
        //hide the up and down arrows
        self.nextProductButton.hidden = YES;
        self.previousProductButton.hidden = YES;
        }
    }
    if([self.product.qualityManuals count]>0)
        [self addProductManualNavigationItem];
    [self initNotificationCenterListener];
    self.warningIcon.hidden = YES;
}

-(int)getInspectionMinimumCount {
    int totalCountOfCases =self.savedAudit.countOfCases;
   // if([self isSavedAuditEmpty]) //when saved audit is null- first time PO started
    //if(!self.savedAudit) //when saved audit is null- first time PO started
        totalCountOfCases = self.countOfCasesEnteredByTheUser;
    
    InspectionMinimums *minimums = [self.viewModel getRequiredSampleCountWithGroupId:self.currentAudit.product.group_id];
    IMResult* inspectionMinimumsResult =  [minimums getResultForAuditCount:0 withTotalCount:totalCountOfCases withInspectionStatus:INSPECTION_STATUS_ACCEPT];
    //NSLog(@"Insights - Inspection Minimum count is: %d", count);
    return inspectionMinimumsResult.count;
}
/*
-(BOOL)isSavedAuditEmpty {
 if(!self.savedAudit || (self.savedAudit.productId == 0 && self.savedAudit.productGroupId ==0))
     return YES;
    
    return NO;
}
*/
- (void) checkCountOfCases:(Rating *) currentRating withCount:(NSString*)count{
    int totalCountOfCases = [count intValue];
    InspectionMinimums *minimums = [self.viewModel getRequiredSampleCountWithGroupId:self.currentAudit.product.group_id];
    IMResult* inspectionMinimumsResult =  [minimums getResultForAuditCount:0 withTotalCount:totalCountOfCases withInspectionStatus:INSPECTION_STATUS_ACCEPT];
    if(currentRating.ratingID == minimums.rating_id){
 self.currentAudit.userEnteredInspectionSamples = [NSString stringWithFormat:@"%i", inspectionMinimumsResult.count];
        self.userEnteredInspectionSamples = self.currentAudit.userEnteredInspectionSamples;
        self.numberOfProductsInspected.text = self.userEnteredInspectionSamples;
    }
}
-(void)addProductManualNavigationItem{
    if(aggregateSamplesMode){
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithCustomView:self.saveButton], [[UIBarButtonItem alloc] initWithCustomView:self.cameraButton],[[UIBarButtonItem alloc] initWithCustomView:self.productInfoButton], nil];
    }else{
       self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithCustomView:self.saveButton], [[UIBarButtonItem alloc] initWithCustomView:self.cameraButton],[[UIBarButtonItem alloc] initWithCustomView:self.productInfoButton],[[UIBarButtonItem alloc] initWithCustomView:self.duplicateButton], nil];
    }
}

- (void) popoulateArray {
    NSArray *interArray = [[Inspection sharedInspection] productGroups];
    NSMutableArray *interArrayMutable = [NSMutableArray array];
    for (int i=0; i < [interArray count]; i++) {
        if ([[interArray objectAtIndex:i] isKindOfClass:[ProgramGroup class]]) {
            ProgramGroup *pg = [interArray objectAtIndex:i];
            [interArrayMutable addObjectsFromArray:pg.products];
        } else {
            [interArrayMutable addObject:[interArray objectAtIndex:i]];
        }
    }
    
    //sortProductAuditsByName
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
        NSArray *sortDescriptors = @[sort];
        interArrayMutable = [[interArrayMutable sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
    
    self.productsArrayForNavigation = [interArrayMutable copy];
    for (int i=0; i < [self.productsArrayForNavigation count]; i++) {
        Product *productLocal = [self.productsArrayForNavigation objectAtIndex:i];
        if (productLocal.product_id == self.product.product_id) {
            self.indexOfProductsArray = i;
            if([self.productsArrayForNavigation count]<=1){
                self.nextProductButton.hidden = YES;
                self.previousProductButton.hidden = YES;
            }
            else if (self.indexOfProductsArray == 0) {
                self.nextProductButton.hidden = NO;
                self.previousProductButton.hidden = YES;
            } else if (self.indexOfProductsArray == [self.productsArrayForNavigation count] - 1) {
                self.nextProductButton.hidden = YES;
                self.previousProductButton.hidden = NO;
            } else {
                self.nextProductButton.hidden = NO;
                self.previousProductButton.hidden = NO;
            }
        }
    }
}




- (void) addDeleteButtonToTheToolBar {
    //[self.navigationController setToolbarHidden:YES animated:YES];
    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc]
                                     initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                     target:self
                                     action:@selector(deleteAuditTouched)];
    [self setToolbarItems: [NSArray arrayWithObject:deleteButton]];
}

- (void) removePreviousAndNextAuditButtonsIfDistinctSamplesIsOff {
    if (aggregateSamplesMode) {
//        self.numberOfProductsInspected.frame = CGRectMake(self.view.frame.size.width - 40, self.numberOfProductsInspected.frame.origin.y, self.numberOfProductsInspected.frame.size.width, self.numberOfProductsInspected.frame.size.height);
//        self.labelHolderButton.frame = CGRectMake(self.view.frame.size.width - 40, self.labelHolderButton.frame.origin.y, self.labelHolderButton.frame.size.width, self.labelHolderButton.frame.size.height);
        self.inspectionLabel.frame = CGRectMake(self.view.frame.size.width - 95, self.inspectionLabel.frame.origin.y, self.inspectionLabel.frame.size.width, self.inspectionLabel.frame.size.height);
        self.samplesLabel.frame = CGRectMake(self.view.frame.size.width - 85, self.samplesLabel.frame.origin.y, self.samplesLabel.frame.size.width, self.samplesLabel.frame.size.height);
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithCustomView:self.saveButton], [[UIBarButtonItem alloc] initWithCustomView:self.cameraButton], nil];
        [self.nextProductButton setBackgroundImage:[UIImage imageNamed:@"ic_down.png"] forState:UIControlStateNormal];
        [self.previousProductButton setBackgroundImage:[UIImage imageNamed:@"ic_up.png"] forState:UIControlStateNormal];
        self.nextProductButton.hidden = NO;
        self.previousProductButton.hidden = NO;
    } else {
        self.inspectionLabel.hidden = YES;
        self.samplesLabel.hidden = YES;
        self.nextProductButton.hidden = NO;
        self.previousProductButton.hidden = NO;
    }
}

- (IBAction)numberOfInspectionSamplesButtonTouched:(id)sender {
    //NSLog(@"numberOfInspectionSamplesButtonTouched");
    if (aggregateSamplesMode) {
        [self.parentViewController.view endEditing:YES]; // dismiss any previous open keyboard
        UIAlertView* dialog = [[UIAlertView alloc] initWithTitle:@"Enter the inspection samples count" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        [dialog setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [[dialog textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
        //[[dialog textFieldAtIndex:0] setText:self.numberOfProductsInspected.text];
        [dialog setTag:2];
        [dialog show];
    }
}
- (IBAction)watchedFlagPressed:(UIButton *)sender {
        //NSString *flaggedProductMessageToShow = productListItem.orderData.Message;
        NSArray *orderDataArray = [OrderData getOrderDataForItemNumberWithPONumber:self.product.selectedSku withPONumber:[[Inspection sharedInspection] poNumberGlobal]];
    OrderData* od = [orderDataArray lastObject];
        //DI-2933 - use the messages array to render text/html message
    NSMutableArray *flaggedMessageArray = od.allFlaggedProductMessages;
        NSString* flaggedProductName = self.product.name;
        
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
}

- (void)deleteAuditTouched {
    [self.currentAudit deleteCurrentAuditFromDB];
    [self previousProductButtonTouched:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    self.saved = NO;
    [super viewDidLoad];
    if(!self.viewModel)
        self.viewModel = [[ProductViewModel alloc]init];
    [self refreshState];

    // Do any additional setup after loading the view from its nib.
}

//TODO Needs some serious refactoring
- (void) refreshState {
    if ([self.parentView isEqualToString:defineProductSelectViewController]) {
        UIWindow *win = [[UIApplication sharedApplication] keyWindow];
        self.syncOverlayView = [[SyncOverlayView alloc] initWithFrame:CGRectMake(0, 0, win.bounds.size.width, win.bounds.size.height)];
        self.syncOverlayView.headingTitleLabel.text = PreparingRatings;
        [self.syncOverlayView showActivityView];
        [win addSubview:self.syncOverlayView];
    }
    
    [[Inspection sharedInspection] setCurrentAuditGroupId:[DeviceManager getCurrentTimeString]];
    if (self.savedAudit) {
        [[Inspection sharedInspection] setCurrentAuditGroupId:self.savedAudit.auditGroupId];
    }
    
    [self duplicatesViewSetup];
        
    self.inspectionCount = 1;
    if (self.savedAudit) {
        if (aggregateSamplesMode) {
            if (self.savedAudit.userEnteredAuditsCount > 0) {
                self.userEnteredInspectionSamples = [NSString stringWithFormat:@"%d", self.savedAudit.userEnteredAuditsCount];
            }
            if (self.savedAudit.userEnteredAuditsCount == 0) {
                //DI-2931 - Inspection Minimum count
                int minRequiredCount = [self getInspectionMinimumCount];
                if(minRequiredCount>0){
                 //   self.savedAudit.userEnteredAuditsCount = minRequiredCount;
                self.numberOfProductsInspected.text = [NSString stringWithFormat:@"%d",minRequiredCount];
                self.userEnteredInspectionSamples = [NSString stringWithFormat:@"%d",minRequiredCount];
                self.currentAudit.userEnteredInspectionSamples = self.userEnteredInspectionSamples;
                    //self.savedAudit.userEnteredAuditsCount = minRequiredCount;
                    self.inspectionCount = minRequiredCount;
                }
            }
        } else {
            if(self.savedAudit.auditNumberToShow>0) //for summary detail screen - take user to the specific audit
                self.inspectionCount = self.savedAudit.auditNumberToShow;
            else
            self.inspectionCount = self.savedAudit.auditsCount + 1;
        }
        self.product = [[Inspection sharedInspection] getProductForProductId:self.savedAudit.productId withGroupId:self.savedAudit.productGroupId];
        self.countOfCasesEnteredByTheUser = self.savedAudit.countOfCases;
            /*dispatch_async(dispatch_get_main_queue(), ^{
                self.productNameLabel.text = self.product.product_name;
                [self.productNameLabel setNeedsDisplay];
                //NSLog(@"ProductViewController.m 11: %@", self.product.product_name);
            });*/
    }
    [self configureFonts];
  
   // dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        if (aggregateSamplesMode) {
            /*if (self.savedAudit.userEnteredAuditsCount > 0) { //this was adding productRatingView twice for every audit
                [self setupDistinctSamples];
            } else {*/
                [self setupCurrentAudit];
            //}
        } else {
            [self setupCurrentAudit];
        }
        //[self setupCurrentAudit];
        //dispatch_async(dispatch_get_main_queue(), ^{
            self.productNameLabel.text = self.product.product_name;
            //NSLog(@"ProductViewController.m : %@", self.product.product_name);
            [self cameraButtonIconDecide];
            self.numberOfProductsInspected.text = [NSString stringWithFormat:@"%d", self.inspectionCount];
            if (aggregateSamplesMode) {
                if (self.savedAudit.userEnteredAuditsCount > 0) {
                    self.numberOfProductsInspected.text = [NSString stringWithFormat:@"%d", self.savedAudit.userEnteredAuditsCount];
                    self.currentAudit.userEnteredInspectionSamples = [NSString stringWithFormat:@"%d", self.savedAudit.userEnteredAuditsCount];
                }else{
                    //DI-2931 - Inspection Minimum count - first time gets here
                    int minRequiredCount = [self getInspectionMinimumCount];
                    if(minRequiredCount>0){
                    self.numberOfProductsInspected.text = [NSString stringWithFormat:@"%d",minRequiredCount];
                    self.userEnteredInspectionSamples = [NSString stringWithFormat:@"%d",minRequiredCount];
                    self.currentAudit.userEnteredInspectionSamples = self.userEnteredInspectionSamples;
                    }
                }
            }
            [self addProductRatingView];
            [self.syncOverlayView dismissActivityView];
            [self.syncOverlayView removeFromSuperview];
        //});
   // });
}

- (void) setupDistinctSamples {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.numberOfProductsInspected.text = [NSString stringWithFormat:@"%d", self.inspectionCount];
    });
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        [self setupCurrentAudit];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self cameraButtonIconDecide];
            //being called twice
            [self addProductRatingViewWithAnimationPop];
            [self.syncOverlayView dismissActivityView];
            [self.syncOverlayView removeFromSuperview];
        });
    });
}

- (void) duplicatesViewSetup {
    self.duplicateCountsView.frame = CGRectMake(30, 30, self.duplicateCountsView.frame.size.width, self.duplicateCountsView.frame.size.height);
    if (IS_IPHONE5 || IS_IPHONE6) {
        self.duplicateCountsView.frame = CGRectMake(30, 120, self.duplicateCountsView.frame.size.width, self.duplicateCountsView.frame.size.height);
    }
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {

    UIWindow *win = [[UIApplication sharedApplication] keyWindow];
        self.duplicateCountsView.frame = CGRectMake(win.bounds.size.width/2-self.duplicateCountsView.frame.size.width/2, win.bounds.size.height/2-self.duplicateCountsView.frame.size.width, self.duplicateCountsView.frame.size.width, self.duplicateCountsView.frame.size.height);
    
    }
    
    self.duplicateCountsView.layer.borderColor = [[UIColor blackColor] CGColor];
    self.duplicateCountsView.layer.cornerRadius = 5.0;
    self.duplicateCountsView.layer.borderWidth = 2.0;

}

- (void) configureFonts {
    self.labelHolderButton.layer.cornerRadius = 10.0;
    self.labelHolderButton.layer.borderWidth = 2.0;
    self.labelHolderButton.layer.borderColor = [[UIColor blackColor] CGColor];
}

- (void) setupCurrentAudit {
    dispatch_async(dispatch_get_main_queue(), ^{ //fix crash
        [self chooseBackButtonToBePresent];
        });
    self.currentAudit = [[CurrentAudit alloc] init];
    if (aggregateSamplesMode) {
            self.currentAudit.userEnteredInspectionSamples = @"1";
    }
    [self.currentAudit setAllTheCurrentAuditVariables:self.inspectionCount withAuditMasterId:[[Inspection sharedInspection] auditMasterId] withAuditGroupId:[[Inspection sharedInspection] currentAuditGroupId] withProductID:self.product.product_id  withProductGroupID:self.product.group_id withProgramID:self.product.program_id withProgramVersion:[self.product.program_version intValue]];
    self.currentAudit.product = self.product;
    self.productNameLabel.text = self.product.product_name;
    if((self.savedAudit.isFlagged) || (self.product.isFlagged)){
        self.productNameLabel.textColor= [UIColor redColor];
        self.watchedFlag.hidden = NO;
    }else{
        self.watchedFlag.hidden = YES;
        self.productNameLabel.textColor=[UIColor colorWithRed:0/255.0f green:51/255.0f blue:102.0/255.0f alpha:1.0];

    }
    //NSLog(@"ProductViewController.m: %@", self.product.product_name);
    [self loadProductRatings];
    if ([self loadCurentAuditIfPresent]) {
        if ([[self.currentAudit.product ratingsFromUI] count] > 0) {
            [self populateRatingsWithUIValues:[self.currentAudit.product ratingsFromUI]];
        }
    } else {
    }
    if (aggregateSamplesMode) {
        //DI-3018 - set the inspection min count if user has not manually changed the inspection count
        // when moving through the audits using up/down
        if ([self.currentAudit.userEnteredInspectionSamples integerValue] == 1) {
            int minRequiredCount = [self getInspectionMinimumCount];
            if(minRequiredCount>0){
                self.currentAudit.userEnteredInspectionSamples = [NSString stringWithFormat:@"%i", minRequiredCount];
            }
        }
        self.userEnteredInspectionSamples = self.currentAudit.userEnteredInspectionSamples;
        if ([self.userEnteredInspectionSamples integerValue] > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.numberOfProductsInspected.text = [NSString stringWithFormat:@"%@", self.userEnteredInspectionSamples];
            });
        }
    }
    self.currentAudit.countOfCasesFromSavedAudit = self.savedAudit.countOfCases;
    [[Inspection sharedInspection] setCurrentAudit:self.currentAudit];
}

- (void) loadProductRatings {
    Product *productLocal = self.currentAudit.product;
    self.productRatingsArray = [[NSMutableArray alloc] init];
    self.productRatingsArray = [[productLocal getAllRatings] mutableCopy];
    if (![[Inspection sharedInspection] checkForOrderData]) {
        self.productRatingsArray = [self removeCountOfCasesRatingFromRatings:[productLocal getAllRatings]];
    } else {
        self.productRatingsArray = [[productLocal getAllRatings] mutableCopy];
    }
    //populate defects
    //DI-2074 - the severity ids become 0 if they are not populated here
    for(Rating *rating in self.productRatingsArray){
        [rating getAllDefects];
    }
    if ([[Inspection sharedInspection] checkForOrderData]) {
        NSString *sku = product.selectedSku;
        NSString *PONumber = [Inspection sharedInspection].poNumberGlobal;
        NSSet *set;
        if((![PONumber  isEqual: @""]) && (PONumber != nil)){
           set  = [OrderData getItemNumbersForPONumberSelected];
        }else{
            set  = [OrderData getItemNumbersForGRNSelected];
        }
        if (!sku || [sku isEqualToString:@""]) {
            for (NSString *skuLocal in [set allObjects]) {
                for (NSString *skuLocal2 in product.skus) {
                    if ([skuLocal2 isEqualToString:skuLocal]) {
                        sku = skuLocal2;
                        break;
                    }
                }
            }
        }
       
        if (!sku || [sku isEqualToString:@""]) {
            sku = [product.skus lastObject];
        }
        self.product.selectedSku = sku;
        self.currentAudit.product.selectedSku = sku; // populate SKU
        [self loadOrderData:sku];
    }else{
        //populate from non-order data values
        NonOrderDataValues* nonOrderDataValues = [Inspection sharedInspection].nonOrderDataInspectionValues;
        NSMutableArray *finishedRatings = [[NSMutableArray alloc]init];
        for(Rating *rating in self.productRatingsArray){
            if ([[rating.order_data_field uppercaseString] isEqualToString:ORDERDATAVENDORNAME]) {
                rating.ratingAnswerFromUI = nonOrderDataValues.supplierName;
                [finishedRatings addObject:rating];
            } else if ([[rating.order_data_field uppercaseString] isEqualToString:ORDERDATAPONUMBER]) {
                rating.ratingAnswerFromUI = nonOrderDataValues.poNumber;
                [finishedRatings addObject:rating];
            }else if ([[rating.order_data_field uppercaseString] isEqualToString:ORDERDATAGRN]) {
                rating.ratingAnswerFromUI = nonOrderDataValues.grn;
                [finishedRatings addObject:rating];
            }else
                [finishedRatings addObject:rating];
        }
        self.productRatingsArray = finishedRatings;
    }
}

- (NSMutableArray *) removeCountOfCasesRatingFromRatings:(NSArray *) ratings {
    NSMutableArray *ratingsLocal = [[NSMutableArray alloc] init];
    for (Rating *rating in ratings) {
        if ([[Inspection sharedInspection] checkForOrderData]) {
            if (![[rating.order_data_field uppercaseString] isEqualToString:ORDERDATAQUANTITYOFCASES]) {
                [ratingsLocal addObject:rating];
            } else {
                self.currentAudit.countOfCasesRatingPresent = YES;
                int countOfCasesFromAnswer = [rating.ratingAnswerFromUI integerValue];
                self.countOfCasesEnteredByTheUser = countOfCasesFromAnswer;
                [ratingsLocal addObject:rating];
            }
        } else {
            if(![rating.name compare:@"COUNT OF CASES" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                [ratingsLocal addObject:rating];
            } else {
                self.currentAudit.countOfCasesRatingPresent = YES;
                [ratingsLocal addObject:rating];
            }
        }
    }
    return ratingsLocal;
}

- (void) loadOrderData: (NSString *) sku{
    NSArray *modifiedRatings = [[NSArray alloc] init];
    NSString *PONumber = [Inspection sharedInspection].poNumberGlobal;
    if((![PONumber  isEqual: @""]) && (PONumber != nil)){
    modifiedRatings = [OrderData populateAllRatingsData:self.productRatingsArray withPONumber:PONumber withItemNumber:sku];
    self.orderDataGlobal = [OrderData getOrderDataWithPO:PONumber withItemNumber:sku withTime:[[Inspection sharedInspection] dateTimeForOrderData]];
    }else{
        NSString *grn = [Inspection sharedInspection].grnGlobal;
        modifiedRatings = [OrderData populateAllRatingsData:self.productRatingsArray withGRN:grn withItemNumber:sku];
        self.orderDataGlobal = [OrderData getOrderDataWithGRN:grn withItemNumber:sku withTime:[[Inspection sharedInspection] dateTimeForOrderData]];
    }
    self.productRatingsArray = [self removeCountOfCasesRatingFromRatings:modifiedRatings];
}

- (void) chooseBackButtonToBePresent {
    if (aggregateSamplesMode) {
        [self.backButton addSubview:self.arrowBackIcon];
        [self.backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithCustomView: self.backButton], nil];// [[UIBarButtonItem alloc] initWithCustomView:settingsButton], nil];
    }
}

- (void) goBack {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveUtilityView" object:self];
    [self gotoProductSelectScreen];
    //NSLog(@"dfgdgf ");
}

- (void) gotoProductSelectScreen {
    BOOL productSelectPresent = NO;
    int index = 0;
    for (int i = 0; i < [self.navigationController.viewControllers count]; i++) {
        if ([[self.navigationController.viewControllers objectAtIndex:i] isKindOfClass:[ProductSelectAutoCompleteViewController class]]) {
            productSelectPresent = YES;
            index = i;
        }
    }
    ProductSelectAutoCompleteViewController *productSelectAutoCompleteViewController;
    if (!productSelectPresent) {
        productSelectAutoCompleteViewController = [[ProductSelectAutoCompleteViewController alloc] initWithNibName:@"ProductSelectAutoCompleteViewController" bundle:nil];
        [self.navigationController pushViewController:productSelectAutoCompleteViewController animated:YES];
    } else {
        productSelectAutoCompleteViewController = (ProductSelectAutoCompleteViewController *) [self.navigationController.viewControllers objectAtIndex:index];
        [self.navigationController popToViewController:productSelectAutoCompleteViewController animated:YES];
    }
}

- (void) populateRatingsWithUIValues: (NSArray *) ratingsFromUILocal {
    NSMutableArray *arrayLocal = [[NSMutableArray alloc] init];
    for (Rating *ratingUI in ratingsFromUILocal) {
        for (Rating *rating in self.productRatingsArray) {
            if (ratingUI.ratingID == rating.ratingID) {
                rating.ratingAnswerFromUI = ratingUI.ratingAnswerFromUI;
                if ([ratingUI.defectsFromUI count] > 0) {
                    NSMutableArray *defectLocal = [[NSMutableArray alloc] init];
                    NSArray *ratingDefects = [rating getAllDefects];
                    for (Defect *defectUI in ratingUI.defectsFromUI) {
                        for (Defect *defect in ratingDefects) {
                            if (defectUI.defectID == defect.defectID) {
                                
                                for(AuditApiSeverity *tempSeverity in defectUI.severities)
                                {
                                    for(Severity *severity in defect.severities)
                                    {
                                        NSString *name = severity.name;
                                        NSString *name2 = tempSeverity.severity;
                                        if([name isEqualToString:name2]){
                                            severity.inputOrCalculatedPercentage = tempSeverity.percentage;
                                            severity.inputNumerator = tempSeverity.numerator;
                                            severity.inputDenominator = tempSeverity.denominator;
                                        }
                                    }
                                }
                                defect.isSetFromUI = defectUI.isSetFromUI;
                                [defectLocal addObject:defect];
                            }
                        }
                    }
                    rating.defectsFromUI = [[NSMutableArray alloc] init];
                    rating.defectsFromUI = defectLocal;
                }
                [arrayLocal addObject:rating];
            }
        }
    }
    self.productRatingsArray = [[NSMutableArray alloc] init];
    self.productRatingsArray = arrayLocal;
}

- (void) populateRatingsWithPersistentValues: (NSArray *) ratingsReponses {
    NSMutableArray *arrayLocal = [[NSMutableArray alloc] init];
    for (Rating *ratingForPersistent in ratingsReponses) {
        for (Rating *rating in self.productRatingsArray) {
            if (ratingForPersistent.ratingID == rating.ratingID) {
                if (rating.optionalSettings.persistent) {
                    rating.ratingAnswerFromUI = ratingForPersistent.ratingAnswerFromUI;
                    [arrayLocal addObject:rating];
                } else {
                    [arrayLocal addObject:rating];
                }
            }
        }
    }
    self.productRatingsArray = [[NSMutableArray alloc] init];
    self.productRatingsArray = arrayLocal;
}


- (void) addProductRatingView {
    
    //TODO fix memory leak for ProductRatingViewController
    // reusing self.productRatingView fixes the leak - need to refresh the data
   /* if(self.productRatingView){
        self.productRatingView.delegate = self;
    
        //viewDidLoad content in this method - but calling this causes memory leak
        //without this there is no memory leak
        //[self.productRatingView refreshData];
    
        self.productRatingView.currentAuditGlobal = self.currentAudit;
        self.productRatingView.ratingsGlobal = self.productRatingsArray;
        self.productRatingView.parentView = @"ProductViewController";
        [self.productRatingView.ratingsTableView reloadData];
        //self.productRatingView = productRatingViewLocal;
        [self.view addSubview:self.productRatingView.view];
    }else{*/
 
    ProductRatingViewController *productRatingViewLocal = [[ProductRatingViewController alloc] initWithNibName:kProductRatingViewNIBName bundle:nil];
    productRatingViewLocal.view.frame = CGRectMake(0, yCoordinateForRatingView, self.view.frame.size.width, self.view.frame.size.height);
    productRatingViewLocal.delegate = self;
    productRatingViewLocal.currentAuditGlobal = self.currentAudit;
    NSString *temp = @"";
    for(Rating *tempRating in self.productRatingsArray){
        if([tempRating.order_data_field isEqualToString:@"QuantityOfCases"]){
            temp = tempRating.ratingAnswerFromUI;
        }
    }
    for(Rating *tempRating in self.productRatingsArray){
        if([tempRating.order_data_field isEqualToString:@"QuantityOfItems"]){
            if(tempRating.ratingAnswerFromUI == nil){
                tempRating.ratingAnswerFromUI = temp;
        }
    }
    }
    productRatingViewLocal.ratingsGlobal = self.productRatingsArray;
    productRatingViewLocal.parentView = @"ProductViewController";
    [productRatingViewLocal.ratingsTableView reloadData];
    self.productRatingView = productRatingViewLocal;
    [self.view addSubview:productRatingViewLocal.view];
}

- (void) addProductRatingViewWithAnimationPush {
    ProductRatingViewController *productRatingViewLocal = [[ProductRatingViewController alloc] initWithNibName:kProductRatingViewNIBName bundle:nil];
    productRatingViewLocal.view.frame = CGRectMake(0, yCoordinateForRatingView, self.view.frame.size.width, self.view.frame.size.height);
    productRatingViewLocal.delegate = self;
    productRatingViewLocal.currentAuditGlobal = self.currentAudit;
    NSString *temp = @"";
    for(Rating *tempRating in self.productRatingsArray){
        if([tempRating.order_data_field isEqualToString:@"QuantityOfCases"]){
            temp = tempRating.ratingAnswerFromUI;
        }
    }
    for(Rating *tempRating in self.productRatingsArray){
        if([tempRating.order_data_field isEqualToString:@"QuantityOfItems"]){
            if(tempRating.ratingAnswerFromUI == nil){
                tempRating.ratingAnswerFromUI = temp;
        }
    }
    }
    productRatingViewLocal.ratingsGlobal = self.productRatingsArray;
    productRatingViewLocal.parentView = @"ProductViewController";
    [productRatingViewLocal.ratingsTableView reloadData];
    self.productRatingView = productRatingViewLocal;
    [self.view addSubview:productRatingViewLocal.view];
    /*[UIView animateWithDuration:0.50
                     animations:^{
                         productRatingViewLocal.view.frame = CGRectMake(0, yCoordinateForRatingView, self.view.frame.size.width, self.view.frame.size.height);
                     }];*/
}

- (void) addProductRatingViewWithAnimationPop {
    ProductRatingViewController *productRatingViewLocal = [[ProductRatingViewController alloc] initWithNibName:kProductRatingViewNIBName bundle:nil];
    productRatingViewLocal.view.frame = CGRectMake(0, yCoordinateForRatingView, self.view.frame.size.width, self.view.frame.size.height);
    productRatingViewLocal.delegate = self;
    productRatingViewLocal.currentAuditGlobal = self.currentAudit;
    NSString *temp = @"";
    for(Rating *tempRating in self.productRatingsArray){
        if([tempRating.order_data_field isEqualToString:@"QuantityOfCases"]){
            temp = tempRating.ratingAnswerFromUI;
        }
    }
    for(Rating *tempRating in self.productRatingsArray){
        if([tempRating.order_data_field isEqualToString:@"QuantityOfItems"]){
            if(tempRating.ratingAnswerFromUI == nil){
                tempRating.ratingAnswerFromUI = temp;
        }
    }
    }
    productRatingViewLocal.ratingsGlobal = self.productRatingsArray;
    productRatingViewLocal.parentView = @"ProductViewController";
    [productRatingViewLocal.ratingsTableView reloadData];
    self.productRatingView = productRatingViewLocal;
    [self.view addSubview:productRatingViewLocal.view];
//    [UIView animateWithDuration:0.50
//                     animations:^{
//                         productRatingViewLocal.view.frame = CGRectMake(0, yCoordinateForRatingView, self.view.frame.size.width, self.view.frame.size.height);
//                     }];
}

- (void) proceedToNextGroup:(NSArray *) ratingsReponses withSuccess:(BOOL)success {
    if (success) {
        self.currentAudit.product.ratingsFromUI = [[NSMutableArray alloc] init];
        self.ratingResponsesGlobal = ratingsReponses;
        if ([ratingsReponses count] > 0) {
            for (Rating *rating in ratingsReponses) {
                [self.currentAudit.product addRating:rating];
                if ([rating.order_data_field isEqualToString:@"QuantityOfCases"]) {
                    

                        self.countOfCasesEnteredByTheUser = [rating.ratingAnswerFromUI integerValue];
                    }
                if([rating.order_data_field isEqualToString:@"QuantityOfItems"]){
                    self.inspectionCountOfCasesEnteredByTheUser = [rating.ratingAnswerFromUI integerValue];
                }
            }
        }
        if(self.duplicateButtonTouchedButton) {
            self.duplicateButtonTouchedButton = NO;
            // if valid then show the duplicate inspection dialog
            [self.syncOverlayView dismissActivityView];
            [self.syncOverlayView removeFromSuperview];
            [self duplicatesCountViewBringToTheFront];
        } else {
            [self saveCurrentAudit:0];
        }
    } else {
        [self.syncOverlayView dismissActivityView];
        [self.syncOverlayView removeFromSuperview];
    }
}

- (void) duplicatesCountViewBringToTheFront {
    UIWindow *win = [[UIApplication sharedApplication] keyWindow];
    self.duplicateOverlayView = [[DuplicateOverlayView alloc] initWithFrame:CGRectMake(0, 0, win.bounds.size.width, win.bounds.size.height)];
    self.duplicateOverlayView.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.6];
    [win addSubview:self.duplicateOverlayView];
    [self.duplicateTextField becomeFirstResponder];
    [win addSubview:self.duplicateCountsView];
}

- (IBAction)cancelDuplicateCountsViewButtonTouched:(id)sender {
    [self.duplicateOverlayView removeFromSuperview];
    [self resetDuplicatesView];
}

- (IBAction)okDuplicateCountsViewButtonTouched:(id)sender {
    NSString* duplicateCount = [self.duplicateTextField text];
    NSInteger duplicateCountInt = [duplicateCount intValue];
    [self.duplicateOverlayView removeFromSuperview];
    if ([duplicateCount intValue] > 99) {
        [[[UIAlertView alloc] initWithTitle:@"Duplicates cannot be greater than 99" message:@"" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    } else {
        UIWindow *win = [[UIApplication sharedApplication] keyWindow];
        self.syncOverlayView = [[SyncOverlayView alloc] initWithFrame:CGRectMake(0, 0, win.bounds.size.width, win.bounds.size.height)];
        self.syncOverlayView.headingTitleLabel.text = CreatingDuplicateAudits;
        [self.syncOverlayView showActivityView];
        [win addSubview:self.syncOverlayView];
        [self saveCurrentAudit:duplicateCountInt];
    }
    [self resetDuplicatesView];
}

- (void) resetDuplicatesView {
    [self.duplicateTextField resignFirstResponder];
    self.duplicateTextField.text = @"";
    [self.duplicateCountsView removeFromSuperview];
}

/*
-(void) showDuplicateInspectionDialog {
    // if valid then show the dialog below
    UIAlertView* dialog = [[UIAlertView alloc] initWithTitle:@"Duplicate Inspections Count" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [dialog setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [[dialog textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeDefault];
    [dialog setTag:1];
    [dialog show];
}*/

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag==2) {
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
                 [[[UIAlertView alloc] initWithTitle:@"Samples can't be 0 or empty" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            else if([valueEntered integerValue]>999)
                [[[UIAlertView alloc] initWithTitle:@"Count should be less than 999" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            /*else if(isGreaterThanCountOfCases)
                 [[[UIAlertView alloc] initWithTitle:@"Inspection Samples should be less than the count of cases" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];*/
            else {
                //NSLog(@"cancelling inspection");
                self.numberOfProductsInspected.text = [[alertView textFieldAtIndex:0] text];
                self.userEnteredInspectionSamples = [[alertView textFieldAtIndex:0] text];
                self.currentAudit.userEnteredInspectionSamples = self.userEnteredInspectionSamples;
            }
        }
    } else {
        if ([alertView textFieldAtIndex:0]) {
            NSString *text = [alertView textFieldAtIndex:0].text;
            if (![text isEqualToString:@""]) {
                NSString *countString = [alertView textFieldAtIndex:0].text;
                int countOfCases = [countString intValue];
                if (countOfCases > 0) {
                    self.countOfCasesEnteredByTheUser = countOfCases;
                    [self.productRatingView submitAnswersTouched:self];
                } else {
                    [self showAlertForCountOfCasesEntering];
                }
            } else {
                [self showAlertForCountOfCasesEntering];
            }
        }
    }
}

- (void) saveCurrentAudit:(NSInteger)duplicateCount {
    if (self.currentAudit) {
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            self.currentAudit.product.group_id = self.product.group_id;
            [self.currentAudit saveCurrentAuditToDB:duplicateCount];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.syncOverlayView dismissActivityView];
                [self.syncOverlayView removeFromSuperview];
                if (!self.saved) {
                    if (duplicateCount == 0) {
                        if (!aggregateSamplesMode) {
                            self.inspectionCount = self.inspectionCount + 1;
                        }
                    } else {
                        self.inspectionCount = self.inspectionCount + duplicateCount;
                    }
                    self.numberOfProductsInspected.text = [NSString stringWithFormat:@"%d", self.inspectionCount];
                    [self.productRatingView.view removeFromSuperview];
                    self.productRatingView = nil;
                    [self calculateSummaryLocal];
                    if (aggregateSamplesMode) {
                       
                        if (self.nextPressed) {
                            self.product = [self.productsArrayForNavigation objectAtIndex:self.indexOfProductsArray + 1];
                            self.indexOfProductsArray = self.indexOfProductsArray + 1;
                            if (self.indexOfProductsArray == [self.productsArrayForNavigation count] - 1) {
                                self.nextProductButton.hidden = YES;
                                self.previousProductButton.hidden = NO;
                            } else {
                                self.nextProductButton.hidden = NO;
                                self.previousProductButton.hidden = NO;
                            }
                        } else {
                            self.product = [self.productsArrayForNavigation objectAtIndex:self.indexOfProductsArray - 1];
                            self.indexOfProductsArray = self.indexOfProductsArray - 1;
                            if (self.indexOfProductsArray == 0) {
                                self.nextProductButton.hidden = NO;
                                self.previousProductButton.hidden = YES;
                            } else {
                                self.nextProductButton.hidden = NO;
                                self.previousProductButton.hidden = NO;
                            }
                        }
                         [self setCurrentSplitGroupId];
                    }
                    [self setupCurrentAudit];
                    [self cameraButtonIconDecide];
                    [self populateRatingsWithPersistentValues:self.ratingResponsesGlobal];
                    self.ratingResponsesGlobal = [[NSArray alloc] init];
                    //not needed - legacy bug
//                    if ([[Inspection sharedInspection] checkForOrderData] && self.inspectionCount == 2) {
//                        [self updateCountOfCases];
//                    }
                    if (aggregateSamplesMode) {
                        //[self setCurrentSplitGroupId];
                        if (self.nextPressed) {
                            [self addProductRatingViewWithAnimationPush];
                        } else {
                            [self addProductRatingViewWithAnimationPop];
                        }
                    } else {
                        //call update collaborative inspections
                        if([CollobarativeInspection isCollaborativeInspectionsEnabled]){
                            [self startCollaborativeInspectionForProduct:(int)self.currentAudit.product.product_id];
                        }
                        [self addProductRatingViewWithAnimationPush];
                    }
                } else {
                    self.saved = NO;
                    [self calculateSummaryLocal];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //[NSThread sleepForTimeInterval:5.0f];
                        if([CollobarativeInspection isCollaborativeInspectionsEnabled]){
                            [self startCollaborativeInspectionForProduct:(int)self.currentAudit.product.product_id];
                        }
                        [Inspection sharedInspection].currentSplitGroupId = @""; //reset split groupid
                        if ([[User sharedUser] checkForRetailInsights]) {
                            InspectionStatusViewControllerRetailViewController *inspectionViewController = [[InspectionStatusViewControllerRetailViewController alloc] initWithNibName:@"InspectionStatusViewControllerRetailViewController" bundle:nil];
                            [self.navigationController pushViewController:inspectionViewController animated:YES];
                        } else {
                            InspectionStatusViewController *inspectionViewController = [[InspectionStatusViewController alloc] initWithNibName:@"InspectionStatusViewController" bundle:nil];
                            [self.navigationController pushViewController:inspectionViewController animated:YES];
                        }
                    });
                }
            });
        });
    }
}

-(void) startCollaborativeInspectionForProduct:(int)productId{
    
    CollobarativeInspection* collobarativeInsp = [Inspection sharedInspection].collobarativeInspection;
    if(!collobarativeInsp) {
        collobarativeInsp = [[CollobarativeInspection alloc]init];
        [Inspection sharedInspection].collobarativeInspection = collobarativeInsp;
    }
    UIWindow *win = [[UIApplication sharedApplication] keyWindow];
    self.syncOverlayView = [[SyncOverlayView alloc] initWithFrame:CGRectMake(0, 0, win.frame.size.width, win.frame.size.height)];
    self.syncOverlayView.headingTitleLabel.text = @"Starting Inspection...";
    [self.syncOverlayView showActivityView];
    [win addSubview:self.syncOverlayView];
    
    [collobarativeInsp startInspectionForProduct:productId inPO:[Inspection sharedInspection].poNumberGlobal withBlock:^(BOOL success) {
        [self.syncOverlayView dismissActivityView];
        [self.syncOverlayView removeFromSuperview];
        
    }];
    
}


-(NSArray*)getAllSavedAudits {
    NSArray *allSavedAudits = [[NSArray alloc]init];
    if ([[Inspection sharedInspection] checkForOrderData]) {
        if ([[Inspection sharedInspection].productGroups count] < 1) {
            [Inspection sharedInspection].productGroups = [[User sharedUser].currentStore getProductGroups];
        }
        NSSet *set;
        NSString *PONumber = [Inspection sharedInspection].poNumberGlobal;
        if((![PONumber  isEqual: @""]) && (PONumber != nil)){
            set = [OrderData getItemNumbersForPONumberSelected];
        }else{
            set = [OrderData getItemNumbersForGRNSelected];
        }
        NSArray *newProductGroupsArray = [[Inspection sharedInspection] filteredProductGroups:set];
        [Inspection sharedInspection].productGroups = newProductGroupsArray;
        allSavedAudits = [[Inspection sharedInspection] getAllSavedAndFakeAuditsForInspection];
    } else
        allSavedAudits = [[Inspection sharedInspection] getAllSavedAuditsForInspection];
    
    return allSavedAudits;
}

//when moving using arrows in an aggregate mode
-(void)setCurrentSplitGroupId {
    NSArray *allSavedAudits = [self getAllSavedAudits];
    for (SavedAudit *saved in allSavedAudits) {
        if (saved.productId == self.product.product_id) {
            [Inspection sharedInspection].currentSplitGroupId = saved.splitGroupId;
            if([[Inspection sharedInspection].currentSplitGroupId length]==0)
                [Inspection sharedInspection].currentSplitGroupId = [DeviceManager getCurrentTimeString];
            NSLog(@"split group id from savedAudit: %@", saved.splitGroupId );
            NSLog(@"[Inspection sharedInspection].currentSplitGroupId: %@", [Inspection sharedInspection].currentSplitGroupId);
        }
    }
}

- (void) calculateSummaryLocal {
    __block Summary *summary = [[Summary alloc] init];
    if (self.countOfCasesEnteredByTheUser <= OrderDataMinimumCount) { // To allow count of cases to zero, change the value for minimumCountForCases to zero else 1.
        self.countOfCasesEnteredByTheUser = [self.orderDataGlobal.QuantityOfCases integerValue];
    }
    summary.inspectionCountOfCases = self.inspectionCountOfCasesEnteredByTheUser;
    summary.totalCountOfCases = self.countOfCasesEnteredByTheUser;
    if(![self isRatingPassDaysRemainingValidation]){
        summary.failedDateValidation = YES;
    }
    //int count = 0;
    FMDatabase *database;
    database = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
    [database open];
    summary = [self calculateSummaryAndSaveToTheTable:summary withDatabase: database];
    [summary updateCountOfCasesInDB:[NSString stringWithFormat:@"%d", self.countOfCasesEnteredByTheUser] withInspectionCount:[NSString stringWithFormat:@"%d", self.inspectionCountOfCasesEnteredByTheUser] withGroupId:[NSString stringWithFormat:@"%d", self.product.group_id] withProductId:[NSString stringWithFormat:@"%d", self.product.product_id] withDatabase:database];
    //cause for error DI-1132
    if ([self.userEnteredInspectionSamples integerValue] > 0) {
        [summary updateNumberOfInspectionsInDB:[self.userEnteredInspectionSamples integerValue] withGroupId:[NSString stringWithFormat:@"%d", self.product.group_id] withAuditMasterID:[Inspection sharedInspection].auditMasterId withProductId:[NSString stringWithFormat:@"%d", self.product.product_id] withSplitGroupId:[Inspection sharedInspection].currentSplitGroupId withDatabase:database];
    }
    if (![summary.inspectionStatus isEqualToString:@""]) {
        [summary updateInspectionStatusInDB:summary.inspectionStatus withGroupId:[NSString stringWithFormat:@"%d", self.product.group_id] withAuditMasterID:[Inspection sharedInspection].auditMasterId withProductId:[NSString stringWithFormat:@"%d", self.product.product_id] withProductGroupId:[NSString stringWithFormat:@"%d", self.product.group_id] withSplitGroupId:[Inspection sharedInspection].currentSplitGroupId withDatabase:database];
    }
    //update validation for days remaining
   /* if(![self isRatingPassDaysRemainingValidation]){
        [summary updateDaysRemainingValidationFailedStatus:YES withGroupId:[NSString stringWithFormat:@"%d", self.product.group_id] withAuditMasterID:[Inspection sharedInspection].auditMasterId withProductId:[NSString stringWithFormat:@"%d", self.product.product_id] withProductGroupId:[NSString stringWithFormat:@"%d", self.product.group_id] withSplitGroupId:[Inspection sharedInspection].currentSplitGroupId withDatabase:database];
    }*/
    [database close];
    self.userEnteredInspectionSamples = 0;
}

-(BOOL) isRatingPassDaysRemainingValidation {
    if ([self.ratingResponsesGlobal count] > 0) {
        for (Rating *rating in self.ratingResponsesGlobal) {
            BOOL isValid = [self.currentAudit validateDaysRemainingMinConditionForRating:rating forProduct:self.product];
            if(!isValid)
                return NO;
        }
    }
    return YES;
}

- (void) updateCountOfCases {
    __block Summary *summary = [[Summary alloc] init];
    if (self.countOfCasesEnteredByTheUser < 1) {
        self.countOfCasesEnteredByTheUser = [self.orderDataGlobal.QuantityOfCases integerValue];
    }
    summary.totalCountOfCases = self.countOfCasesEnteredByTheUser;
    summary.inspectionCountOfCases = self.inspectionCountOfCasesEnteredByTheUser;
    dispatch_queue_t backgroundQueue = dispatch_queue_create("com.mycompany.myqueue", 0);
    dispatch_async(backgroundQueue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            int count = 0;
            FMDatabase *database;
            database = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
            [database open];
            summary = [self calculateSummaryAndSaveToTheTable:summary withDatabase:database];
            count = [[Summary getCountOfCasesFromDB:0 withGroupId:[NSString stringWithFormat:@"%d", self.product.group_id] withProductId:[NSString stringWithFormat:@"%d", self.product.product_id] withSplitGroupId:[Inspection sharedInspection].currentSplitGroupId withDatabase:database] integerValue];
            if (count < 1) {
                [summary updateCountOfCasesInDB:[NSString stringWithFormat:@"%d", self.countOfCasesEnteredByTheUser] withInspectionCount:[NSString stringWithFormat:@"%d", self.inspectionCountOfCasesEnteredByTheUser] withGroupId:[NSString stringWithFormat:@"%d", self.product.group_id] withProductId:[NSString stringWithFormat:@"%d", self.product.product_id] withDatabase:database];
            }
            [database close];
        });
    });
}

- (Summary *) calculateSummaryAndSaveToTheTable: (Summary *) summary withDatabase:(FMDatabase *) database {
    summary.productName = self.product.product_name;
    [summary getSummaryOfAudits:self.product withGroupId:[NSString stringWithFormat:@"%d", self.product.group_id] withSplitGroupId:[Inspection sharedInspection].currentSplitGroupId withDatabase:database];
    return summary;
}

- (BOOL) loadCurentAuditIfPresent {
    BOOL present = NO;
    if (self.currentAudit) {
        present = [self.currentAudit populateFromExisitingAuditInDB:[[Inspection sharedInspection] auditMasterId] withAuditCount:self.inspectionCount withProductID:self.product.product_id withProductName:self.product.product_name withUserEnteredInspectionSamples:[self.userEnteredInspectionSamples integerValue]];
    }
    return present;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"ProductViewController.m - OutOfMemory");
    CrashLogHandler *crashHandler = [[CrashLogHandler alloc]init];
    NSString* deviceName = [DeviceManager getDeviceID];
    NSString* timeStampe = [DeviceManager getCurrentDateTimeWithTimeZone];
    NSString* crashDetails = [NSString stringWithFormat:@"\nDeviceId: %@ \nTime: %@ \nError: didReceiveMemoryWarning() called in ProductViewController",deviceName,timeStampe];
    [crashHandler addToCrashLogs:crashDetails];
}

- (void) saveProcess: (BOOL) savedTouched {
    NSArray *allSavedAudits = [self getAllSavedAudits];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveUtilityView" object:self];
    self.saved = savedTouched;
    self.product.savedAudit.defects = self.productRatingsArray;
    UIWindow *win = [[UIApplication sharedApplication] keyWindow];
    self.syncOverlayView = [[SyncOverlayView alloc] initWithFrame:CGRectMake(0, 0, win.bounds.size.width, win.bounds.size.height)];
    self.syncOverlayView.headingTitleLabel.text = SavingAudits;
    [self.syncOverlayView showActivityView];
    [win addSubview:self.syncOverlayView];
    if (![[Inspection sharedInspection] checkForOrderData]) {
        if (![[User sharedUser] checkForRetailInsights]) {
            if (self.countOfCasesEnteredByTheUser <= OrderDataMinimumCount) {
                if (![self countOfCasesRatingPresentMethod]) {
                    [self showAlertForCountOfCasesEntering];
                } else {
                    [self.productRatingView submitAnswersTouched:self];
                }
            } else {
                [self.productRatingView submitAnswersTouched:self];
            }
        } else {
            [self.productRatingView submitAnswersTouched:self];
        }
    } else {
        [self.productRatingView submitAnswersTouched:self];
    }
}

- (void) saveButtonTouched {
    [self saveProcess:YES];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:self.product.product_id forKey:@"currentProductId"];

    [userDefaults synchronize];
}

- (BOOL) countOfCasesRatingPresentMethod {
    BOOL countOfCasesRatingPresent = NO;
    NSArray *ratings = self.product.ratings;
    for (Rating *rating in ratings) {
        if ([rating.order_data_field isEqualToString:@"QuantityOfCases"]) {
            countOfCasesRatingPresent = YES;
            break;
        }
    }
    return countOfCasesRatingPresent;
}

- (void) showAlertForCountOfCasesEntering {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please enter count of cases."
                                                    message:@""
                                                   delegate:self
                                          cancelButtonTitle:@"Done"
                                          otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textField = [alert textFieldAtIndex:0];
    textField.keyboardType = UIKeyboardTypeNumberPad;
    [alert show];
}


-(void) duplicateButtonTouched {
    // validate the ratings first
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveUtilityView" object:self];
    //NSLog(@"cvjbsfjkvdfkvbdfkjbndjlkdnlj %d", [self.currentAudit getNumberOfSavedAudits]);
    if (self.inspectionCount < [self.currentAudit getNumberOfSavedAudits]) {
        [[[UIAlertView alloc] initWithTitle:@"You cannot duplicate previously reviewed audit." message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
    } else {
        UIWindow *win = [[UIApplication sharedApplication] keyWindow];
        self.syncOverlayView = [[SyncOverlayView alloc] initWithFrame:CGRectMake(0, 0, win.bounds.size.width, win.bounds.size.height)];
        self.syncOverlayView.headingTitleLabel.text = PreparingDuplicateAudits;
        [self.syncOverlayView showActivityView];
        [win addSubview:self.syncOverlayView];
        self.duplicateButtonTouchedButton = YES;
        [self.productRatingView submitAnswersTouched:self];
    }
}
/*
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    // duplicate inspection
    if(alertView.tag==1) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            //NSLog(@"dialog dismissed");
        }
        if (buttonIndex == alertView.firstOtherButtonIndex) {
            //NSLog(@"call save currentauditToDB: duplicateCount");
        }
    }
    }
    */


- (void) changeCameraColor {
    self.cameraButton.tintColor = [UIColor redColor];
}

- (IBAction)nextProductButtonTouched:(id)sender {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"RemoveUtilityView"
     object:self];
    self.nextPressed = YES;
    // do not reset self.savedAudit for distinct mode
    //self.savedAudit = [[SavedAudit alloc] init];
    if (aggregateSamplesMode) {
        self.savedAudit = [[SavedAudit alloc] init];
        [self saveProcess:NO];
    } else {
        UIWindow *win = [[UIApplication sharedApplication] keyWindow];
        self.syncOverlayView = [[SyncOverlayView alloc] initWithFrame:CGRectMake(0, 0, win.bounds.size.width, win.bounds.size.height)];
        self.syncOverlayView.headingTitleLabel.text = SavingAudits;
        [self.syncOverlayView showActivityView];
        [win addSubview:self.syncOverlayView];
        [self.productRatingView submitAnswersTouched:self];
    }
}

-(void)collaborativeConnectionErrorNotification {
        if([CollobarativeInspection isCollaborativeInspectionsEnabled]){
            [self.warningIcon setHidden:NO];
        }
}

-(void) initNotificationCenterListener {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(collaborativeConnectionErrorNotification)
                                                 name:NOTIFICATION_COLLABORATIVE_CONNECTION_ERROR
                                               object:nil];
}

-(void)warningIconTouched {
    UIAlertView* dialog = [[UIAlertView alloc] initWithTitle:@"There was a problem updating collaborative inspection. Please check you internet connection and try again." message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [dialog setAlertViewStyle:UIAlertViewStyleDefault];
    [dialog show];
}

- (IBAction)previousProductButtonTouched:(id)sender {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"RemoveUtilityView"
     object:self];
    self.nextPressed = NO;
    // do not reset self.savedAudit for distinct mode
    //self.savedAudit = [[SavedAudit alloc] init];
    if (aggregateSamplesMode) {
        self.savedAudit = [[SavedAudit alloc] init];
        [self saveProcess:NO];
    } else {
        self.inspectionCount = self.inspectionCount - 1;
        if (self.inspectionCount == 0 &&  [sender isKindOfClass:[UIButton class]]) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            if (self.inspectionCount == 0 && ![sender isKindOfClass:[UIButton class]]) {
                self.inspectionCount = self.inspectionCount + 1;
            }
            self.numberOfProductsInspected.text = [NSString stringWithFormat:@"%d", self.inspectionCount];
            [self.productRatingView.view removeFromSuperview];
            self.productRatingView = nil;
            UIWindow *win = [[UIApplication sharedApplication] keyWindow];
            self.syncOverlayView = [[SyncOverlayView alloc] initWithFrame:CGRectMake(0, 0, win.bounds.size.width, win.bounds.size.height)];
            self.syncOverlayView.headingTitleLabel.text = PreparingRatings;
            [self.syncOverlayView showActivityView];
            [win addSubview:self.syncOverlayView];
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setupCurrentAudit];
                    [self cameraButtonIconDecide];
                    [self addProductRatingViewWithAnimationPop];
                    [self.syncOverlayView dismissActivityView];
                    [self.syncOverlayView removeFromSuperview];
                });
            });
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
}

- (void) setupPhotosAlbum {
    [super setupPhotosAlbum];
//    self.galleryView = [[VerticalGalleryViewController alloc] initWithNibName:@"VerticalGalleryViewController" bundle:nil];
//    self.galleryView.imagesArray = [self.currentAudit.allImages copy];
//    [self.galleryView addContentsToScrollView];
//    [self.navigationController pushViewController:self.galleryView animated:YES];
}

- (void) setupPhotoViewer {
    self.galleryView = [[VerticalGalleryViewController alloc] initWithNibName:@"VerticalGalleryViewController" bundle:nil];
    self.galleryView.imagesArray = self.currentAudit.allImages;
    self.galleryView.productView = YES;
    [self.galleryView addContentsToScrollView];
    [self.navigationController pushViewController:self.galleryView animated:YES];
}

- (void) productInfoButtonTouched {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveUtilityView" object:self];
    //if ([self checkIfManualPresent]) {
        WebviewForProductViewController *webView = [[WebviewForProductViewController alloc] initWithNibName:@"WebviewForProductViewController" bundle:nil];
        webView.product = self.product;
        [self.navigationController pushViewController:webView animated:YES];
   // } else {
     //   [[[UIAlertView alloc] initWithTitle:@"No manual present" message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
    //}

}
//check product quality manual present in DB
- (BOOL) checkIfManualPresent {
    BOOL present = NO;
    FMDatabase *databaseGroupRatings = [[DBManager sharedDBManager] openDatabase:DB_INSIGHTS_DATA];
    FMResultSet *resultsGroupRatings;
    [databaseGroupRatings open];
    resultsGroupRatings = [databaseGroupRatings executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%d", TBL_PRODUCT_QUALITY_MANUAL, COL_ID, self.product.product_id]];
    while ([resultsGroupRatings next]) {
        present = YES;
    }
    [databaseGroupRatings close];
    return present;
}

//get list of URLs for quality manuals - for this product
-(NSArray*)getProductManualURLs{
 //go through each rating
//if star rating - check for defect family and get the manual for that family
    NSMutableArray* productManualURLs = [[NSMutableArray alloc]init];
    if(self.currentAudit.product.ratings){
        for(Rating* rating in self.currentAudit.product.ratings){
            if([rating.type isEqualToString:STAR_RATING] && rating.defect_family_id>0){
               [rating getAllDefects];
            }
        }
    }
    return [productManualURLs copy];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [self.duplicateTextField resignFirstResponder];
}

- (void) cameraButtonTouched {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveUtilityView" object:self];
    [super cameraButtonTouched];
}



@end
