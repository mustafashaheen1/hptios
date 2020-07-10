//
//  ProductSelectAutoCompleteViewController.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/19/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "RetailProductListViewController.h"
#import "ProductViewController.h"
#import "ProductSelectSectionInfo.h"
#import "Product.h"
#import "Store.h"
#import "User.h"
#import "ProgramGroup.h"

#import "SKSTableView.h"
#import "SKSTableViewCell.h"
#import "Inspection.h"
#import "InspectionStatusViewController.h"
#import "OrderData.h"
#import "InspectionStatusViewControllerRetailViewController.h"
#import "HomeScreenViewController.h"
#import "MasterProductRatingManager.h"
#import "ContainerViewController.h"
#import "CollaborativeInspection.h"
#import "CollaborativeAPISaveRequest.h"

#define DEFAULT_ROW_HEIGHT 65
#define HEADER_HEIGHT 48

#pragma mark - TableViewController

static NSString *SectionHeaderViewIdentifier = @"ProductSelectSectionHeader";

@interface RetailProductListViewController ()

@property (nonatomic) IBOutlet ProductSelectSectionHeader *sectionHeaderView;
//@property (nonatomic, strong) UILabel *productNameLabel;
//@property (nonatomic, strong) UILabel *countsLabel;

@end

@implementation RetailProductListViewController

@synthesize table;
@synthesize productGroups;
@synthesize searchResults;
@synthesize productName;
@synthesize productStatuses;
@synthesize openSectionIndex;
@synthesize sectionInfoArray;
@synthesize sectionHeaderTitleArray;
@synthesize dictFruits;
@synthesize searchButton;
@synthesize sectionOpened;
@synthesize productGroupsDidSelectGlobalArray;
@synthesize comingFromContainerScreen;

- (BOOL)canBecomeFirstResponder {
    
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    //[self populateSavedAudits];
    [super viewDidAppear:animated];
}

-(void) populateSavedAudits {
    //if collab inspections - get the status from backend
    if([CollobarativeInspection isCollaborativeInspectionsEnabled])
        [self getLatestCollaborativeInspections];
    else
        [self getAllSavedAudits];
}

-(void) getAllAuditsAndReload {
    dispatch_queue_t backgroundQueue = dispatch_queue_create("com.mycompany.myqueue", 0);
    dispatch_async(backgroundQueue, ^{
        [self getAllSavedAudits];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.table reloadData];
        });
    });
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.showAllProductsTapped = NO;
    self.sectionHeaderTitleArray = [[NSMutableArray alloc] init];
    self.productGroups = [[NSMutableArray alloc] init];
	// Do any additional setup after loading the view.
    self.showAllProductsButton.layer.borderWidth = 2.0;
    self.showAllProductsButton.layer.borderColor = [[UIColor blackColor] CGColor];
    if ([[Inspection sharedInspection] checkForOrderData] || [[User sharedUser] checkForRetailInsights]) {
        self.showAllProductsButton.hidden = YES;
    }
    
}

- (void) getAllSavedAudits {
    if ([[[Inspection sharedInspection] getAllSavedAuditsForInspection]  count] > 0 /*|| [[Inspection sharedInspection] checkForOrderData]*/)  {
        self.productAudits = [[Inspection sharedInspection] getAllSavedAndFakeAuditsForInspection];

    } else {
        self.productAudits = [[NSArray alloc] init];
    }
    [self recalculateSavedAuditsWithDatabase:nil];

    if([[Inspection sharedInspection] checkForOrderData])
        [self addSplitProductGroups];
}

- (void) sortProductGroupByName {
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = @[sort];
    [Inspection sharedInspection].productGroups = [[Inspection sharedInspection].productGroups sortedArrayUsingDescriptors:sortDescriptors];
    //return sortedArray;
}

//add split products to the self.productGroups
-(void)addSplitProductGroups{

    if([self.productAudits count]<=0)
        return;
    //create a map of productId and array of SavedAudits (with different split groups)
    NSMutableDictionary *productIdAndSavedAuditsDictionary = [[NSMutableDictionary alloc]init];
    for(SavedAudit *savedAudit in self.productAudits){
        NSMutableArray* savedAuditsForASplitGroup = [[NSMutableArray alloc]init];
        if([productIdAndSavedAuditsDictionary objectForKey:[NSNumber numberWithInt:savedAudit.productId]]){
            savedAuditsForASplitGroup =[productIdAndSavedAuditsDictionary objectForKey:[NSNumber numberWithInt:savedAudit.productId]];
        }
        [savedAuditsForASplitGroup addObject:savedAudit];
        [productIdAndSavedAuditsDictionary setObject:savedAuditsForASplitGroup forKey:[NSNumber numberWithInt:savedAudit.productId]];
    }
    NSMutableArray* mutableProductGroups = [[NSMutableArray alloc]init];
    //mutableProductGroups = [self.productGroups mutableCopy];
    
    if ([[self.productGroups objectAtIndex:0] isKindOfClass:[ProgramGroup class]]){
        return;
    }
    for(Product *product in self.productGroups){
        if([productIdAndSavedAuditsDictionary objectForKey:[NSNumber numberWithInt:(int)product.product_id]]){
            NSMutableArray* savedAuditsForASplitGroup =[productIdAndSavedAuditsDictionary objectForKey:[NSNumber numberWithInt:(int)product.product_id]];
            for(int i=0; i<[savedAuditsForASplitGroup count]; i++){
                Product *productCopy = [product getCopy];
                productCopy.savedAudit = savedAuditsForASplitGroup[i];
                [mutableProductGroups addObject:productCopy];
            }
        }else{
            Product *productCopy = [product getCopy];
            productCopy.savedAudit = [[SavedAudit alloc]init];
            [mutableProductGroups addObject:productCopy];
        }
    }
    self.productGroups = [mutableProductGroups copy];
    //create copies again
    self.productGroupsArrayForAutoComplete = self.productGroups;
    self.cacheForAllProducts = self.productGroups;
    self.productGroupsDidSelectGlobalArray = self.productGroups;
    
}

-(void)printProductGroups {
    for(Product *product in self.productGroups){
        NSLog(@"\ProductGroups - self.productGroup - productId:%d with SavedAudit cases: %d", product.product_id, product.savedAudit.countOfCases);
    }
}

- (void) recalculateSavedAuditsWithDatabase: (FMDatabase *) databaseLocal {
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
        NSString *queryStringForSavedAudit = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%d' AND %@='%d' AND %@='%@' AND %@='%@'", TBL_SAVED_SUMMARY, COL_PRODUCT_ID, savedAudit.productId, COL_PRODUCT_GROUP_ID, savedAudit.productGroupId, COL_AUDIT_MASTER_ID, [Inspection sharedInspection].auditMasterId,COL_SPLIT_GROUP_ID,savedAudit.splitGroupId];
        resultsGroupRatingsForSavedAudit = [databaseGroupRatings executeQuery:queryStringForSavedAudit];
        while ([resultsGroupRatingsForSavedAudit next]) {
            AuditApiSummary *summary = [[AuditApiSummary alloc] initWithString:[resultsGroupRatingsForSavedAudit stringForColumn:COL_SUMMARY] error:nil];
            savedAudit.inspectionStatus = summary.inspectionStatus;
            NSString *userEnteredInspectionSamples = [resultsGroupRatingsForSavedAudit stringForColumn:COL_USERENTERED_SAMPLES];
            if (userEnteredInspectionSamples && ![userEnteredInspectionSamples isEqualToString:@""]) {
                savedAudit.userEnteredAuditsCount = [userEnteredInspectionSamples integerValue];
            }
            //savedAudit.countOfCases = [[resultsGroupRatingsForSavedAudit stringForColumn:COL_COUNT_OF_CASES] integerValue];
        }
        [savedAuditsLocal addObject:savedAudit];
    }
    if (!databaseLocal) {
        [databaseGroupRatings close];
    }
    self.productAudits = [savedAuditsLocal copy];
}

