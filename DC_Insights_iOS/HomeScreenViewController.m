//
//  HomeScreenViewController.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/13/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "HomeScreenViewController.h"
#import "InspectionTableViewCell.h"
#import "ProductRatingViewController.h"
#import "MasterProductRatingManager.h"
#import "User.h"
#import "Inspection.h"
#import "AuditApiContainerParent.h"
#import "ContainerViewController.h"
#import "Inspection.h"
#import "ProductSelectAutoCompleteViewController.h"
#import "InspectionStatusViewController.h"
#import "LocationManager.h"
#import "SavedInspection.h"
#import "UserLocationSelectViewController.h"
#import <Google/SignIn.h>
#import "OrderData.h"
#import "ImageArray.h"
#import "BackgroundUpload.h"

@interface HomeScreenViewController ()

@property int pendingAuditsToUpload;
@property int pendingImagesToUpload;

@end

@implementation HomeScreenViewController

@synthesize table;
@synthesize resumeInspectionLabel;
@synthesize startNewInspectionButton;
@synthesize inspectionTableViewCell;
@synthesize scrollView;
@synthesize emailAddress;
@synthesize address;
@synthesize pastInspections;
@synthesize syncManager;


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
    [super viewWillAppear:animated];
    //[NSUserDefaultsManager removeObjectFromUserDeafults:containerIdForProductsFiltering];

    self.pageTitle = @"HomeScreenViewController";
    [User sharedUser].allImages = [[NSMutableArray alloc] init];
    [self setupNavBar];
    [self tableViewSetup];
    [self checkForAuditsToUpload];
    [self populatePreviousInspections];
    if ([[[User sharedUser] getAuditorRole] isEqualToString:AUDITOR_ROLE_DC]) {
        self.resumeInspectionLabel.hidden = NO;
    } else {
        self.resumeInspectionLabel.hidden = YES;
    }
    [self.table reloadData];
}

- (void) viewWillDisappear:(BOOL)animated {
    self.syncManager.delegate = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.logsView = [[UITextView alloc] init];
    self.auditsPresentForUploadGlobal = NO;
    self.updatedLocationTouched = NO;
    self.emailAddress.text = [[User sharedUser] email];
    Store *store = [[User sharedUser] currentStore];
    self.address.text = @"";
    if (store.address) {
        self.address.text = [NSString stringWithFormat:@"%@", store.address];
    }
    if ([[User sharedUser] checkForRetailInsights] || [[User sharedUser] checkForScanOut]) {
        self.dividerButton.hidden = YES;
        self.showCompletedInspectionsButton.hidden = YES;
        self.savedInspectionsButton.hidden = YES;
        self.savedInspDividerButton.hidden = YES;
    }
    self.storeName.text = [NSString stringWithFormat:@"%@", store.name];
    [self configureFonts];
    [self scrollViewSetup];
    [self checkForAudiProgram];
    [self initNotificationCenterListener];
    // Do any additional setup after loading the view from its nib.
}

//Set program level variables
- (void) checkForAudiProgram {
    NSArray *containers = [[[User sharedUser] currentStore] getListOfAllContainersForTheStore];
    BOOL audiPresent = NO;
    for (Container *container in containers) {
        if ([[container.containerProgramName lowercaseString] isEqualToString:@"aldi"]) {
            audiPresent = YES;
            [NSUserDefaultsManager saveObjectToUserDefaults:container.containerProgramName withKey:selectedProgramName];
            break;
        }
    }
    if(!containers || [containers count]==0){
        //check if only 1 program - then assign that program
        //[[User sharedUser] getListOfProgramsForTheStore];
        [[User sharedUser] getListOfProgramsForTheStore:[User sharedUser].currentStore];
        NSArray* allPrograms = [User sharedUser].currentStore.allPrograms;
        if([allPrograms count]==1){
            Program* prog = allPrograms[0];
            NSString* programName = prog.name;
        BOOL isDistinctMode = [[Inspection sharedInspection] checkIfProgramIsDistinctMode:programName];
        [NSUserDefaultsManager saveBOOLToUserDefaults:isDistinctMode withKey:programIsDistinctSamplesMode]; //set distinct Samples
        }
    }
}


- (IBAction)bringCompleteInspectionsList:(id)sender {
    //UIWindow *win = [[UIApplication sharedApplication] keyWindow];
    CompleteInspectionsListViewController* completeInspectionsListViewController = [[CompleteInspectionsListViewController alloc] initWithNibName:@"CompleteInspectionsListViewController" bundle:nil];
    //self.completeInspectionsListViewController.view.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    [self.navigationController pushViewController:completeInspectionsListViewController animated:YES];
    /*[win addSubview:self.completeInspectionsListViewController.view];
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         self.completeInspectionsListViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
                     } completion:^(BOOL finished){
                     }];*/
}

