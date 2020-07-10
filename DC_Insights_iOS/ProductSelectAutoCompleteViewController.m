//
//  ProductSelectAutoCompleteViewController.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/19/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "ProductSelectAutoCompleteViewController.h"
#import "ProductViewController.h"
#import "ApplyToAllViewController.h"
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
#import "ProductListItem.h"
#import "ProductListItemGroup.h"
#import "ProductListManager.h"
#import "FlaggedMessage.h"


#define DEFAULT_ROW_HEIGHT 65
#define HEADER_HEIGHT 48

#pragma mark - TableViewController

static NSString *SectionHeaderViewIdentifier = @"ProductSelectSectionHeader";

@interface ProductSelectAutoCompleteViewController ()

@property (nonatomic) IBOutlet ProductSelectSectionHeader *sectionHeaderView;
//@property (nonatomic, strong) UILabel *productNameLabel;
//@property (nonatomic, strong) UILabel *countsLabel;

@end

@implementation ProductSelectAutoCompleteViewController

@synthesize table;
@synthesize productGroups;
@synthesize searchResults;
@synthesize productName;
@synthesize productStatuses;
//@synthesize openSectionIndex;
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
        self.productGroups = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)initializeProductList:(BOOL)allProducts
{
//    if(![Inspection sharedInspection].dcInspection)
//        [Inspection sharedInspection].dcInspection = [[DCInspection alloc]init];
    
    ProductListManager *productListManager = [[ProductListManager alloc]init];
    
    dispatch_queue_t loadingQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    __weak ProductSelectAutoCompleteViewController *vc = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showLoadingScreenWithText:@"Loading Products..."];
    });
    
    dispatch_async(loadingQueue, ^{
        NSMutableArray* array = [productListManager getProductsList:allProducts];
        [self initializeCacheWithProductGroups:array];
        //load products
        if([CollobarativeInspection isCollaborativeInspectionsEnabled]){
            [vc getLatestCollaborativeInspectionsWithBlock:^(BOOL success) {
                //DI-2912 - collaborative enabled only for order data inspections
                if ([[Inspection sharedInspection] checkForOrderData] &&
                    ![[Inspection sharedInspection] isOtherSelected] &&
                    ![[Inspection sharedInspection] isNoneSelectedForPOSupplier] )
                [productListManager populateCollaborativeInspectionDataInProductList:array];
                //dismiss loading and reload
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self reloadTable];
                });
            }];
        }else{
            /*NSMutableArray* array = [productListManager getProductsList:allProducts];
            [self initializeCacheWithProductGroups:array];*/
            
            //dismiss loading and reload
            dispatch_async(dispatch_get_main_queue(), ^{
                [self reloadTable];
            });
        }
    });
}

-(void)reloadTable
{
    [self dismissLoadingScreen];
    [self tableViewSetup];
    UINib *sectionHeaderNib = [UINib nibWithNibName:@"ProductSelectSectionHeader" bundle:nil];
    [self.table registerNib:sectionHeaderNib forHeaderFooterViewReuseIdentifier:SectionHeaderViewIdentifier];
    //[self.table refreshData];
    if(self.table)
        [self.table refreshData];
}

-(void)initializeCacheWithProductGroups:(NSMutableArray*)productGroups
{
    self.productGroups = productGroups;
    self.productGroupsArrayForAutoComplete = self.productGroups;
    self.cacheForAllProducts = self.productGroups;
    self.productGroupsDidSelectGlobalArray = self.productGroups;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //init ViewModel
    if(!self.viewModel)
        self.viewModel = [[ProductSelectViewModel alloc]init];
    
    self.showAllProductsTapped = NO;
    self.applyToAllButton.hidden = YES;
    self.sectionHeaderTitleArray = [[NSMutableArray alloc] init];
    self.productGroups = [[NSMutableArray alloc] init];
	// Do any additional setup after loading the view.
    self.showAllProductsButton.layer.borderWidth = 2.0;
    self.showAllProductsButton.layer.borderColor = [[UIColor blackColor] CGColor];
    if ([[Inspection sharedInspection] checkForOrderData]
        || [[User sharedUser] checkForRetailInsights]
        || [[Inspection sharedInspection] isOtherSelected]
        /*|| [[Inspection sharedInspection] isNoneSelectedForPOSupplier]*/) //DI-3034
    {
        self.showAllProductsButton.hidden = YES;
    }
    if([[Inspection sharedInspection] isNoneSelectedForPOSupplier])
        self.showAllProductsButton.hidden = NO;
    
    if ([[Inspection sharedInspection] checkForOrderData]){
        if(self.viewModel.isApplyToAllActive)
            self.applyToAllButton.hidden = NO;
    }
        [self initNotificationCenterListener];
        //self.warningIcon.hidden = YES;
}