- (void) loadTheProducts {
    if ([[Inspection sharedInspection].productGroups count] > 0) {
        [self sortProductGroupByName];
        //populate the [Inspection sharedInspection].productGroups
        //for the use-case where first time user select product and immediately click back
        if ([[Inspection sharedInspection] checkForOrderData]) {
            if ([[Inspection sharedInspection].productGroups count] < 1) {
                [Inspection sharedInspection].productGroups = [[User sharedUser].currentStore getProductGroups];
            }
            NSSet *set = [OrderData getItemNumbersForPONumberSelected];
            NSArray *newProductGroupsArray = [[Inspection sharedInspection] filteredProductGroups:set];
            [Inspection sharedInspection].productGroups = newProductGroupsArray;
        }
        
        self.productGroups = [[Inspection sharedInspection].productGroups mutableCopy];
        self.productGroups = [[[User sharedUser].currentStore filterProductsBasedOnContainers:self.productGroups] mutableCopy];
        self.productGroupsArrayForAutoComplete = self.productGroups;
        [Inspection sharedInspection].productGroups = self.productGroupsArrayForAutoComplete;
        if (![[Inspection sharedInspection] checkForOrderData] || [[Inspection sharedInspection] isOtherSelected]) {
            [Inspection sharedInspection].productGroups = [[User sharedUser].currentStore getProductGroups];
           [self sortProductGroupByName];
            self.productGroups = [[Inspection sharedInspection].productGroups mutableCopy];
            self.productGroups = [[[User sharedUser].currentStore filterProductsBasedOnContainers:self.productGroups] mutableCopy];
            self.productGroupsArrayForAutoComplete = self.productGroups;
            [Inspection sharedInspection].productGroups = self.productGroupsArrayForAutoComplete;
        }
    } else {
        [Inspection sharedInspection].productGroups = [[User sharedUser].currentStore getProductGroups];
        [self sortProductGroupByName];
        self.productGroups = [[Inspection sharedInspection].productGroups mutableCopy];
        self.productGroups = [[[User sharedUser].currentStore filterProductsBasedOnContainers:self.productGroups] mutableCopy];
        self.productGroupsArrayForAutoComplete = self.productGroups;
        [Inspection sharedInspection].productGroups = self.productGroupsArrayForAutoComplete;
    }
    self.cacheForAllProducts = self.productGroups;
}


- (void) filterProductGroupsBasedOnTheItemNumber: (NSSet *) itemNumbers {    
    NSArray *newProductGroupsArray = [[Inspection sharedInspection] filteredProductGroups:itemNumbers];
    //if ([newProductGroupsArray count] > 0) {
        self.productGroups = [newProductGroupsArray copy];
    //for order-data only do not show the groups (in programs where multiple products per group)
        if ([[Inspection sharedInspection] checkForOrderData])
            self.productGroups = [[[Inspection sharedInspection] removeProductGroupsIfItsOrderData:self.productGroups] mutableCopy];
        self.productGroupsArrayForAutoComplete = self.productGroups;
        self.productGroupsDidSelectGlobalArray = self.productGroups;
        [Inspection sharedInspection].productGroups = self.productGroups;
        [self.table reloadData];
    //}
}

- (void) setupNavBar {
    [super setupNavBar];
}

- (IBAction)showAllProductsTouched:(id)sender {
    if (!self.showAllProductsTapped) {
        self.showAllProductsButton.backgroundColor = [UIColor colorWithRed:0/255.0 green:134/255.0 blue:199.0/255.0 alpha:1.0];
        [self.showAllProductsButton setTitle:@"Filter Products" forState:UIControlStateNormal];
        self.showAllProductsTapped = YES;
        [self.searchTextField resignFirstResponder];
        [self replaceAllProductsFromCache];
        [self tableViewSetup];
    } else {
        self.showAllProductsButton.backgroundColor = [UIColor colorWithRed:159.0/255.0 green:154.0/255.0 blue:143.0/255.0 alpha:1.0];
        [self.showAllProductsButton setTitle:@"All Products" forState:UIControlStateNormal];
        self.showAllProductsTapped = NO;
        [self.searchTextField resignFirstResponder];
        [self replaceAllProductsFromCacheWithFilteredOnes];
        [self tableViewSetup];
    }
}

- (void) replaceAllProductsFromCache {
    self.productGroups = [self.cacheForAllProducts copy];
    self.productGroupsArrayForAutoComplete = self.productGroups;
    self.productGroupsDidSelectGlobalArray = self.productGroups;
}

- (void) replaceAllProductsFromCacheWithFilteredOnes {
    self.productGroups = [self.cacheForAllFilteredProducts copy];
    self.productGroupsArrayForAutoComplete = self.productGroups;
    self.productGroupsDidSelectGlobalArray = self.productGroups;
}