- (void) logReceived:(NSNotification *)notification
{
    NSLog(@"lsodjf %@", self.logsView.text);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.logsView setText:[NSString stringWithFormat:@"%@%@", self.logsView.text, notification.object]];
        [self.logsView scrollRangeToVisible:NSMakeRange([self.logsView.text length], 0)];
    });
}

- (void)logStatusTouched {
    [self getAllTheRatingsNoMatterWhat];
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setSubject:@"Debug Log"];
    [controller setMessageBody:[[User sharedUser] logForUser] isHTML:NO];
    //[controller addAttachmentData:data mimeType:@"db" fileName:@"offlineData"];
    if (controller) {
        [self presentModalViewController:controller animated:YES];
    }
}

- (void) getAllTheRatingsNoMatterWhat {
    NSString *queryAllOfflineRatings = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%@'", TBL_COMPLETED_AUDITS, COL_DATA_SUBMITTED, CONST_FALSE];
    FMDatabase *databaseOfflineRatings = [[DBManager sharedDBManager] openDatabase:DB_OFFLINE_DATA];
    FMResultSet *resultsGroupRatings;
    [databaseOfflineRatings open];
    resultsGroupRatings = [databaseOfflineRatings executeQuery:queryAllOfflineRatings];
    while ([resultsGroupRatings next]) {
        NSString *ratings = [resultsGroupRatings stringForColumn:COL_RATINGS];
        [[User sharedUser] addLogText:[NSString stringWithFormat:@"\nRatings Start: %@\n", ratings]];
    }
    [databaseOfflineRatings close];
}

- (NSString *)locationFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [NSString stringWithFormat:@"%@/%@.%@", documentsDirectory, @"offlineData", @"db"];
    return path;
}

#pragma mark - Mail delegate

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void) populatePreviousInspections {
    self.pastInspections = [[User sharedUser] getAllSavedInspections];
}

- (void)configureFonts
{
    self.logoutButton.layer.cornerRadius = 5.0;
    self.logoutButton.layer.borderWidth = 1.0; 
    self.logoutButton.layer.borderColor = [[UIColor blackColor] CGColor];
    
    self.startNewInspectionButton.layer.cornerRadius = 5.0;
    self.startNewInspectionButton.layer.borderWidth = 1.0;
    self.startNewInspectionButton.layer.borderColor = [[UIColor blackColor] CGColor];
    
    self.selectLocationButton.layer.cornerRadius = 5.0;
    self.selectLocationButton.layer.borderWidth = 1.0;
    self.selectLocationButton.layer.borderColor = [[UIColor blackColor] CGColor];

    self.updateLocationButton.layer.cornerRadius = 5.0;
    self.updateLocationButton.layer.borderWidth = 1.0;
    self.updateLocationButton.layer.borderColor = [[UIColor blackColor] CGColor];
    
}

- (void) setupNavBar {
    [super setupNavBar];
}

- (void) scrollViewSetup {
    self.scrollView.delegate = self;
    self.scrollView.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
}