-(void)collaborativeConnectionErrorNotification {
    if([CollobarativeInspection isCollaborativeInspectionsEnabled]){
        [self updateProductListNavBar:YES];
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

- (void) setupNavBar {
    [super setupNavBar];
}

- (IBAction)applyToAllButtonTouched:(id)sender {
    if(self.viewModel.isApplyToAllActive){
        //show apply to all dialog view
        ApplyToAllViewController *applyToAllViewController = [[ApplyToAllViewController alloc] initWithNibName:@"ApplyToAllViewController" bundle:nil];
        
        applyToAllViewController.parentView = defineProductSelectViewController;
        applyToAllViewController.viewModel.allProductList = self.productGroups;
            [self.navigationController pushViewController:applyToAllViewController animated:YES];

        
        
    }
}

-(void) applyToAllSaved {
    [self goBackToHomeScreen];
}

- (IBAction)showAllProductsTouched:(id)sender {
    if (!self.showAllProductsTapped) {
        self.showAllProductsButton.backgroundColor = [UIColor colorWithRed:0/255.0 green:134/255.0 blue:199.0/255.0 alpha:1.0];
        [self.showAllProductsButton setTitle:@"Filter Products" forState:UIControlStateNormal];
        self.showAllProductsTapped = YES;
        [self.searchTextField resignFirstResponder];
        [self initializeProductList:YES];
        //[self replaceAllProductsFromCache];
        [self tableViewSetup];
    } else {
        self.showAllProductsButton.backgroundColor = [UIColor colorWithRed:159.0/255.0 green:154.0/255.0 blue:143.0/255.0 alpha:1.0];
        [self.showAllProductsButton setTitle:@"All Products" forState:UIControlStateNormal];
        self.showAllProductsTapped = NO;
        [self.searchTextField resignFirstResponder];
        [self initializeProductList:NO];
        //[self replaceAllProductsFromCacheWithFilteredOnes];
        [self tableViewSetup];
    }
}
/*
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
*/
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self resetSearchBox];
    [self initializeProductList:NO];
    
    //view setup
    self.pageTitle = @"ProductSelectAutoCompleteViewController";
    self.showAllProductsButton.backgroundColor = [UIColor colorWithRed:159.0/255.0 green:154.0/255.0 blue:143.0/255.0 alpha:1.0];
    [self.showAllProductsButton setTitle:@"All Products" forState:UIControlStateNormal];
    self.showAllProductsTapped = NO;
    
    [self setupNavBar];
    [self.backButton addSubview:self.arrowBackIcon];
    [self.backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
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

-(void)resetSearchBox
{
    [self.searchTextField setText:@""];
    [self.searchTextField resignFirstResponder];
}

//take user to home screen
-(void)goBackToHomeScreen {
    [self.navigationController popToViewController:self animated:YES];
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
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(alertView.tag == 0) {
        // cancel inspection
        if (buttonIndex == alertView.cancelButtonIndex) {
            //NSLog(@"cancelling inspection");
        }
        if (buttonIndex == alertView.firstOtherButtonIndex) {
            [[Inspection sharedInspection] cancelInspection];
            [self goBackToHomeScreen];
        }
        if (buttonIndex == 2) {
            [self saveButtonTouched];
        }
    }
    
    if(alertView.tag == 1) {
        if (buttonIndex == 1) {
            if (![[[alertView textFieldAtIndex:0] text] isEqualToString:@""]) {
                [[Inspection sharedInspection] saveInspection:[[alertView textFieldAtIndex:0] text]];
                [self goBackToHomeScreen];
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
        if ([[self.productGroupsArrayForAutoComplete objectAtIndex:i] isKindOfClass:[ProductListItemGroup class]]) {
            ProductListItemGroup *programGroup = [self.productGroupsArrayForAutoComplete objectAtIndex:i];
            NSRange substringRange = [[programGroup.name lowercaseString] rangeOfString:[string lowercaseString]];
            if (substringRange.length != 0) {
                [self.productGroups addObject:programGroup];
            } else {
                for (int j=0; j < [programGroup.productListItemArray count]; j++) {
                    ProductListItem *product = [programGroup.productListItemArray objectAtIndex:j];
                    NSRange substringRangeProduct = [[product.product.name lowercaseString] rangeOfString:[string lowercaseString]];
                    if (substringRangeProduct.length != 0) {
                        ProductListItemGroup *tempProgramGroup = [[ProductListItemGroup alloc] init];
                        tempProgramGroup.name = programGroup.name;
                        tempProgramGroup.productListItemArray = [[NSMutableArray alloc] init];
                        for(ProductListItem *item in programGroup.productListItemArray){
                            [tempProgramGroup.productListItemArray addObject:item];
                        }
                        [tempProgramGroup.productListItemArray removeAllObjects];
                        [tempProgramGroup.productListItemArray addObject:product];
                        [self.productGroups addObject:tempProgramGroup];
                        
                        break;
                    }
                }
            }
        } else {
            ProductListItem *product = [self.productGroupsArrayForAutoComplete objectAtIndex:i];
            NSString *productsLowerCaseString = [product.product.name lowercaseString];
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
    if ([[self.productGroups objectAtIndex:indexPath.row] isKindOfClass:[ProductListItemGroup class]]) {
        ProductListItemGroup *programGroup = [self.productGroups objectAtIndex:indexPath.row];
        return [programGroup.productListItemArray count];
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
    
    //details
    UILabel *countsLabel = [[UILabel alloc ]initWithFrame:CGRectMake(10.0, 40.0, 150.0, 15.0)];
    countsLabel.textColor = [UIColor blackColor];
    countsLabel.font = [UIFont fontWithName:@"Helvetica" size:(13.0)];
    countsLabel.numberOfLines=1;
    countsLabel.textColor = [UIColor darkGrayColor];
    [cell addSubview:countsLabel];
    cell.expandable = NO;
    if ([[self.productGroups objectAtIndex:indexPath.row] isKindOfClass:[ProductListItemGroup class]]) {
        ProductListItemGroup *programGroup = [self.productGroups objectAtIndex:indexPath.row];
       productNameLabel.text = programGroup.name;
        cell.expandable = YES;
    } else {
        ProductListItem *productListItem = [self.productGroups objectAtIndex:indexPath.row];
        productNameLabel.text = productListItem.product.name;
        SavedAudit *savedAuditLocal = productListItem.savedAudit;
        [self.productGroups replaceObjectAtIndex:indexPath.row withObject:productListItem];
        productListItem.product.isFlagged = productListItem.orderData.FlaggedProduct;
        BOOL isFlagged = productListItem.orderData.FlaggedProduct;
        
        int countOfCasesLocal = 0;
    
        if (savedAuditLocal) {
            if (savedAuditLocal.countOfCases > 0) {
                countOfCasesLocal = savedAuditLocal.countOfCases;
            }else
                countOfCasesLocal = [productListItem.orderData.QuantityOfCases intValue];
                
            int userEnteredAuditsCount = savedAuditLocal.userEnteredAuditsCount;
            if (userEnteredAuditsCount == 0) {
                userEnteredAuditsCount = savedAuditLocal.auditsCount;
            }
            countsLabel.text = [NSString stringWithFormat:@"%d/%d", userEnteredAuditsCount, countOfCasesLocal];
        } else {
            countOfCasesLocal = [productListItem.orderData.QuantityOfCases intValue];
            countsLabel.text =[NSString stringWithFormat:@"0/%d", countOfCasesLocal];
        }
        
        //if PO is None then do not show counts text
        if([[Inspection sharedInspection].poNumberGlobal isEqualToString:@"None"]
           && [[User sharedUser].userSelectedVendorName isEqualToString:@"None"] && [[Inspection sharedInspection].grnGlobal isEqualToString:@"None"]){
            countsLabel.text=@"0/0";
        }
        
        int collaborativeStatus = productListItem.collaborativeInspectionStatus;
        self.productStatusButton = [[RowSectionButton alloc] initWithFrame:CGRectMake(cell.bounds.size.width-50, 5, 30, 30)];
        if(collaborativeStatus == STATUS_STARTED)
            [self.productStatusButton setBackgroundImage:[UIImage imageNamed:@"halfcircle.png"] forState:normal];
        if(collaborativeStatus == STATUS_FINSIHED)
            [self.productStatusButton setBackgroundImage:[UIImage imageNamed:@"circlecheck.png"] forState:normal];
        self.productStatusButton.row = indexPath.row;
        [self.productStatusButton addTarget:self action:@selector(showCollaborativeProductMessage:) forControlEvents:UIControlEventTouchUpInside];
        
        if(collaborativeStatus != STATUS_NOT_STARTED)
            [cell addSubview:self.productStatusButton];
        UILabel *scoreLabel = [[UILabel alloc]initWithFrame:CGRectMake(cell.bounds.size.width-60, 5, 45, 45)];
        double score = [productListItem.orderData.score doubleValue];
        if(score != 0.0){
        scoreLabel.text = [NSString stringWithFormat:@"%.02f",score];
        if((score >= 0) && (score <= 40)){
            scoreLabel.layer.borderColor = [UIColor redColor].CGColor;
        }else if((score >= 41) && (score <= 70)){
            scoreLabel.layer.borderColor = [UIColor orangeColor].CGColor;
        }else{
            scoreLabel.layer.borderColor = [UIColor greenColor].CGColor;
        }
        
        scoreLabel.layer.borderWidth = 2.0;
        scoreLabel.layer.cornerRadius = scoreLabel.frame.size.width/2;
        scoreLabel.textAlignment = NSTextAlignmentCenter;
        scoreLabel.font = [UIFont fontWithName:@"Helvetica" size:(15.0)];
        [cell addSubview:scoreLabel];
        }
        if(isFlagged){
            productNameLabel.textColor= [UIColor redColor];
            //show flag
            self.flaggedProductButton = [[RowSectionButton alloc] initWithFrame:CGRectMake(cell.bounds.size.width-5, 5, 30, 30)];
            [self.flaggedProductButton setBackgroundImage:[UIImage imageNamed:@"redflag.png"] forState:normal];
            self.flaggedProductButton.row = indexPath.row;
            [self.flaggedProductButton addTarget:self action:@selector(showFlaggedProductMessage:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:self.flaggedProductButton];
        }
        cell.expandable = NO;
    }
    return cell;
}

- (void) showCollaborativeProductMessage:(RowSectionButton*)sender {
    ProductListItem *productListItem = [self.productGroups objectAtIndex:sender.row];
    NSString* message = productListItem.collaborativeInspectionMessage;
    UIAlertView* dialog = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [dialog show];
    
}

/*
 Clipper damage > 0.5 sq cm allowed
 Light blemish affecting in aggregate >6 sq cm. of surface allowed.
 
 Date Matrix Variation
 Product                    Best Before Code         Minimum Days Shelf Life into DC    Display Until Date Coding
 Lemons                               13                                                    11                                                          -7
 Mandarins                       11                                                     9                                                          -6
 Oranges                               12                                                    10                                                          -6
 
 
 */

- (void) showFlaggedProductMessage:(RowSectionButton*)sender {
    ProductListItem *productListItem = [self.productGroups objectAtIndex:sender.row];
    //NSString *flaggedProductMessageToShow = productListItem.orderData.Message;
    
    //DI-2933 - use the messages array to render text/html message
    NSMutableArray *flaggedMessageArray = productListItem.orderData.allFlaggedProductMessages;
    NSString* flaggedProductName = productListItem.product.name;
    
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
    
    if ([[self.productGroups objectAtIndex:indexPath.row] isKindOfClass:[ProductListItemGroup class]]) {
        ProductListItemGroup *programGroup = self.productGroups[indexPath.row];
        ProductListItem *product = programGroup.productListItemArray[indexPath.subRow - 1];
        cell.textLabel.text = product.product.name;
        SavedAudit *savedAuditLocal = product.savedAudit;
        
        int countOfCasesLocal = 0;
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
    if ([[self.productGroupsDidSelectGlobalArray objectAtIndex:indexPath.row] isKindOfClass:[ProductListItem class]]) {
        ProductListItem *productItem = [self.productGroupsDidSelectGlobalArray objectAtIndex:indexPath.row];
        Product *product = productItem.product;
        [Inspection sharedInspection].currentSplitGroupId = productItem.savedAudit.splitGroupId; //set split groupId
        [self selectedProduct:product];
    }
}

- (void)tableView:(SKSTableView *)tableView didSelectSubRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[self.productGroupsDidSelectGlobalArray objectAtIndex:indexPath.row] isKindOfClass:[ProductListItemGroup class]]) {
        ProductListItemGroup *prg = [self.productGroupsDidSelectGlobalArray objectAtIndex:indexPath.row];
        if ([[prg.productListItemArray objectAtIndex:indexPath.subRow-1] isKindOfClass:[ProductListItem class]]) {
            ProductListItem *productItem = [prg.productListItemArray objectAtIndex:indexPath.subRow-1];
            Product *product = productItem.product;
            [Inspection sharedInspection].currentSplitGroupId = productItem.savedAudit.splitGroupId; //set split groupId
            [self selectedProduct:product];
        }
    }
}

-(void) selectedProduct:(Product*)product{
    self.productSelectedForGlobalSelection = product;
    NSString *poNumber = [Inspection sharedInspection].poNumberGlobal;
    
    if((![poNumber  isEqual: @""]) && (poNumber != nil)){
    if ([product.skus count] > 0) {
        self.poNumbersArrayForSelectedProduct = [self checkForMultiplePOsForProduct:[product.skus lastObject]];
    }
    if ([self.poNumbersArrayForSelectedProduct count] > 0) {
        if ((![[Inspection sharedInspection] checkForOrderData] &&
             ![[Inspection sharedInspection] isOtherSelected])
             ||([[Inspection sharedInspection].poNumberGlobal isEqualToString:@"None"])) {
            if ([self.productAudits count] < 1) {
                [self selectPOs:self.poNumbersArrayForSelectedProduct withTitle:@"Select PO"];
                return;
            } /*else {
                [self navigateToProductView:product];
            }*/
        } /*else {
            [self navigateToProductView:product];
        }*/
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
    }
    }else{
        if ([product.skus count] > 0) {
            self.grnArrayForSelectedProduct = [self checkForMultiplePOsForProduct:[product.skus lastObject]];
        }
        if ([self.grnArrayForSelectedProduct count] > 0) {
            if ((![[Inspection sharedInspection] checkForOrderData] &&
                 ![[Inspection sharedInspection] isOtherSelected])
                 ||([[Inspection sharedInspection].grnGlobal isEqualToString:@"None"])) {
                if ([self.productAudits count] < 1) {
                    [self selectPOs:self.grnArrayForSelectedProduct withTitle:@"Select GRN"];
                    return;
                }
            }
            
        } else {
            
            if ([self.grnArrayForSelectedProduct count] > 0) {
                if (![[Inspection sharedInspection] checkForOrderData] && ![[Inspection sharedInspection] isOtherSelected]) {
                    if ([self.productAudits count] < 1) {
                        OrderData *ord = [self.grnArrayForSelectedProduct objectAtIndex:0];
                        //[[Inspection sharedInspection] initInspection];
                        [[Inspection sharedInspection] saveGRNToInspection:ord.grn];
                        [User sharedUser].userSelectedVendorName = ord.VendorName;
                        [[Inspection sharedInspection] checkForGRNAndSaveItInUserDefaults];
                        [Inspection sharedInspection].dateTimeForOrderData = ord.ExpectedDeliveryDateTime;
                        [NSUserDefaultsManager saveObjectToUserDefaults:ord.ExpectedDeliveryDateTime withKey:OrderDataDateTimeSet];
                    }
                }
            }
        }
    }
    for(int i = 0; i < self.productGroups.count; i++){
        if([[self.productGroups objectAtIndex:i] isKindOfClass:[ProductListItem class]]){
            ProductListItem *productList = [self.productGroups objectAtIndex:i];
            if(productList.product.product_id == product.product_id){
                product.allFlaggedProductMessages = productList.orderData.allFlaggedProductMessages;
                product.score = productList.orderData.score;
            }
        }
    }

    [self navigateToProductView:product];
}

- (void) navigateToProductView: (Product *) product {
    ProductViewController *productViewController = [[ProductViewController alloc] initWithNibName:@"ProductViewController" bundle:nil];
    productViewController.product = [product getCopy];
    productViewController.parentView = defineProductSelectViewController;
    if([self.productAudits count]>0 && [Inspection sharedInspection].checkForOrderData){
        [Inspection sharedInspection].currentSplitGroupId = product.savedAudit.splitGroupId;
        productViewController.savedAudit = product.savedAudit;
    }

    //init split groupID if empty
    if([[Inspection sharedInspection].currentSplitGroupId length]==0)
        [Inspection sharedInspection].currentSplitGroupId = [DeviceManager getCurrentTimeString];
    
    [self removeBackFromProductSelectMethod];
    
    
   // if([CollobarativeInspection isCollaborativeInspectionsEnabled]){
     //   [self startCollaborativeInspectionForProduct:(int)productViewController.product.product_id withViewController:productViewController];
    //}else
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
-(void) getLatestCollaborativeInspectionsWithBlock:(void(^)(BOOL success))respond
{
    CollobarativeInspection* collobarativeInsp = [Inspection sharedInspection].collobarativeInspection;
    if(!collobarativeInsp) {
        collobarativeInsp = [[CollobarativeInspection alloc]init];
        [Inspection sharedInspection].collobarativeInspection = collobarativeInsp;
    }
    [collobarativeInsp initCollabInspectionsForPO:[Inspection sharedInspection].poNumberGlobal withBlock:^(BOOL success) {
        respond(success);
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


- (void) removeBackFromProductSelectMethod {
    [Inspection sharedInspection].removeBackFromProductSelect = YES;
    [User sharedUser].temporaryPONumberFromUserClass = @"";
    [User sharedUser].temporaryGRNFromUserClass = @"";
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