//TODO - need to refactor this and take out a lot of duplicated code
//move to a single background thread (populating groups and savedaudits)
- (void)viewWillAppear:(BOOL)animated
{
    if ([[Inspection sharedInspection] checkForOrderData]) {
        self.showAllProductsButton.hidden = YES;
    }
    if ([[Inspection sharedInspection] isOtherSelected]) {
        self.showAllProductsButton.hidden = YES;
    }
    [super viewWillAppear:animated];
    UIWindow *win = [[UIApplication sharedApplication] keyWindow];
    self.syncOverlayView = [[SyncOverlayView alloc] initWithFrame:CGRectMake(0, 0, win.bounds.size.width, win.bounds.size.height)];
    self.syncOverlayView.headingTitleLabel.text = @"Loading Products...";
    [self.syncOverlayView showActivityView];
    [win addSubview:self.syncOverlayView];
    
    dispatch_queue_t backgroundQueue = dispatch_queue_create("com.mycompany.myqueue", 0);
    dispatch_async(backgroundQueue, ^{
        [self loadTheProducts];
        if (![[Inspection sharedInspection] isOtherSelected]) {
            self.productGroups = [[[Inspection sharedInspection] filteredProductGroups:[OrderData getAllItemNumbers]] copy];
            self.cacheForAllFilteredProducts = [[[Inspection sharedInspection] filteredProductGroups:[OrderData getAllItemNumbers]] copy];
        }
        if ([[Inspection sharedInspection] checkForOrderData]) {
            self.productGroups = [[[Inspection sharedInspection] removeProductGroupsIfItsOrderData:self.productGroups] mutableCopy];
            self.cacheForAllFilteredProducts = [[Inspection sharedInspection] removeProductGroupsIfItsOrderData:self.productGroups];
        }
        
        //populate the correct savedAudits in non-order data mode and also for splitGroups
        if([[Inspection sharedInspection] isOtherSelected]){
            [self addSplitProductGroups];
        }
        
        self.showAllProductsButton.backgroundColor = [UIColor colorWithRed:159.0/255.0 green:154.0/255.0 blue:143.0/255.0 alpha:1.0];
        [self.showAllProductsButton setTitle:@"All Products" forState:UIControlStateNormal];
        self.showAllProductsTapped = NO;
        self.productGroupsArrayForAutoComplete = self.productGroups;
        self.productGroupsDidSelectGlobalArray = self.productGroups;
        self.pageTitle = @"ProductSelectAutoCompleteViewController";
        if ([self.productAudits count] > 0 || [[[[User sharedUser] currentStore] getListOfAllContainersForTheStore] count] > 0) {
            if ([[Inspection sharedInspection] checkForOrderData]) {
                NSSet *set = [OrderData getItemNumbersForPONumberSelected];
                [self filterProductGroupsBasedOnTheItemNumber:set];
            }
        }
        NSMutableArray *productsForCountOfCases = [NSMutableArray array];
        for (int i=0; i < [self.productGroups count]; i++) {
            if ([[self.productGroups objectAtIndex:i] isKindOfClass:[ProgramGroup class]]) {
                ProgramGroup *programGroup = [self.productGroups objectAtIndex:i];
                [productsForCountOfCases addObjectsFromArray:programGroup.products];
            } else {
                Product *product = [self.productGroups objectAtIndex:i];
                [productsForCountOfCases addObject:product];
            }
        }
        NSMutableDictionary *dictCount = [NSMutableDictionary dictionary];
        NSMutableDictionary *flaggedProducts = [NSMutableDictionary dictionary];
        NSMutableDictionary *flaggedProductMessage = [NSMutableDictionary dictionary];
        NSSet *set = [OrderData getItemNumbersForPONumberSelected];
        BOOL isOrderDataPresent = [OrderData orderDataExistsInDB];
        for (Product *product in productsForCountOfCases) {
            NSString *sku = product.selectedSku;
            
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
            NSString *PONumber = [Inspection sharedInspection].poNumberGlobal;
            if(isOrderDataPresent){
            OrderData *orderData = [OrderData getOrderDataWithPO:PONumber withItemNumber:sku withTime:[[Inspection sharedInspection] dateTimeForOrderData]];
            [dictCount setObject:orderData.QuantityOfCases forKey:[NSString stringWithFormat:@"%d", product.product_id]];
            [flaggedProducts setObject:[NSString stringWithFormat:@"%d", orderData.FlaggedProduct] forKey:[NSString stringWithFormat:@"%ld", product.product_id]];
            [flaggedProductMessage setObject:[NSString stringWithFormat:@"%@", orderData.Message] forKey:[NSString stringWithFormat:@"%d", product.product_id]];
            }
            
        }
        self.countOfCasesDict = dictCount;
        self.flaggedProducts = flaggedProducts;
        self.flaggedProductMessage = flaggedProductMessage;
        //run UI stuff on main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setupNavBar];
            [self.backButton addSubview:self.arrowBackIcon];
            [self.backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
            [self tableViewSetup];
            UINib *sectionHeaderNib = [UINib nibWithNibName:@"ProductSelectSectionHeader" bundle:nil];
            [self.table registerNib:sectionHeaderNib forHeaderFooterViewReuseIdentifier:SectionHeaderViewIdentifier];
             [self.syncOverlayView removeFromSuperview];
        });
    });
    [self populateSavedAudits];
}

- (void) goBack {
    if ([self.productAudits count] > 0) {
        UIAlertView* dialog = [[UIAlertView alloc] initWithTitle:@"This action will cancel the inspection" message:@"You will lose your saved audits" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:@"Cancel Inspection",@"Save Inspection", nil];
        dialog.tag = 0;
        [dialog show];
    } else {
        [super goBack];
    }
}