- (void) tableViewSetup {
    [self.table setSeparatorColor:[UIColor blackColor]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma SavedInspections Button Methods

- (IBAction)savedInspectionButtonTouched:(id)sender {
    
    if ([self.pastInspections count] == 0) {
        [[[UIAlertView alloc] initWithTitle: @"No Saved Inspections" message:nil delegate: self cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
    } else {
    
   // [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveUtilityView" object:self];
    CGFloat xWidth = self.view.frame.size.width - 20.0f;
    CGFloat yHeight = popupDefaultHeight;
   // if ( [self.pastInspections count] < 5) {
        int heightAfterCalculation =  [self.pastInspections count] * 60.0f;
        heightAfterCalculation = heightAfterCalculation + 40;
        yHeight = heightAfterCalculation;
   // }
    CGFloat yOffset = (self.view.frame.size.height - yHeight)/2.0f;
    UIPopoverListView *poplistview = [[UIPopoverListView alloc] initWithFrame:CGRectMake(10, yOffset, xWidth, yHeight)];
    poplistview.delegate = self;
    poplistview.datasource = self;
    poplistview.listView.scrollEnabled = TRUE;
    [poplistview setTitle:@"  Saved Inspections"];
    [poplistview show];
    }
}


#pragma mark - UIPopoverListViewDataSource

- (UITableViewCell *)popoverListView:(UIPopoverListView *)popoverListView
                    cellForIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                    reuseIdentifier:identifier];
    SavedInspection *savedInspection = [self.pastInspections objectAtIndex:indexPath.row];
    cell.textLabel.text = savedInspection.inspectionName;
    if ([savedInspection.inspectionName isEqualToString:@""]) {
        cell.textLabel.text = savedInspection.auditMasterId;
    }
    
    UILabel *numberLabel = [[UILabel alloc]initWithFrame:CGRectMake(220, 0, 45, 45)];
    numberLabel.text =  [NSString stringWithFormat:@"%d", savedInspection.auditsCount];
    cell.accessoryView = numberLabel;
    return cell;
}

- (CGFloat)popoverListView:(UIPopoverListView *)popoverListView
   heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (NSInteger)popoverListView:(UIPopoverListView *)popoverListView
       numberOfRowsInSection:(NSInteger)section
{
   return [self.pastInspections count];
}

#pragma mark - UIPopoverListViewDelegate
- (void)popoverListView:(UIPopoverListView *)popoverListView
     didSelectIndexPath:(NSIndexPath *)indexPath
{
    SavedInspection *savedInspection;
    if ([self.pastInspections count] > 0) {
        savedInspection = [self.pastInspections objectAtIndex:indexPath.row];
    }
    [[Inspection sharedInspection] resumeSavedInspection:savedInspection.auditMasterId];
    [Inspection sharedInspection].inspectionName = savedInspection.inspectionName;
    if (savedInspection.auditsCount > 0) {
        InspectionStatusViewController *inspectionViewController = [[InspectionStatusViewController alloc] initWithNibName:@"InspectionStatusViewController" bundle:nil];
        [self.navigationController pushViewController:inspectionViewController animated:YES];
    } else {
        ProductSelectAutoCompleteViewController *productSelectAutoCompleteViewController = [[ProductSelectAutoCompleteViewController alloc] initWithNibName:@"ProductSelectAutoCompleteViewController" bundle:nil];
        [self.navigationController pushViewController:productSelectAutoCompleteViewController animated:YES];
    }
}

-(void) initNotificationCenterListener {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logReceived:) name:@"logReceived" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sortStoresAfterLocationReturn) name:@"LocationNotificationHomeScreen" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(backgroundUploadNotification:)
                                                 name:NOTIFICATION_BACKGROUND_UPLOAD_STARTED
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(backgroundUploadNotification:)
                                                 name:NOTIFICATION_BACKGROUND_UPLOAD_COMPLETED
                                               object:nil];
}

-(void) backgroundUploadNotification:(NSNotification *) notification{
    if ([[notification name] isEqualToString:NOTIFICATION_BACKGROUND_UPLOAD_COMPLETED]){
        NSLog (@"Successfully received the test notification!");
        [self checkForAuditsToUpload];
    }
    if ([[notification name] isEqualToString:NOTIFICATION_BACKGROUND_UPLOAD_STARTED]){
        NSLog (@"Successfully received the test notification!");
        [self.uploadButton setImage:[UIImage imageNamed:@"ic_refresh.png"] forState:UIControlStateNormal];
    }
}


