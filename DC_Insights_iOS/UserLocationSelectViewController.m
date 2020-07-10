//
//  UserLocationSelectViewController.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/7/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "UserLocationSelectViewController.h"
#import "SyncManager.h"
#import "HomeScreenViewController.h"
#import "HPTHomeViewController.h"
#import "DBManager.h"
#import "Container.h"
#import "User.h"
//#import "AppFlow.h"
#import "LocationManager.h"
#import "DeviceManager.h"

@interface UserLocationSelectViewController ()

@end

@implementation UserLocationSelectViewController

@synthesize table;
@synthesize storeLocationTableViewCell;
@synthesize storesArray;
@synthesize storeSelectPopUp;
@synthesize storeNotListedPopUpView;
@synthesize alertView;

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

- (void) configureFontsAndColors {
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationUpdated) name:@"LocationNotification" object:nil];
    [self refreshState];
    if ([[User sharedUser] checkForRetailInsights]) {
        self.storeLocationLabel.text = @"       My Locations";
        self.storeLocationLabel.textAlignment = NSTextAlignmentLeft;
        self.nearbyLocationsButton.hidden = YES; //NO;
        self.nearbyLocationsButton.layer.cornerRadius = 5.0;
        self.nearbyLocationsButton.layer.borderWidth = 1.0;
        self.nearbyLocationsButton.layer.borderColor = [[UIColor blackColor] CGColor];
    }
	// Do any additional setup after loading the view.
}

- (void) refreshState {
    [self.table setSeparatorColor:[UIColor blackColor]];
    [self setupState];
    BOOL downloadingData = NO;
    if (![NSUserDefaultsManager getBOOLFromUserDeafults:SYNCSUCCESS]) {
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
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Sync Device"
                                                              message:[NSString stringWithFormat:@"%@", connectionString]
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
            
            [message show];
            [self reloadTableWithNewSyncValues];
        } else {
            downloadingData = YES;
            [self downloadSyncData];
        }
//        if ([DeviceManager isConnectedToWifi]) {
//            [self downloadSyncData];
//        } else {
//            [[[UIAlertView alloc] initWithTitle:@"Sync Device" message:@"Sync wasnt successful last time. Kindly sync again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//            [self reloadTableWithNewSyncValues];
//        }
    } else {
        [self reloadTableWithNewSyncValues];
    }
    if (downloadingData) {
        downloadingData = NO;
    } else {
        if ([User sharedUser].currentStore) {
            [self navigateToHomeScreenWithStack];
        } else {
            [self autoSelectStore];
        }
    }
}

- (void) autoSelectStore {
    if ([self.storesArray count] > 0) {
        [[User sharedUser] setCurrentStore:[self.storesArray objectAtIndex:0]];
        [self navigateToHomeScreenWithStack];
    }
}

- (void) navigateToHomeScreenWithStack {
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    if(([bundleIdentifier isEqualToString:@"com.trimble.harvestmark.enterprise.hpt"]) || ([bundleIdentifier isEqualToString:@"com.trimble.harvestmark.hpt"]))
    {
        HPTHomeViewController *homeScreenViewController = [[HPTHomeViewController alloc] initWithNibName:@"HPTHomeViewController" bundle:nil];
        [self.navigationController pushViewController:homeScreenViewController animated:NO];
    }else{
    BOOL homeViewPresent = NO;
    for (int i = 0; i < [self.navigationController.viewControllers count]; i++) {
        if ([[self.navigationController.viewControllers objectAtIndex:i] isKindOfClass:[HomeScreenViewController class]]) {
            homeViewPresent = YES;
        }
    }
    if (!homeViewPresent) {
        HomeScreenViewController *homeScreenViewController = [[HomeScreenViewController alloc] initWithNibName:@"HomeScreenViewController" bundle:nil];
        [self.navigationController pushViewController:homeScreenViewController animated:NO];
    }
    }
}