- (void) checkForContainersAndGoBackElseGoToHomeScreen {
    [self.navigationController popToViewController:self animated:YES]; // cleanup all present view controllers and pop to this controller
    for (int i = 0; i < [self.navigationController.viewControllers count]; i++) {
        //NSLog(@"Controllers are: %@", [self.navigationController.viewControllers objectAtIndex:i]);
        //if container controller present - pop to container view
        if ([[self.navigationController.viewControllers objectAtIndex:i] isKindOfClass:[ContainerViewController class]]) {
            ContainerViewController *containerViewController = (ContainerViewController *) [self.navigationController.viewControllers objectAtIndex:i];
            [self.navigationController popToViewController:containerViewController animated:YES];
        }
        //if home controller present - pop to home view
        if ([[self.navigationController.viewControllers objectAtIndex:i] isKindOfClass:[HomeScreenViewController class]]) {
            HomeScreenViewController *homeScreenViewController = (HomeScreenViewController *) [self.navigationController.viewControllers objectAtIndex:i];
            [self.navigationController popToViewController:homeScreenViewController animated:YES];
        }
        //if containers are available - move to container screen
        NSArray *containers = [[[User sharedUser] currentStore] getListOfAllContainersForTheStore];
        if ([containers count] > 1){
            /*MasterProductRatingManager *masterProductRatingManager = [[MasterProductRatingManager alloc] init];
            masterProductRatingManager.navigationController = self.navigationController;
            [masterProductRatingManager navigateNow];*/
            
            ContainerViewController *containerViewController;
            containerViewController = [[ContainerViewController alloc] initWithNibName:kContainerViewNIBName bundle:nil];
            [self.navigationController pushViewController:containerViewController animated:YES];
        }
    }
   /* Older Implementation - causing the app to go to non-order data mode
    NSArray *containers = [[[User sharedUser] currentStore] getListOfAllContainersForTheStore];
    if ([containers count] < 1) {
        BOOL homePresentPresent = NO;
        for (int i = 0; i < [self.navigationController.viewControllers count]; i++) {
            if ([[self.navigationController.viewControllers objectAtIndex:i] isKindOfClass:[HomeScreenViewController class]]) {
                homePresentPresent = YES;
                HomeScreenViewController *homeScreenViewController = (HomeScreenViewController *) [self.navigationController.viewControllers objectAtIndex:i];
                [self.navigationController popToViewController:homeScreenViewController animated:YES];
            }
        }
        if (!homePresentPresent) {
            HomeScreenViewController *homeScreenViewController = [[HomeScreenViewController alloc] initWithNibName:@"HomeScreenViewController" bundle:nil];
            [self.navigationController pushViewController:homeScreenViewController animated:YES];
        }
    } else {
        BOOL containerPresent = NO;
        for (int i = 0; i < [self.navigationController.viewControllers count]; i++) {
            if ([[self.navigationController.viewControllers objectAtIndex:i] isKindOfClass:[ContainerViewController class]]) {
                containerPresent = YES;
                ContainerViewController *containerViewController = (ContainerViewController *) [self.navigationController.viewControllers objectAtIndex:i];
                [self.navigationController popToViewController:containerViewController animated:YES];
            }
        }
        if (!containerPresent) {
            MasterProductRatingManager *masterProductRatingManager = [[MasterProductRatingManager alloc] init];
            masterProductRatingManager.navigationController = self.navigationController;
            [masterProductRatingManager navigateNow];
        }
    }*/
   
    

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(alertView.tag == 0) {
        // cancel inspection
        if (buttonIndex == alertView.cancelButtonIndex) {
            //NSLog(@"cancelling inspection");
        }
        if (buttonIndex == alertView.firstOtherButtonIndex) {
            //NSLog(@"cancelling inspection");
            [[Inspection sharedInspection] cancelInspection];
            [self checkForContainersAndGoBackElseGoToHomeScreen];
            //[super goBack];
        }
        if (buttonIndex == 2) {
            //NSLog(@"saving inspection");
            [self saveButtonTouched];
            //[super goBack];
        }
    }
    
    if(alertView.tag == 1) {
        if (buttonIndex == 1) {
            if (![[[alertView textFieldAtIndex:0] text] isEqualToString:@""]) {
                [[Inspection sharedInspection] saveInspection:[[alertView textFieldAtIndex:0] text]];
                [self checkForContainersAndGoBackElseGoToHomeScreen];
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Name Cant be Empty" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            }
        }
    }
}

/*!
 *  Save button action. This will popup an alertview asking for an Inspection name if there are more than one audit, else the action will fail.
 */
// rename for the icon (earlier was called -  saveForInspectionStatusTouched)
- (void) saveButtonTouched {
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
        dialog.tag = 1;
        [dialog show];
    } else {
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        UIWindow *win = [[UIApplication sharedApplication] keyWindow];
        [alert showWarning:win.rootViewController title:@"Save failed" subTitle:@"No audits available to save" closeButtonTitle:@"OK" duration:0.0f];
        //[[[UIAlertView alloc] initWithTitle:@"No audits available to save" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }
}



- (void) startSearch {
    if (![[NSString stringWithFormat:@"%@", self.searchTextField.text] isEqualToString:@""] && self.searchTextField.text) {
        [self searchAndRefreshTableViewWithString:self.searchTextField.text];
    } else {
        self.productGroups = [[NSMutableArray alloc] init];
        [self.productGroups addObjectsFromArray:self.productGroupsArrayForAutoComplete];
    }
    self.productGroupsDidSelectGlobalArray = [[NSArray alloc] init];
    self.productGroupsDidSelectGlobalArray = self.productGroups;
}

- (void) tableViewSetup {
    [self.table removeFromSuperview];
    self.table = [[SKSTableView alloc] init];
    self.table.frame = CGRectMake(0, 77, self.view.frame.size.width, self.view.frame.size.height-50);
    if (IS_OS_7_OR_LATER) {
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
        {
            self.table.frame = CGRectMake(0, 77, self.view.frame.size.width, 860);
        }
        if (IS_IPHONE5) {
            self.table.frame = CGRectMake(0, 77, self.view.frame.size.width, self.view.frame.size.height - 80);
        }
        if (IS_IPHONE4) {
            self.table.frame = CGRectMake(0, 77, self.view.frame.size.width, self.view.frame.size.height - 80);
        }
    } else {
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
        {
            self.table.frame = CGRectMake(0, 77, self.view.frame.size.width, 860);
        }
        if (IS_IPHONE5) {
            self.table.frame = CGRectMake(0, 77, self.view.frame.size.width, self.view.frame.size.height - 120);
        }
        if (IS_IPHONE4) {
            self.table.frame = CGRectMake(0, 77, self.view.frame.size.width, self.view.frame.size.height - 210);
        }
    }
    
    [self.table setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self.table setContentInset:UIEdgeInsetsMake(0,0,50,0)];//add space to the bottom
    self.table.SKSTableViewDelegate = self;
    //self.table.bounces = NO;
    //[self.table expandAllRowsAtIndexPaths];
    //self.table.shouldExpandOnlyOneCell = NO;
    [self.view addSubview:self.table];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    [self.table removeFromSuperview];
    self.productGroups = [[NSMutableArray alloc] init];
    [self.productGroups addObjectsFromArray:self.productGroupsArrayForAutoComplete];
    self.productGroupsDidSelectGlobalArray = [[NSArray alloc] init];
    self.productGroupsDidSelectGlobalArray = self.productGroups;
    [self tableViewSetup];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (IBAction)searchButtonTouched:(id)sender {
    [self.searchTextField resignFirstResponder];
    [self startSearch];
    [self tableViewSetup];
}

- (void) searchAndRefreshTableViewWithString: (NSString *) string {
    self.productGroups = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.productGroupsArrayForAutoComplete count]; i++) {
        if ([[self.productGroupsArrayForAutoComplete objectAtIndex:i] isKindOfClass:[ProgramGroup class]]) {
            ProgramGroup *programGroup = [self.productGroupsArrayForAutoComplete objectAtIndex:i];
            NSRange substringRange = [[programGroup.name lowercaseString] rangeOfString:[string lowercaseString]];
            if (substringRange.length != 0) {
                [self.productGroups addObject:programGroup];
            } else {
                for (int i=0; i < [programGroup.products count]; i++) {
                    Product *product = [programGroup.products objectAtIndex:i];
                    NSRange substringRangeProduct = [[product.product_name lowercaseString] rangeOfString:[string lowercaseString]];
                    if (substringRangeProduct.length != 0) {
                        [self.productGroups addObject:programGroup];
                        break;
                    }
                }
            }
        } else {
            Product *product = [self.productGroupsArrayForAutoComplete objectAtIndex:i];
            NSString *productsLowerCaseString = [product.product_name lowercaseString];
            NSString *stringsLowerCaseString = [string lowercaseString];
            NSRange substringRangeProduct = [productsLowerCaseString rangeOfString:stringsLowerCaseString];
            if (substringRangeProduct.length != 0) {
                [self.productGroups addObject:product];
            }
        }
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self startSearch];
    // Do the search...
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.productGroups count];
}