- (IBAction)startNewInspectionButtonTouched:(id)sender {
    [User sharedUser].userSelectedVendorName = @"";
    //[self showLoadingScreenWithText:@"Loading..."];
    
    UIWindow *win = [[UIApplication sharedApplication] keyWindow];
    self.syncOverlayView = [[SyncOverlayView alloc] initWithFrame:CGRectMake(0, 0, win.bounds.size.width, win.bounds.size.height)];
    self.syncOverlayView.headingTitleLabel.text = LoadingContainersProducts;
    [self.syncOverlayView showActivityView];
    [win addSubview:self.syncOverlayView];
    
    dispatch_queue_t backgroundQueue = dispatch_queue_create("com.mycompany.myqueue", 0);
    dispatch_async(backgroundQueue, ^{
        if ([[User sharedUser].currentStore.productGroups count] <= 0) {
            [[User sharedUser].currentStore getProductGroups];
            [Inspection sharedInspection].productGroups = [User sharedUser].currentStore.productGroups;
        }
        BOOL orderDataExists  = [OrderData orderDataExistsInDB];
        [OrderData saveOrderDataStatusPref:orderDataExists];
        NSArray *containers = [[[User sharedUser] currentStore] getListOfAllContainersForTheStore];
        if ([containers count] < 1) {
            [[Inspection sharedInspection] initInspection];
            Container *container = [[Container alloc] init];
            [[Inspection sharedInspection] setSavedContainer:container];
            [[Inspection sharedInspection] saveContainerImagesToDB];
            [[Inspection sharedInspection] saveContainerRatingsToDB];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.syncOverlayView dismissActivityView];
                [self.syncOverlayView removeFromSuperview];
                ProductSelectAutoCompleteViewController *productSelectAutoCompleteViewController = [[ProductSelectAutoCompleteViewController alloc] initWithNibName:@"ProductSelectAutoCompleteViewController" bundle:nil];
                [self.navigationController pushViewController:productSelectAutoCompleteViewController animated:YES];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.syncOverlayView dismissActivityView];
                [self.syncOverlayView removeFromSuperview];;
                /*MasterProductRatingManager *masterProductRatingManager = [[MasterProductRatingManager alloc] init];
                 masterProductRatingManager.navigationController = self.navigationController;
                 [masterProductRatingManager navigateNow];*/
                
                ContainerViewController *containerViewController;
                containerViewController = [[ContainerViewController alloc] initWithNibName:kContainerViewNIBName bundle:nil];
                [self.navigationController pushViewController:containerViewController animated:YES];
            });
        }
    });
}