- (void) setupState {
    [self configureFontsAndColors];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.pageTitle = @"UserLocationSelectViewController";
    [self setupNavBar];
    //[self callAllTheApis];
    
    [self reloadTableWithNewSyncValues];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;    //count of section
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.storesArray count];    //count number of row from counting array hear cataGorry is An Array
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = StoreLocationTableView;

    StoreLocationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil)
    {
        [[NSBundle mainBundle] loadNibNamed:StoreLocationTableView owner:self options:nil];
        cell = storeLocationTableViewCell;
        self.storeLocationTableViewCell = nil;
    }
    Store *store = [self.storesArray objectAtIndex:indexPath.row];
    cell.storeName.text = [NSString stringWithFormat:@"%@", store.name];
    cell.storeAddress.text = @"";
    if (store.address) {
        cell.storeAddress.text = [NSString stringWithFormat:@"%@", store.address];
    }
    if (store.distanceFromUserLocation > 0) {
        cell.distance.text = [NSString stringWithFormat:@"%0.2f miles", store.distanceFromUserLocation];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = [StoreLocationTableViewCell myCellHeight];
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{\
    Store *store;
    if ([storesArray count] > 0) {
        store = [self.storesArray objectAtIndex:indexPath.row];
        [[User sharedUser] setCurrentStore:store];
    }
    [self navigateToHomeScreen];
    if (store.storeEnteredByUser) {
        [NSUserDefaultsManager saveBOOLToUserDefaults:YES withKey:StoreEnteredByUser];
    } else {
        [NSUserDefaultsManager saveBOOLToUserDefaults:NO withKey:StoreEnteredByUser];
    }
    [self saveUserSelectedStoreDetailsToDefaultsManager: store];
}

- (void) navigateToHomeScreen {
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    if(([bundleIdentifier isEqualToString:@"com.trimble.harvestmark.enterprise.hpt"]) || ([bundleIdentifier isEqualToString:@"com.trimble.harvestmark.hpt"]))
    {
        HPTHomeViewController *homeScreenViewController = [[HPTHomeViewController alloc] initWithNibName:@"HPTHomeViewController" bundle:nil];
        [self.navigationController pushViewController:homeScreenViewController animated:NO];
    }else{
    HomeScreenViewController *homeScreenViewController = [[HomeScreenViewController alloc] initWithNibName:@"HomeScreenViewController" bundle:nil];
    [self.navigationController pushViewController:homeScreenViewController animated:YES];
    }
}

- (void) sortStoresBasedOnTheLocation: (NSArray *) storesArrayToBeSorted {
    
}

- (void) downloadSyncData {
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    self.syncManager = [[SyncManager alloc] init];
    self.syncManager.delegate = self;
    //[self checkAppVersion];//not being used
    [self downloadOriginalData];
}

- (void) downloadProgress: (BOOL)success {
    if (success) {
        //calling from main thread - xcode warning
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].idleTimerDisabled = NO;
        });
        
        //TODO: check if this is ever called from non UI thread
        dispatch_queue_t backgroundQueue = dispatch_queue_create("com.mycompany.myqueue", 0);
        dispatch_async(backgroundQueue, ^{
            self.storesArray = [[NSArray alloc] init];
            self.storesArray = [[User sharedUser] getListOfStoresSortedByDistance];
            RatingAPI *ratingAPI = [[RatingAPI alloc] init];
            [[User sharedUser] reportCurrentTime];
            dispatch_async(dispatch_get_main_queue(), ^{
                //Your main thread code goes in here
                [self updateAPIName:@"Processing"];
            });
            
            //[DefectAPI downloadImagesWithBlock:^(BOOL success) {
                [ratingAPI downloadImagesWithBlock:^(BOOL success) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIWindow *win = [[UIApplication sharedApplication] keyWindow];
                        SCLAlertView *alert = [[SCLAlertView alloc] init];
                        [alert addButton:@"Ok" actionBlock:^(void) {
                            NSLog(@"Ok button tapped");
                        }];
                        //[alert showSuccess:win.rootViewController title:@"Download Successful" subTitle:@"" closeButtonTitle:nil duration:0.0f];
                        if(self.syncManager.failedImagesCount<=0)
                            [alert showSuccess:win.rootViewController title:@"Download Successful" subTitle:@"" closeButtonTitle:nil duration:0.0f];
                        else
                            [alert showSuccess:win.rootViewController title:@"Download Successful" subTitle:[NSString stringWithFormat:@"%d Images Failed to download. Please try again later", self.syncManager.failedImagesCount] closeButtonTitle:nil duration:0.0f];
                        [self.table reloadData];
                        [self.syncOverlay removeProgressView];
                        [self.syncOverlay removeFromSuperview];
                    });
                }];
            //}];
        });
    } else {
        [self.syncOverlay updateProgress];
    }
}

- (void) updateAPIName: (NSString *) apiName {
    self.syncOverlay.apiDownloadedLabel.text = apiName;
}

- (void)alertView:(UIAlertView *)alertVie clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertVie.tag == 2) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UpdateLink]];
    } else if (alertView.tag ==3) {
        if (buttonIndex == [alertVie cancelButtonIndex]) {
            [self downloadOriginalData];
        }
    }
}