- (NSInteger)tableView:(SKSTableView *)tableView numberOfSubRowsAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[self.productGroups objectAtIndex:indexPath.row] isKindOfClass:[ProgramGroup class]]) {
        ProgramGroup *programGroup = [self.productGroups objectAtIndex:indexPath.row];
        return [programGroup.products count];
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SKSTableViewCell";
    
    SKSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    //if (!cell) {
        cell = [[SKSTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    //}
    
    
    //product name
    UILabel *productNameLabel = [[UILabel alloc ]initWithFrame:CGRectMake(10.0, 0.0, 250.0, 35.0)];
    productNameLabel.textColor = [UIColor blackColor];
    productNameLabel.font = [UIFont fontWithName:@"Helvetica" size:(15.0)];
    productNameLabel.text = @""; //product.product_name;;
    productNameLabel.numberOfLines=0;
    productNameLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [cell addSubview:productNameLabel];
    
    //to get dynamic height
    //however if you reduce the height dynamically then the inspection flags in the row will have issue
    
    /*CGSize size = [productNameLabel.text sizeWithFont:[UIFont fontWithName:@"Helvetica" size:(15.0)] forWidth:250 lineBreakMode:NSLineBreakByWordWrapping];
    CGRect labelFrame = productNameLabel.frame;
    labelFrame.size = size;
    productNameLabel.frame = labelFrame;*/
    
    //details
    UILabel *countsLabel = [[UILabel alloc ]initWithFrame:CGRectMake(10.0, 40.0, 150.0, 15.0)];
    countsLabel.textColor = [UIColor blackColor];
    countsLabel.font = [UIFont fontWithName:@"Helvetica" size:(13.0)];
    countsLabel.numberOfLines=1;
    countsLabel.textColor = [UIColor darkGrayColor];
    [cell addSubview:countsLabel];

    //cell.detailTextLabel.textColor = [UIColor blackColor];
    //cell.textLabel.numberOfLines = 1; // set the numberOfLines
   // cell.textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    if ([[self.productGroups objectAtIndex:indexPath.row] isKindOfClass:[ProgramGroup class]]) {
        ProgramGroup *programGroup = [self.productGroups objectAtIndex:indexPath.row];
       // cell.textLabel.text = programGroup.name;
       productNameLabel.text = programGroup.name;
        if ([[User sharedUser] checkForRetailInsights]) {
           // cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", programGroup.audit_count];
            countsLabel.text =[NSString stringWithFormat:@"%d", programGroup.audit_count];
        }
        cell.expandable = YES;
    } else {
        Product *product = [self.productGroups objectAtIndex:indexPath.row];
        //NSLog(@"indexpath.row %d", product.group_id);
        //cell.textLabel.text = product.product_name;
        productNameLabel.text = product.product_name;
        //cell.textLabel.lineBreakMode = UILineBreakModeTailTruncation;
        if ([[User sharedUser] checkForRetailInsights]) {
            //cell.detailTextLabel.text = [NSString stringWithFormat:@""];
            countsLabel.text =[NSString stringWithFormat:@""];
        } else {
            SavedAudit *savedAuditLocal;
            for (SavedAudit *savedAudit in self.productAudits) {
                if (savedAudit.productGroupId == product.group_id) {
                    if (savedAudit.productId == product.product_id) {
                        savedAuditLocal = savedAudit;
                    }
                }
            }
            if([[Inspection sharedInspection] checkForOrderData] && ![[Inspection sharedInspection].poNumberGlobal isEqualToString:@"None"])
                savedAuditLocal = product.savedAudit; //?? this should work
            NSString *countOfCases = [self.countOfCasesDict objectForKey:[NSString stringWithFormat:@"%d", product.product_id]];
            NSString *isFlaggedProduct = [self.flaggedProducts objectForKey:[NSString stringWithFormat:@"%d", product.product_id]];
            
            int countOfCasesLocal = 0;
            countOfCasesLocal = [countOfCases integerValue];
            if (savedAuditLocal.countOfCases > 0) {
                countOfCasesLocal = savedAuditLocal.countOfCases;
            }
            if (savedAuditLocal) {
                int userEnteredAuditsCount = savedAuditLocal.userEnteredAuditsCount;
                if (userEnteredAuditsCount == 0) {
                    userEnteredAuditsCount = savedAuditLocal.auditsCount;
                }
               // cell.detailTextLabel.text = [NSString stringWithFormat:@"%d/%d", userEnteredAuditsCount, countOfCasesLocal];
                countsLabel.text = [NSString stringWithFormat:@"%d/%d", userEnteredAuditsCount, countOfCasesLocal];
            } else {
               // cell.detailTextLabel.text = [NSString stringWithFormat:@"0/%d", countOfCasesLocal];
                countsLabel.text =[NSString stringWithFormat:@"0/%d", countOfCasesLocal];
            }
            
            //if PO is None then do not show counts text
            if([[Inspection sharedInspection].poNumberGlobal isEqualToString:@"None"]
               && [[User sharedUser].userSelectedVendorName isEqualToString:@"None"]){
                countsLabel.text=@"0/0";
            }
            
            CollobarativeInspection* collobarativeInsp = [Inspection sharedInspection].collobarativeInspection;
            if(collobarativeInsp && [CollobarativeInspection isCollaborativeInspectionsEnabled]){
                int status = (int)[collobarativeInsp getStatusForProduct:product.product_id inPO:[Inspection sharedInspection].poNumberGlobal];
                //NSNumber *number = [collobarativeInsp.productStatusMap objectForKey:[NSNumber numberWithInt:product.product_id ]];
                //int status = [number intValue];
                self.productStatusButton = [[RowSectionButton alloc] initWithFrame:CGRectMake(cell.bounds.size.width-50, 5, 30, 30)];
                if(status == STATUS_STARTED)
                [self.productStatusButton setBackgroundImage:[UIImage imageNamed:@"halfcircle.png"] forState:normal];
                if(status == STATUS_FINSIHED)
                 [self.productStatusButton setBackgroundImage:[UIImage imageNamed:@"circlecheck.png"] forState:normal];
                self.productStatusButton.row = indexPath.row;
                [self.productStatusButton addTarget:self action:@selector(showCollaborativeProductMessage:) forControlEvents:UIControlEventTouchUpInside];
                
                if(status != STATUS_NOT_STARTED)
                [cell addSubview:self.productStatusButton];

            }
            
            if(savedAuditLocal.flaggedProduct || [isFlaggedProduct integerValue]>0){
                //cell.textLabel.textColor = [UIColor redColor];
                productNameLabel.textColor= [UIColor redColor];
                //show flag
                //if(!self.flaggedProductButton)
                self.flaggedProductButton = [[RowSectionButton alloc] initWithFrame:CGRectMake(cell.bounds.size.width-5, 5, 30, 30)];
                [self.flaggedProductButton setBackgroundImage:[UIImage imageNamed:@"redflag.png"] forState:normal];
                self.flaggedProductButton.row = indexPath.row;
                [self.flaggedProductButton addTarget:self action:@selector(showFlaggedProductMessage:) forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:self.flaggedProductButton];
            }
        }
        //cell.textLabel.textColor = [UIColor darkGrayColor];
        //cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:16.0];
        //cell.detailTextLabel.textColor = [UIColor darkGrayColor];
        //cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0];
        cell.expandable = NO;
    }
    
    return cell;
}

- (void) showCollaborativeProductMessage:(RowSectionButton*)sender {
    Product *product = [self.productGroups objectAtIndex:sender.row];
    NSString *flaggedProductMessageToShow = [self.flaggedProductMessage objectForKey:[NSString stringWithFormat:@"%d", product.product_id]];
    NSString* flaggedProductName = product.product_name;
    NSMutableSet* listOfUsersSet = [[Inspection sharedInspection].collobarativeInspection getListOfUsersForProduct:(int)product.product_id inPO:[Inspection sharedInspection].poNumberGlobal];
    NSArray *listOfUsersArray = [listOfUsersSet allObjects];
    NSString *listOfUsers = [listOfUsersArray componentsJoinedByString:@"\n"];
    CollobarativeInspection* collobarativeInsp = [Inspection sharedInspection].collobarativeInspection;
    int status = STATUS_NOT_STARTED;
    if(collobarativeInsp && [CollobarativeInspection isCollaborativeInspectionsEnabled]){
        status = (int)[collobarativeInsp getStatusForProduct:product.product_id inPO:[Inspection sharedInspection].poNumberGlobal];
    }
    /*
    if(status == STATUS_STARTED)
        flaggedProductMessageToShow = [NSString stringWithFormat:@"Started by %@", listOfUsers];
    if(status == STATUS_FINSIHED)
        flaggedProductMessageToShow = [NSString stringWithFormat:@"Finished by %@", listOfUsers];*/
    
    if(status == STATUS_STARTED)
        flaggedProductMessageToShow = [NSString stringWithFormat:@"Inspections for \n%@\n have been started by %@",product.name,listOfUsers];
    if(status == STATUS_FINSIHED)
        flaggedProductMessageToShow = [NSString stringWithFormat:@"Inspections for \n%@\n have been finished by %@",product.name,listOfUsers];
    
    UIAlertView* dialog = [[UIAlertView alloc] initWithTitle:nil message:flaggedProductMessageToShow delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [dialog show];
    
}

- (void) showFlaggedProductMessage:(RowSectionButton*)sender {
    Product *product = [self.productGroups objectAtIndex:sender.row];
    NSString *flaggedProductMessageToShow = [self.flaggedProductMessage objectForKey:[NSString stringWithFormat:@"%d", product.product_id]];
    NSString* flaggedProductName = product.product_name;

    UIAlertView* dialog = [[UIAlertView alloc] initWithTitle:flaggedProductName message:flaggedProductMessageToShow delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [dialog show];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForSubRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"UITableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:(15.0)];
    cell.textLabel.numberOfLines=0;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    if ([[self.productGroups objectAtIndex:indexPath.row] isKindOfClass:[ProgramGroup class]]) {
        ProgramGroup *programGroup = self.productGroups[indexPath.row];
        Product *product = programGroup.products[indexPath.subRow - 1];
        cell.textLabel.text = product.product_name;
        SavedAudit *savedAuditLocal;
        for (SavedAudit *savedAudit in self.productAudits) {
            if (savedAudit.productGroupId == product.group_id) {
                if (savedAudit.productId == product.product_id) {
                    savedAuditLocal = savedAudit;
                }
            }
        }
        if([[Inspection sharedInspection]checkForOrderData])
            savedAuditLocal = product.savedAudit;
        
       /* NSArray *countOfCasesArray = [self.countOfCasesDict allKeysForObject:product];
        int countOfCasesLocal = 0;
        NSString *stringCountOfCases = [countOfCasesArray count] > 0 ? [countOfCasesArray objectAtIndex:0]: @"0";
        countOfCasesLocal = [stringCountOfCases integerValue];
        
        if (savedAuditLocal.countOfCases > 0) {
            countOfCasesLocal = savedAuditLocal.countOfCases;
        }
        if (savedAuditLocal) {
            int userEnteredAuditsCount = savedAuditLocal.userEnteredAuditsCount;
            if (userEnteredAuditsCount == 0) {
                userEnteredAuditsCount = savedAuditLocal.auditsCount;
            }
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d/%d", userEnteredAuditsCount, countOfCasesLocal];
        } else {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"0/%d", countOfCasesLocal];
        }*/
        
        
        
        NSString *countOfCases = [self.countOfCasesDict objectForKey:[NSString stringWithFormat:@"%d", product.product_id]];
        int countOfCasesLocal = 0;
        countOfCasesLocal = [countOfCases integerValue];
        if (savedAuditLocal.countOfCases > 0) {
            countOfCasesLocal = savedAuditLocal.countOfCases;
        }
        if (savedAuditLocal) {
            int userEnteredAuditsCount = savedAuditLocal.userEnteredAuditsCount;
            if (userEnteredAuditsCount == 0) {
                userEnteredAuditsCount = savedAuditLocal.auditsCount;
            }
            // cell.detailTextLabel.text = [NSString stringWithFormat:@"%d/%d", userEnteredAuditsCount, countOfCasesLocal];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d/%d", userEnteredAuditsCount, countOfCasesLocal];
        } else {
            // cell.detailTextLabel.text = [NSString stringWithFormat:@"0/%d", countOfCasesLocal];
            cell.detailTextLabel.text =[NSString stringWithFormat:@"0/%d", countOfCasesLocal];
        }
        
        if ([[User sharedUser] checkForRetailInsights]) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@""];
        }

    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (CGFloat)tableView:(SKSTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return DEFAULT_ROW_HEIGHT;
}


- (CGFloat)tableView:(SKSTableView *)tableView heightForSubRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Returns 60.0 points for all subrows.
    return 60.0f;
}

- (CGFloat)tableView:(SKSTableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"Section: %d, Row:%d", indexPath.section, indexPath.row);

//    SKSTableViewCell *cell = (SKSTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
//    if ([[self.productGroupsDidSelectGlobalArray objectAtIndex:indexPath.row] isKindOfClass:[ProgramGroup class]]) {
//        if (!cell.isExpanded) {
//            self.productGroupsDidSelectGlobalArray = [self prepareArrayForDidSelect:self.productGroupsDidSelectGlobalArray withProgramGroup:[self.productGroupsDidSelectGlobalArray objectAtIndex:indexPath.row] withRow:indexPath.row withClosed:NO];
//        } else {
//            self.productGroupsDidSelectGlobalArray = [self prepareArrayForDidSelect:self.productGroupsDidSelectGlobalArray withProgramGroup:[self.productGroupsDidSelectGlobalArray objectAtIndex:indexPath.row] withRow:indexPath.row withClosed:YES];
//        }
//    } else {
//        self.productGroupsDidSelectGlobalArray = [self prepareArrayForDidSelect:self.productGroupsDidSelectGlobalArray withProgramGroup:nil withRow:indexPath.row withClosed:NO];
//    }
//    if ([[self.productGroupsDidSelectGlobalArray objectAtIndex:indexPath.row] isKindOfClass:[Product class]]) {
//        Product *product = [self.productGroupsDidSelectGlobalArray objectAtIndex:indexPath.row];
//        ProductViewController *productViewController = [[ProductViewController alloc] initWithNibName:@"ProductViewController" bundle:nil];
//        productViewController.product = product;
//        for (SavedAudit *savedAudit in self.productAudits) {
//            if (savedAudit.productGroupId == product.group_id) {
//                if (savedAudit.productId == savedAudit.productId) {
//                    productViewController.savedAudit = savedAudit;
//                }
//            }
//        }
//        [self.navigationController pushViewController:productViewController animated:YES];
//    }

    if ([[self.productGroupsDidSelectGlobalArray objectAtIndex:indexPath.row] isKindOfClass:[Product class]]) {
        Product *product = [self.productGroupsDidSelectGlobalArray objectAtIndex:indexPath.row];
        [Inspection sharedInspection].currentSplitGroupId = product.savedAudit.splitGroupId; //set split groupId
        self.productSelectedForGlobalSelection = product;
        if ([product.skus count] > 0) {
            self.poNumbersArrayForSelectedProduct = [self checkForMultiplePOsForProduct:[product.skus lastObject]];
        }
        if ([self.poNumbersArrayForSelectedProduct count] > 0) {
           
            if ((![[Inspection sharedInspection] checkForOrderData] && ![[Inspection sharedInspection] isOtherSelected]) ||  ([[Inspection sharedInspection].poNumberGlobal isEqualToString:@"None"])) {
               // NSLog(@"sjsf %@", self.productAudits);
                if ([self.productAudits count] < 1) {
                    [self selectPOs:self.poNumbersArrayForSelectedProduct withTitle:@"Select PO"];
                } else {
                    [self navigateToProductView:product];
                }
            } else {
                [self navigateToProductView:product];
            }
        } else {
            //[self selectPOs:self.poNumbersArrayForSelectedProduct withTitle:@"Select PO"];
            if ([self.poNumbersArrayForSelectedProduct count] > 0) {
                if (![[Inspection sharedInspection] checkForOrderData] && ![[Inspection sharedInspection] isOtherSelected]) {
                    if ([self.productAudits count] < 1) {
                        OrderData *ord = [self.poNumbersArrayForSelectedProduct objectAtIndex:0];
                        //[[Inspection sharedInspection] initInspection];
                        [[Inspection sharedInspection] savePONumberToInspection:ord.PONumber];
                        [User sharedUser].userSelectedVendorName = ord.VendorName;
                        [[Inspection sharedInspection] checkForPONumberAndSaveItInUserDefaults];
                        [Inspection sharedInspection].dateTimeForOrderData = ord.ExpectedDeliveryDateTime;
                        [NSUserDefaultsManager saveObjectToUserDefaults:ord.ExpectedDeliveryDateTime withKey:OrderDataDateTimeSet];

                        
                    }
                }
            }
            [self navigateToProductView:product];
        }
    }
}

-(BOOL) isPONumberSelected {
    NSString* po = [Inspection sharedInspection].poNumberGlobal;
    if(!po || po.length==0)
        return NO;
    
    return YES;
        
}

- (void) navigateToProductView: (Product *) product {
    ProductViewController *productViewController = [[ProductViewController alloc] initWithNibName:@"ProductViewController" bundle:nil];
    productViewController.product = product;
    productViewController.parentView = defineProductSelectViewController;
   /* for (SavedAudit *savedAudit in self.productAudits) {
        if (savedAudit.productGroupId == product.group_id) {
            if (savedAudit.productId == product.product_id) {
                if([savedAudit.splitGroupId length]==0) {
                    savedAudit.splitGroupId = [DeviceManager getCurrentTimeString];
                }
                [Inspection sharedInspection].currentSplitGroupId = savedAudit.splitGroupId;
                productViewController.savedAudit = savedAudit;
            }
        }
    }*/
    if([self.productAudits count]>0 && [Inspection sharedInspection].checkForOrderData){
        [Inspection sharedInspection].currentSplitGroupId = product.savedAudit.splitGroupId;
        productViewController.savedAudit = product.savedAudit;
    }

    
    //init split groupID if empty
    if([[Inspection sharedInspection].currentSplitGroupId length]==0)
        [Inspection sharedInspection].currentSplitGroupId = [DeviceManager getCurrentTimeString];
    
    [self removeBackFromProductSelectMethod];
    
    
    if([CollobarativeInspection isCollaborativeInspectionsEnabled]){
        [self startCollaborativeInspectionForProduct:(int)productViewController.product.product_id withViewController:productViewController];
    }else
        [self.navigationController pushViewController:productViewController animated:YES];
}

-(void) startCollaborativeInspectionForProduct:(int)productId withViewController:(ViewController*)productViewController{

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
        [self.navigationController pushViewController:productViewController animated:YES];
    }];
}