#pragma mark - TableView Delegate Methods
/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;    //count of section
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.pastInspections count];    //count number of row from counting array hear cataGorry is An Array
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = InspectionTableView;
    
    InspectionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil)
    {
        [[NSBundle mainBundle] loadNibNamed:InspectionTableView owner:self options:nil];
        cell = inspectionTableViewCell;
        self.inspectionTableViewCell = nil;
    }
    SavedInspection *savedInspection = [self.pastInspections objectAtIndex:indexPath.row];
    cell.inspectionNumberLabel.text = savedInspection.inspectionName;
    if ([savedInspection.inspectionName isEqualToString:@""]) {
        cell.inspectionNumberLabel.text = savedInspection.auditMasterId;
    }
    
    cell.numberOfInspectionsLabel.text = [NSString stringWithFormat:@"%d", savedInspection.auditsCount];
    cell.roundedCornersView.layer.cornerRadius = 5.0;
    cell.roundedCornersView.layer.borderWidth = 2;
    cell.roundedCornersView.layer.borderColor = [[UIColor blackColor] CGColor];
    cell.numberOfInspectionsLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15.0];
    cell.modifiedLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = [InspectionTableViewCell myCellHeight];
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SavedInspection *savedInspection;
    if ([self.pastInspections count] > 0) {
        savedInspection = [self.pastInspections objectAtIndex:indexPath.row];
    }
    [[Inspection sharedInspection] resumeSavedInspection:savedInspection.auditMasterId];
    [Inspection sharedInspection].inspectionName = savedInspection.inspectionName;
    if (savedInspection.auditsCount > 0) {
        InspectionStatusViewController *inspectionViewController = [[InspectionStatusViewController alloc] initWithNibName:@"InspectionStatusViewController" bundle:nil];
        [self.navigationController pushViewController:inspectionViewController animated:YES];
    } else {
        ProductSelectAutoCompleteViewController *productSelectAutoCompleteViewController = [[ProductSelectAutoCompleteViewController alloc] initWithNibName:@"ProductSelectAutoCompleteViewController" bundle:nil];
        [self.navigationController pushViewController:productSelectAutoCompleteViewController animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}
*/
- (IBAction)selectLocationButtonTouched:(id)sender {
    [self gotoLocationScreen];
}

- (void) gotoLocationScreen {
    BOOL locationViewPresent = NO;
    int index = 0;
    for (int i = 0; i < [self.navigationController.viewControllers count]; i++) {
        if ([[self.navigationController.viewControllers objectAtIndex:i] isKindOfClass:[UserLocationSelectViewController class]]) {
            locationViewPresent = YES;
            index = i;
        }
    }
    if (!locationViewPresent) {
        UserLocationSelectViewController *userLocationSelectViewController = [[UserLocationSelectViewController alloc] initWithNibName:@"UserLocationSelectViewController" bundle:nil];
        [self.navigationController pushViewController:userLocationSelectViewController animated:NO];
    } else {
        UserLocationSelectViewController *userLocationSelectViewController = (UserLocationSelectViewController *) [self.navigationController.viewControllers objectAtIndex:index];
        [self.navigationController popToViewController:userLocationSelectViewController animated:YES];
    }
}

- (IBAction)logoutButtonTouched:(id)sender {
    NSArray *savedInspections = [[User sharedUser] getAllSavedInspections];
    if ([savedInspections count] > 0) {
        [[[UIAlertView alloc] initWithTitle: @"Need to finish or cancel all inspections before logging out" message:nil delegate: self cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
    } else {
        [[User sharedUser] logoutUser];
        [[GIDSignIn sharedInstance] signOut];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (IBAction)updateLocationButtonTouched:(id)sender {
    [[[UIAlertView alloc] initWithTitle: @"Do you want to update the Location?" message:nil delegate: self cancelButtonTitle:@"cancel" otherButtonTitles: @"Ok", nil] show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 2) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UpdateLink]];
    } else if (alertView.tag ==3) {
    } else {
        if (buttonIndex == 0) {
        } else if (buttonIndex == 1) {
            self.updatedLocationTouched = YES;
            [[LocationManager sharedLocationManager] retrieveCurrentLocationOnlyIfAlreadySet];
        }
    }
}

- (void) sortStoresAfterLocationReturn {
    //CLLocation *location = [[LocationManager sharedLocationManager] currLocation];
    NSArray *storesSortedAfterLocationUpdate = [[User sharedUser] getListOfStoresSortedByDistance];
    Store *newStoreAfterLocalUpdate = [self locationUpdated:storesSortedAfterLocationUpdate];
    self.address.text = [NSString stringWithFormat:@"%@", newStoreAfterLocalUpdate.address];
    self.storeName.text = [NSString stringWithFormat:@"%@", newStoreAfterLocalUpdate.name];
}

- (Store *) getTheRightStore: (NSArray *) storesLocal {
    NSMutableArray *storesArrayLocal = [[NSMutableArray alloc] init];
    CLLocation *currentLocation = [[LocationManager sharedLocationManager] currentLocation];
    for (Store *store in storesLocal) {
        if (store.distanceFromUserLocation < 0) {
            CLLocation *storeLocation = [[CLLocation alloc] initWithLatitude:store.latitude longitude:store.longitude];
            CLLocationDistance distance = [storeLocation distanceFromLocation:currentLocation];
            store.distanceFromUserLocation = distance/1609.344;
            [storesArrayLocal addObject:store];
        } else {
            [storesArrayLocal addObject:store];
        }
    }
    NSArray *storesSortedLocal = [[User sharedUser] sortStores:[storesArrayLocal copy]];
    storesLocal = [[NSArray alloc] init];
    storesLocal = storesSortedLocal;
    if ([storesLocal count] > 0) {
        [[User sharedUser] setCurrentStore:[storesLocal objectAtIndex:0]];
        return (Store *) [storesLocal objectAtIndex:0];
    }
    return nil;
}

- (Store *) locationUpdated: (NSArray *) storesLocal {
    if (self.updatedLocationTouched) {
        if ([storesLocal count] > 0) {
            Store *store = [self getTheRightStore:storesLocal];
            return store;
        }
        return nil;
    } else {
        if ([User sharedUser].currentStore) {
            return [User sharedUser].currentStore;
        } else {
            if ([storesLocal count] > 0) {
                Store *store = [self getTheRightStore:storesLocal];
                return store;
            }
            return nil;
        }
    }
    self.updatedLocationTouched = NO;
}

- (void) uploadButtonTouched {
    BOOL connectionAvailable = NO;
    NSString *connectionString;
    if ([NSUserDefaultsManager getBOOLFromUserDeafults:SyncOverWifi]) {
        connectionAvailable = [DeviceManager isConnectedToWifi];
        connectionString = @"Wifi connection not available, Manage connection in Settings";
    } else {
        connectionAvailable = [DeviceManager isConnectedToNetwork];
        connectionString = @"No connection available";
    }
    
    if(!connectionAvailable){
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Upload Operation"
                                                          message:[NSString stringWithFormat:@"%@", connectionString]
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];
        return;
    }
    
    if([[User sharedUser].backgroundUpload isBackgroundUploadInProgress]){
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Background upload in progress - please wait"
                                                          message:[NSString stringWithFormat:@"%@", connectionString]
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        
        [message show];
        return;
    }
    
        [UIApplication sharedApplication].idleTimerDisabled = YES;
        self.retryCount = 0;
        self.auditsUploadedTotalUsingRetries = 0;
        self.imagesUploadedTotalUsingRetries = 0;
        UIWindow *win = [[UIApplication sharedApplication] keyWindow];
        self.syncManager = [[SyncManager alloc] init];
        self.syncOverlayView = [[SyncOverlayView alloc] initWithFrame:CGRectMake(0, 0, win.bounds.size.width, win.bounds.size.height)];
        self.syncOverlayView.headingTitleLabel.text = Uploading;
        [self.syncOverlayView showActivityView];
        [win addSubview:self.syncOverlayView];
        self.syncManager.delegate = self;
        self.syncManager.overallTotalImagesToUploadCount = 0;
        [self.syncManager uploadDataAndImages];
}

-(void)showSyncInProgressPopup {
    
}

//TODO - clean up the extra variables
- (int) checkForAuditsToUpload {
    __block BOOL auditsToBeUploaded = NO;
    __block BOOL auditImagesToBeUploaded = NO;
    self.pendingAuditsToUpload = 0;
    self.pendingImagesToUpload = 0;
    NSString *queryAllOfflineRatings = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%@'", TBL_COMPLETED_AUDITS, COL_DATA_SUBMITTED, CONST_FALSE];
    NSString *queryAllOfflineRatingsImages = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%@'", TBL_COMPLETED_AUDITS, COL_IMAGE_SUBMITTED, CONST_FALSE];
    FMDatabase *databaseOfflineRatings = [[DBManager sharedDBManager] openDatabase:DB_OFFLINE_DATA];
    FMResultSet *resultsGroupRatings;
    FMResultSet *resultsGroupRatingsImages;
    [databaseOfflineRatings open];
    resultsGroupRatings = [databaseOfflineRatings executeQuery:queryAllOfflineRatings];
    resultsGroupRatingsImages = [databaseOfflineRatings executeQuery:queryAllOfflineRatingsImages];
    int auditsToBeUploadedCount = 0;
    while ([resultsGroupRatings next]) {
        auditsToBeUploadedCount++;
        auditsToBeUploaded = YES;
        self.pendingAuditsToUpload++;
    }
    while ([resultsGroupRatingsImages next]) {
        auditsToBeUploadedCount++;
        auditImagesToBeUploaded = YES;
        self.pendingImagesToUpload++;
    }
    if (auditsToBeUploaded || auditImagesToBeUploaded) {
        self.auditsPresentForUploadGlobal = auditsToBeUploaded;
        auditsToBeUploaded = NO;
        [self.uploadButton setImage:[UIImage imageNamed:@"ic_upload_red.png"] forState:UIControlStateNormal];
    } else {
        [self.uploadButton setImage:[UIImage imageNamed:@"ic_upload.png"] forState:UIControlStateNormal];
    }
    [databaseOfflineRatings close];
    return auditsToBeUploadedCount;
}

- (void) updateAPIName: (NSString *) apiName {
    self.syncOverlayView.apiDownloadedLabel.text = apiName;
    [self.syncOverlayView setNeedsDisplay];
}


- (void) downloadFailed {
    NSString* message;
    NSString* status;
    
    if(self.orderDataStatus == ORDER_DATA_DOWNLOAD_EMPTY){
        message = @"Order Data Not Available";
        status = @"Error";
    }else if(self.orderDataStatus == ORDER_DATA_DOWNLOAD_FAILED){
        message = @"Order Data Failed";
        status = @"Error";
    }else if(self.orderDataStatus == ORDER_DATA_DOWNLOAD_SUCCESS){
        message = @"Order Data Downloaded";
        status = @"Success";
    }
    message = [NSString stringWithFormat:@"%@\n Insights download failed",message];
    [[[UIAlertView alloc] initWithTitle:status message:message delegate: self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
}

- (void) downloadFailed:(NSString*)failMessage {
    [[[UIAlertView alloc] initWithTitle:@"Sync Failed" message: failMessage delegate: self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
}

- (void) downloadProgress: (BOOL)success {
    if (success) {
        RatingAPI *ratingAPI = [[RatingAPI alloc] init];
        //[DefectAPI downloadImagesWithBlock:^(BOOL success) {
        [self updateAPIName:@"Processing"];
        [ratingAPI downloadImagesWithBlock:^(BOOL success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[User sharedUser] reportCurrentTime];
                //[[self delegate] downloadSyncDone:YES];??
                //[self.settingsTable reloadData];
                [self.syncOverlayView removeProgressView];
                [self.syncOverlayView removeFromSuperview];
                //UIWindow *win = [[UIApplication sharedApplication] keyWindow];
                /*SCLAlertView *alert = [[SCLAlertView alloc] init];
                [alert addButton:@"Ok" actionBlock:^(void) {
                    NSLog(@"Ok button tapped");
                }];*/
                
                NSString* message;
                NSString* status;
                
                if(self.orderDataStatus == ORDER_DATA_DOWNLOAD_EMPTY){
                    message = @"Order Data Not Available";
                    status = @"Error";
                }else if(self.orderDataStatus == ORDER_DATA_DOWNLOAD_FAILED){
                    message = @"Order Data Failed";
                    status = @"Error";
                }else if(self.orderDataStatus == ORDER_DATA_DOWNLOAD_SUCCESS){
                    message = @"Order Data Downloaded";
                    status = @"Success";
                }
                    
                [[[UIAlertView alloc] initWithTitle:status message: message delegate: self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
                //loop for testing
                //[self startDownloadd];
            });
        }];
        //}];
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        
    } else {
        [self.syncOverlayView updateProgress];
    }
}


-(void)startDownloadd {
    [self orderDataSyncButtonTouched];
}
- (void) downloadSyncDone: (BOOL)success {
    
}

-(void)startIncrementalSync:(int)orderDataStatus{
    self.orderDataStatus = orderDataStatus;
    if(orderDataStatus == ORDER_DATA_DOWNLOAD_SUCCESS){
        [[Inspection sharedInspection] clearOrderDataArray];
    }
    //remove order-data view
    [self.syncOverlayView dismissActivityView];
    [self.syncOverlayView removeFromSuperview];
    
    UIWindow *win = [[UIApplication sharedApplication] keyWindow];
    self.syncOverlayView = [[SyncOverlayView alloc] initWithFrame:CGRectMake(0, 0, win.bounds.size.width, win.bounds.size.height)];
    self.syncOverlayView.headingTitleLabel.text = @"Downloading Insights Data";
    [win addSubview:self.syncOverlayView];
    //self.syncManager = [[SyncManager alloc] init];
    //self.syncManager.delegate = self;
    //[syncManager prepareSQLDatabasesAndTables];
    [self.syncManager callAllTheAPIsAndProcessThem : YES];
}


-(void) appendTrackingLog:(NSString*)log{
    [[User sharedUser]addTrackingLog:log];
}

- (void) auditsUploaded: (BOOL) success {
   [self checkForAuditsToUpload];
    if (success) {
        [self.syncOverlayView dismissActivityView];
        [self.syncOverlayView removeFromSuperview];
        [[[UIAlertView alloc] initWithTitle: @"Audits and Images Uploaded" message: @"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else {
        [self.syncOverlayView dismissActivityView];
        [self.syncOverlayView removeFromSuperview];
    }
}

//TODO - clean up the audits uploaded count and read from DB directly instead
- (void) imagesUploaded: (BOOL) success withAuditsCount:(int) auditsUploaded withImagesUploaded: (int) imagesUploaded{
    
    //[self checkForAuditsToUpload];
    int auditsTobeUploaded = [self checkForAuditsToUpload];
    self.auditsUploadedTotalUsingRetries = self.auditsUploadedTotalUsingRetries + auditsUploaded;
    self.imagesUploadedTotalUsingRetries = self.imagesUploadedTotalUsingRetries + imagesUploaded;
    BOOL scanout = [[User sharedUser]checkForScanOut];
    if (auditsTobeUploaded > 0 && self.retryCount < 1) { //retry count 1
        self.retryCount++;
        [self appendTrackingLog:[NSString stringWithFormat:@"| Uploaded audits: %d and images: %d",self.auditsUploadedTotalUsingRetries,self.imagesUploadedTotalUsingRetries]];
        [self appendTrackingLog:[NSString stringWithFormat:@"| Retrying Submission - retry count %d",self.retryCount]];
        [self.syncManager uploadDataAndImages];
    } else if (auditsTobeUploaded == 0) {
        if (success) {
            [self appendTrackingLog:[NSString stringWithFormat:@"| Final Result: %d %@ And %d Images Uploaded", self.auditsUploadedTotalUsingRetries, InspectionsUploaded, self.imagesUploadedTotalUsingRetries]];
            [self.syncOverlayView dismissActivityView];
            [self.syncOverlayView removeFromSuperview];
            [self.syncManager reportUploadSync];
            [self.syncManager sendLogsToBackend];
            //[[User sharedUser] addLogText:[NSString stringWithFormat:@"\nRemoved Overlay. Upload Succcessful\n"]];
            
            if (self.imagesUploadedTotalUsingRetries <= 0) {
                [[[UIAlertView alloc] initWithTitle: [NSString stringWithFormat:@"%d %@", self.auditsUploadedTotalUsingRetries, scanout?ScanoutsUploaded:InspectionsUploaded] message: @"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            } else {
                [[[UIAlertView alloc] initWithTitle: [NSString stringWithFormat:@"%d %@ and %d Images Uploaded", self.auditsUploadedTotalUsingRetries, scanout?ScanoutsUploaded:InspectionsUploaded, self.imagesUploadedTotalUsingRetries] message: @"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
            [self.syncManager cleanupOfflineDatabase];//cleanup database
        } else {
            auditsTobeUploaded = self.pendingAuditsToUpload;
            NSString* message = [NSString stringWithFormat:@"Upload Failed. %d remaining in the device.", auditsTobeUploaded];
            int pendingImages = self.syncManager.overallTotalImagesToUploadCount - self.imagesUploadedTotalUsingRetries;
            if(pendingImages>0 && !scanout){
                message = [NSString stringWithFormat:@"Upload Failed : %d audits and %d images remaining", auditsTobeUploaded,pendingImages];
            }
            [self appendTrackingLog:message];
            [[[UIAlertView alloc] initWithTitle: message message: @"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            [self.syncManager reportUploadSync];
            [self.syncManager sendLogsToBackend];
            [[User sharedUser] addLogText:[NSString stringWithFormat:@"| Removed Overlay. Upload Failed |"]];
            [self.syncOverlayView dismissActivityView];
            [self.syncOverlayView removeFromSuperview];
            
        }
        //[self checkAppVersion];
        [UIApplication sharedApplication].idleTimerDisabled = NO;
    } else {
        auditsTobeUploaded = self.pendingAuditsToUpload;
        NSString* message = [NSString stringWithFormat:@"Upload Failed. %d remaining in the device.", auditsTobeUploaded];
        int pendingImages = self.syncManager.overallTotalImagesToUploadCount - self.imagesUploadedTotalUsingRetries;
        if(pendingImages>0 && !scanout){
            message = [NSString stringWithFormat:@"Upload Failed : %d audits and %d images remaining", auditsTobeUploaded,pendingImages];
        }
        [self appendTrackingLog:message];
        [[[UIAlertView alloc] initWithTitle: message message: @"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        [self.syncManager reportUploadSync];
        [self.syncManager sendLogsToBackend];
        [self.syncOverlayView dismissActivityView];
        [self.syncOverlayView removeFromSuperview];
        [self.syncManager reportUploadSync];
        //[self checkAppVersion];
        [UIApplication sharedApplication].idleTimerDisabled = NO;
    }
    
}

- (void) nothingToUpload {
    [[[UIAlertView alloc] initWithTitle: [NSString stringWithFormat:@"%@", noInspectionsToUpload] message: @"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    [[User sharedUser] addLogText:[NSString stringWithFormat:@"| Removed Overlay. Nothing to Upload.|"]];
    [self.syncOverlayView dismissActivityView];
    [self.syncOverlayView removeFromSuperview];
}

- (void) checkAppVersion {
    UIWindow *win = [[UIApplication sharedApplication] keyWindow];
    SyncOverlayView *syncOverlay = [[SyncOverlayView alloc] initWithFrame:CGRectMake(0, 0, win.bounds.size.width, win.bounds.size.height)];
    syncOverlay.headingTitleLabel.text = @"Checking app version";
    [syncOverlay showActivityView];
    [win addSubview:syncOverlay];
    [self.syncManager appUpdateCheckCall:^(BOOL appUpdateCheckCall, NSError *error){
        if (appUpdateCheckCall) {
            if ([[NSUserDefaultsManager getObjectFromUserDeafults:UPDATEMETHOD] isEqualToString:ForcedUpdateMethod]) {
                UIAlertView *alert = [[UIAlertView alloc] init];
                alert.tag = 2;
                [[alert initWithTitle:@"Update Required" message: @"Tap on this link to update" delegate: self cancelButtonTitle:@"Download Link" otherButtonTitles: nil] show];
            } else if ([[NSUserDefaultsManager getObjectFromUserDeafults:UPDATEMETHOD] isEqualToString:ManualUpdateMethod]) {
                UIAlertView *alert = [[UIAlertView alloc] init];
                alert.tag = 3;
                [[alert initWithTitle:@"Update Available" message: @"Tap on this buttons to either update or cancel" delegate: self cancelButtonTitle:@"Cancel" otherButtonTitles: @"Upgrade", nil] show];
            }
        }
        [syncOverlay removeFromSuperview];
        NSLog(@"appid %d", appUpdateCheckCall);
    }];
}

@end