- (void) downloadFailed {
    [self.syncOverlay removeFromSuperview];
    [[[UIAlertView alloc] initWithTitle:@"Sync Failed" message: @"Goto Settings and Sync again" delegate: self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
}


- (void) downloadFailed:(NSString*)failMessage {
    [self.syncOverlay removeFromSuperview];
//    UIWindow *win = [[UIApplication sharedApplication] keyWindow];
//    SCLAlertView *alert = [[SCLAlertView alloc] init];
//    [alert addButton:@"Ok" actionBlock:^(void) {
//        NSLog(@"Ok button tapped");
//    }];
//    [alert showSuccess:win.rootViewController title:@"Sync Failed" subTitle:failMessage closeButtonTitle:nil duration:0.0f];
    [[[UIAlertView alloc] initWithTitle:@"Sync Failed" message:failMessage delegate: self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}



- (void) locationUpdated {
    if ([self.storesArray count] > 0) {
        NSMutableArray *storesArrayLocal = [[NSMutableArray alloc] init];
        CLLocation *currentLocation = [[LocationManager sharedLocationManager] currentLocation];
        for (Store *store in self.storesArray) {
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
        self.storesArray = [[NSArray alloc] init];
        self.storesArray = storesSortedLocal;
        [self.table reloadData];
        if ([User sharedUser].currentStore) {
            [self navigateToHomeScreenWithStack];
        } else {
            [self autoSelectStore];
        }
    }
}

- (void) refreshButtonTouched {
    [self reloadTableWithNewSyncValues];
}

- (void) reloadTableWithNewSyncValues {
    self.storesArray = [[NSArray alloc] init];
    self.storesArray = [[User sharedUser] getListOfStoresSortedByDistance];
    [self.table reloadData];
}

- (void) downloadSyncDone: (BOOL)success {
    [self reloadTableWithNewSyncValues];
}

- (IBAction)nearbyLocationsButtonPressed:(id)sender {
    if ([DeviceManager isConnectedToNetwork]) {
        CLLocation *location =  [[LocationManager sharedLocationManager] currentLocation];
        NSLog(@"lat %f long %f", location.coordinate.latitude, location.coordinate.longitude);
        if (location) {
            self.syncOverlay = [[SyncOverlayView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
            self.syncOverlay.activityIndicatorView.frame = CGRectMake(130, 180, 30, 30);
            self.syncOverlay.headingTitleLabel.text = @"";
            [self.syncOverlay showActivityView];
            [self.view addSubview:self.syncOverlay];
            StoreAPI *storeApi = [[StoreAPI alloc] init];
            [storeApi storeLocationCallWithBlock:^(BOOL isSuccess, NSArray *array, NSError *error){
                if (error) {
                    DebugLog(@"\n Error: %@  \n", [error localizedDescription]);
                    [self.syncOverlay dismissActivityView];
                    [self.syncOverlay removeFromSuperview];
                } else {
                    NSLog(@"posts %@", array);
                    if (isSuccess) {
                        [self.table reloadData];
                        if ([array count] > 0) {
                            NSString *alertMessage = nil;
                            [self lauchCustomPopUpWithView:[self storeSelectPopUpSetup:array withAlertMessage:alertMessage]];
                        } else {
                            NSString *string = [NSString stringWithFormat:@"No Stores Available. Lat: %f Long %f. Create your custom store below.", location.coordinate.latitude, location.coordinate.longitude];
                            [self lauchCustomPopUpWithView:[self storeSelectPopUpSetup:nil withAlertMessage:string]];
                            //[[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"No Stores Available. Lat: %f Long %f", location.coordinate.latitude, location.coordinate.longitude] message:nil delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                        }
                    } else {
                        NSString *string = [NSString stringWithFormat:@"No Stores Available. Lat: %f Long %f. Create your custom store below.", location.coordinate.latitude, location.coordinate.longitude];
                        [self lauchCustomPopUpWithView:[self storeSelectPopUpSetup:nil withAlertMessage:string]];
                        //[[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"No Stores Available. Lat: %f Long %f", location.coordinate.latitude, location.coordinate.longitude] message:nil delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                    }
                    [self.syncOverlay dismissActivityView];
                    [self.syncOverlay removeFromSuperview];
                }
            }];
        } else {
            NSString *string = [NSString stringWithFormat:@"Location not available. Create your custom store below."];
            [self lauchCustomPopUpWithView:[self storeSelectPopUpSetup:nil withAlertMessage:string]];
            //[[[UIAlertView alloc] initWithTitle: [NSString stringWithFormat:@"Location not available."] message:nil delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    } else {
        NSString *string = [NSString stringWithFormat:@"Device is not connected to network. Create your custom store below."];
        [self lauchCustomPopUpWithView:[self storeSelectPopUpSetup:nil withAlertMessage:string]];
       // [[[UIAlertView alloc] initWithTitle: @"Device is not connected to network." message:nil delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

//- (void) addStoreButtonPressed {
//    // Here we need to pass a full frame
//    [self lauchCustomPopUpWithView:[self storeSelectPopUpSetup]];
//}

- (void) lauchCustomPopUpWithView: (UIView *) popUpView {
    //if (!alertView)
    [alertView close];
    alertView = [[CustomIOS7AlertView alloc] init];
    
    // Add some custom content to the alert view
    [alertView setContainerView:popUpView];
    
    // Modify the parameters
    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"Close", nil]];
    [alertView setDelegate:self];
    
    // You may use a Block, rather than a delegate.
    [alertView setOnButtonTouchUpInside:^(CustomIOS7AlertView *alertViewLocal, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertViewLocal tag]);
        [alertViewLocal close];
    }];
    
    [alertView setUseMotionEffects:true];
    // And launch the dialog
    [alertView show];
}

- (UIView *)createDemoView
{
    UIView *demoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 290, 200)];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 270, 180)];
    [imageView setImage:[UIImage imageNamed:@"demo"]];
    [demoView addSubview:imageView];
    
    return demoView;
}

- (UIView *) storeSelectPopUpSetup: (NSArray *) stores withAlertMessage: (NSString *) alertMessage {
    StoreSelectPopUpView *storeSelectPopUpLocal = [[StoreSelectPopUpView alloc] initWithFrame:CGRectMake(0, 0, 290, 200)];
    [[NSBundle mainBundle] loadNibNamed:@"StoreSelectPopUpView" owner:self options:nil];
    storeSelectPopUpLocal = storeSelectPopUp;
    storeSelectPopUpLocal.table.layer.borderWidth = 1.0;
    storeSelectPopUpLocal.table.layer.borderColor = [[UIColor grayColor] CGColor];
    storeSelectPopUpLocal.table.layer.cornerRadius = 5.0;
    storeSelectPopUpLocal.storeNotListedButton.layer.borderWidth = 1.0;
    storeSelectPopUpLocal.storeNotListedButton.layer.borderColor = [[UIColor grayColor] CGColor];
    storeSelectPopUpLocal.storeNotListedButton.layer.cornerRadius = 5.0;
    storeSelectPopUpLocal.stores = stores;
    storeSelectPopUpLocal.delegate = self;
    storeSelectPopUpLocal.alertMessage.text = alertMessage;
    if (!stores) {
        [storeSelectPopUpLocal hideTableViewAndShowAlert];
    }
    [storeSelectPopUpLocal.storeNotListedButton addTarget:self action:@selector(storeNotListedViewToTheFront) forControlEvents: UIControlEventTouchUpInside];
    //[storeSelectPopUpLocal retrieveStores];
    self.storeSelectPopUp = nil;
    return storeSelectPopUpLocal;
}

- (UIView *) storeNotListedPopUpSetup {
    StoreNotListedPopUpView *storeNotListedPopUpViewLocal = [[StoreNotListedPopUpView alloc] initWithFrame:CGRectMake(0, 0, 290, 200)];
    [[NSBundle mainBundle] loadNibNamed:@"StoreNotListedPopUpView" owner:self options:nil];
    storeNotListedPopUpViewLocal = storeNotListedPopUpView;
    storeNotListedPopUpViewLocal.submitButton.layer.borderWidth = 1.0;
    storeNotListedPopUpViewLocal.submitButton.layer.borderColor = [[UIColor grayColor] CGColor];
    storeNotListedPopUpViewLocal.submitButton.layer.cornerRadius = 5.0;
    storeNotListedPopUpViewLocal.delegate = self;
    self.storeNotListedPopUpView = nil;
    return storeNotListedPopUpViewLocal;
}

- (void) storeNotListedViewToTheFront {
    [self lauchCustomPopUpWithView:[self storeNotListedPopUpSetup]];
}

- (void)customIOS7dialogButtonTouchUpInside: (CustomIOS7AlertView *)alertViewLocal clickedButtonAtIndex: (NSInteger)buttonIndex
{
    NSLog(@"Delegate: Button at position %d is clicked on alertView %d.", (int)buttonIndex, (int)[alertViewLocal tag]);
    [alertViewLocal close];
}

- (void) submitInformation: (Store *) storeValue {
    [self saveStoreAndAssignToTheSession:storeValue];
}

- (void) submitInformationStoreSelect: (Store *) storeValue {
    [self saveStoreAndAssignToTheSession:storeValue];
}

- (void) saveStoreAndAssignToTheSession: (Store *) storeValue {
    [alertView close];
    StoreAPI *storeApi = [[StoreAPI alloc] init];
    NSArray *array;
    if (storeValue) {
        array = [NSArray arrayWithObject:storeValue];
        [storeApi insertUserEnteredStoreDataForDB:array];
    }
    [self reloadTableWithNewSyncValues];
    if ([storesArray count] > 0) {
        storeValue.allPrograms = [[User sharedUser] getProgramsForUser];
        storeValue.storeEnteredByUser = YES;
        [[User sharedUser] setCurrentStore:storeValue];
    }
    if (storeValue.storeEnteredByUser) {
        [NSUserDefaultsManager saveBOOLToUserDefaults:YES withKey:StoreEnteredByUser];
    } else {
        [NSUserDefaultsManager saveBOOLToUserDefaults:NO withKey:StoreEnteredByUser];
    }
    [self saveUserSelectedStoreDetailsToDefaultsManager: storeValue];
    [self navigateToHomeScreen];
}

- (void) saveUserSelectedStoreDetailsToDefaultsManager: (Store *) storeValue {
    if (storeValue.storeEnteredByUser) {
        [NSUserDefaultsManager saveObjectToUserDefaults:storeValue.name withKey:StoreNameEnteredByUser];
        [NSUserDefaultsManager saveObjectToUserDefaults:storeValue.address withKey:StoreAddressEnteredByUser];
        [NSUserDefaultsManager saveObjectToUserDefaults:[NSString stringWithFormat:@"%d", storeValue.postCode] withKey:StoreZipCodeEnteredByUser];
    }
}

- (void) checkAppVersion {
    UIWindow *win = [[UIApplication sharedApplication] keyWindow];
    SyncOverlayView *syncOverlayView = [[SyncOverlayView alloc] initWithFrame:CGRectMake(0, 0, win.bounds.size.width, win.bounds.size.height)];
    syncOverlayView.headingTitleLabel.text = @"Checking app version";
    [syncOverlayView showActivityView];
    [win addSubview:syncOverlayView];
    [self.syncManager appUpdateCheckCall:^(BOOL appUpdateCheckCall, NSError *error){
        if (appUpdateCheckCall) {
            if ([[NSUserDefaultsManager getObjectFromUserDeafults:UPDATEMETHOD] isEqualToString:ForcedUpdateMethod]) {
                [syncOverlayView removeFromSuperview];
                UIAlertView *alert = [[UIAlertView alloc] init];
                alert.tag = 2;
                [[alert initWithTitle:@"Update Required" message: @"Tap on this link to update" delegate: self cancelButtonTitle:@"Download Link" otherButtonTitles: nil] show];
            } else if ([[NSUserDefaultsManager getObjectFromUserDeafults:UPDATEMETHOD] isEqualToString:ManualUpdateMethod]) {
                [syncOverlayView removeFromSuperview];
                UIAlertView *alert = [[UIAlertView alloc] init];
                alert.tag = 3;
                [[alert initWithTitle:@"Update Available" message: @"Tap on this buttons to either update or cancel" delegate: self cancelButtonTitle:@"Cancel" otherButtonTitles: @"Upgrade", nil] show];
            } else {
                [syncOverlayView removeFromSuperview];
                [self downloadOriginalData];
            }
        } else {
            [syncOverlayView removeFromSuperview];
            [self downloadOriginalData];
        }
        NSLog(@"appid %d", appUpdateCheckCall);
    }];
}

- (void) downloadOriginalData {
    UIWindow *win = [[UIApplication sharedApplication] keyWindow];
    self.syncOverlay = [[SyncOverlayView alloc] initWithFrame:CGRectMake(0, 0, win.bounds.size.width, win.bounds.size.height)];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.syncOverlay.frame = CGRectMake(0, 0, 768, 1024);
    }
    self.syncOverlay.headingTitleLabel.text = @"Downloading and Processing Data";
    //[self.syncOverlay updateProgress];
    [win addSubview:self.syncOverlay];
    
    [self.syncManager prepareSQLDatabasesAndTables];
    [self.syncManager callAllTheAPIsAndProcessThem:NO];
}

@end