-(void) getLatestCollaborativeInspections {
    [self.syncOverlayView dismissActivityView];
    [self.syncOverlayView removeFromSuperview];
    UIWindow *win = [[UIApplication sharedApplication] keyWindow];
    self.syncOverlayView = [[SyncOverlayView alloc] initWithFrame:CGRectMake(0, 0, win.frame.size.width, win.frame.size.height)];
    self.syncOverlayView.headingTitleLabel.text = @"Updating Inspection...";
    [self.syncOverlayView showActivityView];
    [win addSubview:self.syncOverlayView];
    CollobarativeInspection* collobarativeInsp = [Inspection sharedInspection].collobarativeInspection;
    if(!collobarativeInsp) {
        collobarativeInsp = [[CollobarativeInspection alloc]init];
        [Inspection sharedInspection].collobarativeInspection = collobarativeInsp;
    }
    [collobarativeInsp initCollabInspectionsForPO:[Inspection sharedInspection].poNumberGlobal withBlock:^(BOOL success) {
        [self.syncOverlayView dismissActivityView];
        [self.syncOverlayView removeFromSuperview];
        [self getAllAuditsAndReload]; //continue with the usual stuff
    }];
}

- (void) selectPOs: (NSArray *) comboItemsLocal withTitle: (NSString *) title {
    CGFloat xWidth = self.view.frame.size.width - 20.0f;
    CGFloat yHeight = popupDefaultHeight;
    if ([comboItemsLocal count] < 5) {
        int heightAfterCalculation = [comboItemsLocal count] * 60.0f + 60.0f; //for other
        heightAfterCalculation = heightAfterCalculation + 40;
        yHeight = heightAfterCalculation;
    }
    CGFloat yOffset = (self.view.frame.size.height - yHeight)/2.0f;
    self.poplistview = [[UIPopoverListView alloc] initWithFrame:CGRectMake(10, yOffset, xWidth, yHeight)];
    self.poplistview.delegate = self;
    self.poplistview.datasource = self;
    self.poplistview.listView.scrollEnabled = TRUE;
    [self.poplistview setTitle:title];
    [self.poplistview show];
}

#pragma mark - UIPopoverListViewDataSource

- (UITableViewCell *)popoverListView:(UIPopoverListView *)popoverListView
                    cellForIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    
    if(indexPath.row <[self.poNumbersArrayForSelectedProduct count]){
        OrderData *orderData = [self.poNumbersArrayForSelectedProduct objectAtIndex:indexPath.row];
        if([orderData.ItemName isEqualToString:@"DATE"]){
            cell.textLabel.numberOfLines = 1;
            cell.textLabel.text = [NSString stringWithFormat:@"%@",orderData.ExpectedDeliveryDateTime];
            cell.backgroundColor = [UIColor lightGrayColor];
        }else{
            cell.textLabel.numberOfLines = 2;
            cell.textLabel.text = [NSString stringWithFormat:@"%@ \nPO: %@ - %d Cases",orderData.VendorName, orderData.PONumber, [orderData.countForPopup intValue] ];
        }
    }
    else
        cell.textLabel.text = @"Other PO";
    return cell;
}

- (NSInteger)popoverListView:(UIPopoverListView *)popoverListView
       numberOfRowsInSection:(NSInteger)section
{
    return [self.poNumbersArrayForSelectedProduct count]+1; //for other
}

#pragma mark - UIPopoverListViewDelegate

- (void)popoverListView:(UIPopoverListView *)popoverListView
     didSelectIndexPath:(NSIndexPath *)indexPath
{
    BOOL isPONone =[[Inspection sharedInspection].poNumberGlobal isEqualToString:@"None"];
    BOOL isVendorNone = [[User sharedUser].userSelectedVendorName isEqualToString:@"None"];
    
    if(indexPath.row < [self.poNumbersArrayForSelectedProduct count]){
        OrderData *orderData = [self.poNumbersArrayForSelectedProduct objectAtIndex:indexPath.row];
        //NSLog(@"ponumber selected %@", orderData.PONumber);
        if([orderData.ItemName isEqualToString:@"DATE"])
            return;
        
        if ((![[Inspection sharedInspection] checkForOrderData] && ![[Inspection sharedInspection] isOtherSelected])
            || isPONone || isVendorNone) {
            if ([self.productAudits count] < 1) {
                //[[Inspection sharedInspection] initInspection];
                //set exepectedDeliveryDateTime for this inspection
                if(isPONone)
                    [Inspection sharedInspection].poNumberGlobal = orderData.PONumber;
                if(isVendorNone)
                    [User sharedUser].userSelectedVendorName = orderData.VendorName;
                
                [Inspection sharedInspection].dateTimeForOrderData = orderData.ExpectedDeliveryDateTime;
                [NSUserDefaultsManager saveObjectToUserDefaults:orderData.ExpectedDeliveryDateTime withKey:OrderDataDateTimeSet];
                [[Inspection sharedInspection] savePONumberToInspection:orderData.PONumber];
                [User sharedUser].userSelectedVendorName = orderData.VendorName;
                [NSUserDefaultsManager saveObjectToUserDefaults:orderData.VendorName withKey:VendorNameSelected];
                [[Inspection sharedInspection] checkForPONumberAndSaveItInUserDefaults];
                [[Inspection sharedInspection] checkForVendorNameAndSaveItInUserDefaults];
            }
        }
        //if user selects 'Other PO' then start non-orderdata inspections
    }else if(isPONone || isVendorNone){
            [Inspection sharedInspection].poNumberGlobal = @"";
            [User sharedUser].userSelectedVendorName = @"";
            [[Inspection sharedInspection] savePONumberToInspection:@""];
            [User sharedUser].userSelectedVendorName = @"";
            [NSUserDefaultsManager saveObjectToUserDefaults:@"" withKey:VendorNameSelected];
            [[Inspection sharedInspection] checkForPONumberAndSaveItInUserDefaults];
            [[Inspection sharedInspection] checkForVendorNameAndSaveItInUserDefaults];
    }
    [self navigateToProductView:self.productSelectedForGlobalSelection];
}

- (void)popoverListViewCancel:(UIPopoverListView *)popoverListView {
    NSLog(@"ponumber date for the inspection");
}

- (CGFloat)popoverListView:(UIPopoverListView *)popoverListView
   heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row < [self.poNumbersArrayForSelectedProduct count]){
        OrderData *orderData = [self.poNumbersArrayForSelectedProduct objectAtIndex:indexPath.row];
        //NSLog(@"ponumber selected %@", orderData.PONumber);
        if([orderData.ItemName isEqualToString:@"DATE"])
            return 30.0f;;
    }
    return 60.0f;
}


- (NSArray *) checkForMultiplePOsForProduct: (NSString *) itemNumber {
    NSArray *orderDataArray = [OrderData getOrderDataForItemNumber:itemNumber];
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"ExpectedDeliveryDateTime" ascending:NO];
    NSMutableArray* sortedOrderDataArrayByDates = [orderDataArray mutableCopy];
    [sortedOrderDataArrayByDates sortUsingDescriptors:[NSArray arrayWithObject:sorter]];
    
    //NSArray* arr = [arrayCopy valueForKeyPath:@"@distinctUnionOfObjects.ExpectedDeliveryDateTime"];
    //NSMutableDictionary* sectionNumberAndOrderDataByDates = [[NSMutableDictionary alloc]init];
    
    //Since library does not support sections, add a fictitious date row
    NSMutableArray* orderDataArrayWithDates = [[NSMutableArray alloc]init];
    NSString* currentExpectedDeliveryDate = @"";
    for(OrderData *orderData in sortedOrderDataArrayByDates){
        if(![orderData.ExpectedDeliveryDateTime isEqualToString:currentExpectedDeliveryDate]){
            OrderData *od = [[OrderData alloc]init];
            od.ItemName = @"DATE";//to identify the date row in UI
            od.ExpectedDeliveryDateTime = orderData.ExpectedDeliveryDateTime;
            currentExpectedDeliveryDate = orderData.ExpectedDeliveryDateTime;
            [orderDataArrayWithDates addObject:od];
            [orderDataArrayWithDates addObject:orderData];
        }else{
            [orderDataArrayWithDates addObject:orderData];
        }
    }
    return [orderDataArrayWithDates copy];
}

- (void)tableView:(SKSTableView *)tableView didSelectSubRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"Section: %d, Row:%d, Subrow:%d", indexPath.section, indexPath.row, indexPath.subRow);
    
    if ([[self.productGroupsDidSelectGlobalArray objectAtIndex:indexPath.row] isKindOfClass:[ProgramGroup class]]) {
        ProgramGroup *prg = [self.productGroupsDidSelectGlobalArray objectAtIndex:indexPath.row];
        if ([[prg.products objectAtIndex:indexPath.subRow-1] isKindOfClass:[Product class]]) {
            Product *product = [prg.products objectAtIndex:indexPath.subRow-1];
            self.productSelectedForGlobalSelection = product;
            if ([product.skus count] > 0) {
                self.poNumbersArrayForSelectedProduct = [self checkForMultiplePOsForProduct:[product.skus lastObject]];
            }
            if ([self.poNumbersArrayForSelectedProduct count] > 0) {
                if (![[Inspection sharedInspection] checkForOrderData] && ![[Inspection sharedInspection] isOtherSelected]) {
                    if ([self.productAudits count] < 1) {
                        [self selectPOs:self.poNumbersArrayForSelectedProduct withTitle:@"Select PO"];
                    } else {
                        [self navigateToProductView:product];
                    }
                } else {
                    [self navigateToProductView:product];
                }
            } else {
                if ([self.poNumbersArrayForSelectedProduct count] > 0) {
                    if (![[Inspection sharedInspection] checkForOrderData] && ![[Inspection sharedInspection] isOtherSelected]) {
                        if ([self.productAudits count] < 1) {
                            OrderData *ord = [self.poNumbersArrayForSelectedProduct objectAtIndex:0];
                            //set exepectedDeliveryDateTime for this inspection
                            [Inspection sharedInspection].dateTimeForOrderData = ord.ExpectedDeliveryDateTime;
                            [NSUserDefaultsManager saveObjectToUserDefaults:ord.ExpectedDeliveryDateTime withKey:OrderDataDateTimeSet];
                            [[Inspection sharedInspection] savePONumberToInspection:ord.PONumber];
                            [User sharedUser].userSelectedVendorName = ord.VendorName;
                            [[Inspection sharedInspection] checkForPONumberAndSaveItInUserDefaults];
                        }
                    }
                }
                [self navigateToProductView:product];
            }
        }
    }

}

- (void) removeBackFromProductSelectMethod {
    [Inspection sharedInspection].removeBackFromProductSelect = YES;
    [User sharedUser].temporaryPONumberFromUserClass = @"";
}


- (NSArray *) prepareArrayForDidSelect: (NSArray *) productGroupsLocal withProgramGroup:(ProgramGroup *) programGroup withRow:(int)row withClosed: (BOOL) closed {
    NSMutableArray *prepareArrayMutable = [[NSMutableArray alloc] initWithArray:productGroupsLocal];
    if ([programGroup isKindOfClass:[ProgramGroup class]]) {
        for (int i=0; i < [programGroup.products count]; i++) {
            if (!closed) {
                [prepareArrayMutable insertObject:[programGroup.products objectAtIndex:i] atIndex:row+i+1];
            } else {
                [prepareArrayMutable removeObject:[programGroup.products objectAtIndex:i]];
            }
        }
    } else {
        return productGroupsLocal;
    }
    return [prepareArrayMutable copy];
}

- (void) listButtonTouched {
    [self removeBackFromProductSelectMethod];
    if ([[User sharedUser] checkForRetailInsights]) {
        InspectionStatusViewControllerRetailViewController *inspectionViewController = [[InspectionStatusViewControllerRetailViewController alloc] initWithNibName:@"InspectionStatusViewControllerRetailViewController" bundle:nil];
        [self.navigationController pushViewController:inspectionViewController animated:YES];
    } else {
        InspectionStatusViewController *inspectionViewController = [[InspectionStatusViewController alloc] initWithNibName:@"InspectionStatusViewController" bundle:nil];
        [self.navigationController pushViewController:inspectionViewController animated:YES];
    }
}


@end
