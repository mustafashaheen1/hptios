//
//  ContainerViewController.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/18/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "ContainerViewController.h"
#import "Inspection.h"
#import "ProductSelectAutoCompleteViewController.h"
#import "RetailProductListViewController.h"
#import "InspectionStatusViewController.h"
#import "OrderData.h"
#import "CollaborativeInspection.h"
#import "CollaborativeAPIListRequest.h"
#import "InspectionStatus.h"
@interface ContainerViewController ()

@end

@implementation ContainerViewController

@synthesize containerOptionButton;
@synthesize containers;
@synthesize containerRatings;
@synthesize masterID;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self initController];
    }
    return self;
}

-(void)initController
{
    self.orderDataArray = [[Inspection sharedInspection] getOrderData];
    self.containers = [[[User sharedUser] currentStore] getListOfAllContainersForTheStore];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureFonts];
    if (self.masterID) {
        [[Inspection sharedInspection] initInspectionWithMasterId:self.masterID];
        ProductSelectAutoCompleteViewController *productSelectAutoCompleteViewController = [[ProductSelectAutoCompleteViewController alloc] initWithNibName:@"ProductSelectAutoCompleteViewController" bundle:nil];
        [self.navigationController pushViewController:productSelectAutoCompleteViewController animated:NO];
    }
    [self.cameraButton addTarget:self action:@selector(cameraButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    //for scanout - reset container options only once
    BOOL isScanout = [[User sharedUser]checkForScanOut];
    if(isScanout){
        if ([self.containers count] == 1) {
            self.container = [self.containers objectAtIndex:0];
            [self containerOptionSelectedToProceed:[self.containers objectAtIndex:0]];
        }
    }
    
}

- (void) setupNavBar {
    [super setupNavBar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.pageTitle = @"ContainerViewController";
    [self setupNavBar];
    if ([Inspection sharedInspection].auditMasterId && ![[Inspection sharedInspection].auditMasterId isEqualToString:@""]) {
        [[Inspection sharedInspection] cancelBackInspection];
    }
    [self resetPOSupplierRatings];
    //for scanout - do not reset container options everytime the screen loads
    BOOL isScanout = [[User sharedUser]checkForScanOut];
    if(!isScanout){
        if ([self.containers count] == 1) {
            self.container = [self.containers objectAtIndex:0];
            [self setTheProgramIdAndVersionNumber];//set programId/version
            [self containerOptionSelectedToProceed:[self.containers objectAtIndex:0]];
        }
    }
    
    [self initNotificationCenterListener];
    //self.warningIcon.hidden = YES;
    [Inspection sharedInspection].productGroups = [User sharedUser].currentStore.productGroups;
    if([CollobarativeInspection isCollaborativeInspectionsEnabled])
        [self getColloborativeInspections];
    
}

-(void)collaborativeConnectionErrorNotification {
    if([CollobarativeInspection isCollaborativeInspectionsEnabled]){
        [self updateContainerViewNavBar:YES];
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

- (void) viewDidAppear:(BOOL)animated {
    //moved to viewWillAppear since the collab inspections need the groups info
    //[Inspection sharedInspection].productGroups = [User sharedUser].currentStore.productGroups;
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//every time this screen is loaded
-(void)resetPOSupplierRatings{
    [User sharedUser].userSelectedVendorName = nil;
    [NSUserDefaultsManager saveObjectToUserDefaults:nil withKey:VendorNameSelected];
    [User sharedUser].temporaryPONumberFromUserClass = nil;
    [User sharedUser].temporaryGRNFromUserClass = nil;
    [[Inspection sharedInspection] savePONumberToInspection:nil];
    [[Inspection sharedInspection] saveGRNToInspection:nil];
    [User sharedUser].userSelectedLoadId = nil;
}
- (void) checkCountOfCases:(Rating *) currentRating withCount:(NSString*)count{
}
- (IBAction)containerOptionButtonSelected:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveUtilityView" object:self];
    CGFloat xWidth = self.view.frame.size.width - 20.0f;
    CGFloat yHeight = popupDefaultHeight;
    if ([self.containers count] < 5) {
        int heightAfterCalculation = [self.containers count] * 60.0f;
        heightAfterCalculation = heightAfterCalculation + 40;
        yHeight = heightAfterCalculation;
    }
    CGFloat yOffset = (self.view.frame.size.height - yHeight)/2.0f;
    UIPopoverListView *poplistview = [[UIPopoverListView alloc] initWithFrame:CGRectMake(10, yOffset, xWidth, yHeight)];
    poplistview.delegate = self;
    poplistview.datasource = self;
    poplistview.listView.scrollEnabled = TRUE;
    [poplistview setTitle:@"  Select type"];
    [poplistview show];
}

#pragma mark - TO BE implemented by subclasses


- (void)configureFonts {
    self.containerOptionButton.layer.cornerRadius = 0.0;
    self.containerOptionButton.layer.borderWidth = 1.0;
    self.containerOptionButton.layer.borderColor = [[UIColor blackColor] CGColor];
}


-(void) getColloborativeInspections{
    UIWindow *win = [[UIApplication sharedApplication] keyWindow];
    self.syncOverlayView = [[SyncOverlayView alloc] initWithFrame:CGRectMake(0, 0, win.frame.size.width, win.frame.size.height)];
    self.syncOverlayView.headingTitleLabel.text = @"Loading Inspections...";
    
    [self.syncOverlayView showActivityView];
    //[self.syncOverlayView showHideButton];
    [win addSubview:self.syncOverlayView];
    
    CollobarativeInspection* collobarativeInsp = [Inspection sharedInspection].collobarativeInspection;
    if(!collobarativeInsp) {
        collobarativeInsp = [[CollobarativeInspection alloc]init];
        [Inspection sharedInspection].collobarativeInspection = collobarativeInsp;
    }
    
    NSArray *allPONumberObjects =  [[Inspection sharedInspection] getOrderData];
    NSMutableSet *poNumbersMutableSet = [NSMutableSet set];
    for (OrderData *orderData in allPONumberObjects) {
        [poNumbersMutableSet addObject:orderData.PONumber];
    }
    NSArray* poNumbers = [poNumbersMutableSet allObjects];
    //NSInteger storeId = [[User sharedUser]currentStore].storeID;
    
    CollaborativeAPIListRequest *apiRequest = [[CollaborativeAPIListRequest alloc]init];
    apiRequest.po_numbers = [poNumbers mutableCopy];
    //apiRequest.program_id = 0;
    apiRequest.store_id = (int)[User sharedUser].currentStore.storeID;
    
    [collobarativeInsp getAllPOStatus:apiRequest withBlock:^(NSArray *productList, NSError *error) {
        [self.syncOverlayView dismissActivityView];
        [self.syncOverlayView removeFromSuperview];
        //refresh
        [self.productRatingView.ratingsTableView reloadData];
        /*if(!productList && !error && [productList count]>0){
         [[[UIAlertView alloc] initWithTitle:@"Success" message: productList.description delegate: self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
         }else{
         [[[UIAlertView alloc] initWithTitle:@"Error" message: error.description delegate: self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
         }*/
        
    }];
}

#pragma mark - UIPopoverListViewDataSource

- (UITableViewCell *)popoverListView:(UIPopoverListView *)popoverListView
                    cellForIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    if ([self.containers count] >0) {
        Container *container = [self.containers objectAtIndex:indexPath.row];
        cell.textLabel.text = container.name;
        if (container.displayName && ![container.displayName isEqualToString:@""]) {
            cell.textLabel.text = container.displayName;
        }
        cell.detailTextLabel.text = [NSString stringWithFormat:@"ProgramName: %@", container.containerProgramName];
    }
    return cell;
}

- (NSInteger)popoverListView:(UIPopoverListView *)popoverListView
       numberOfRowsInSection:(NSInteger)section
{
    return [self.containers count];
}

#pragma mark - UIPopoverListViewDelegate
- (void)popoverListView:(UIPopoverListView *)popoverListView
     didSelectIndexPath:(NSIndexPath *)indexPath
{
    if ([self.containers count] > 0) {
        [User sharedUser].userSelectedVendorName = @"";
        self.container = [self.containers objectAtIndex:indexPath.row];
        [self containerOptionSelectedToProceed:self.container];
        [self setTheProgramIdAndVersionNumber];
        if ([[Inspection sharedInspection].productGroups count] <=0) {
            [[Inspection sharedInspection] getProductGroups];
        }
    }
}

- (void) containerOptionSelectedToProceed: (Container *) container {
    self.containerRatings = [container getAllRatings];
    
    //Scanout - need to persist the container ratings
    for(Rating *rating in self.containerRatings) {
        BOOL isScanout = [[User sharedUser]checkForScanOut];
        if(isScanout && ![rating.name containsString:@"HMCODES"]){
            NSString* value = [self getPersistedRatingValue:rating.ratingID];
            if(value){
                rating.ratingAnswerFromUI = value;
            }
        }
    }
    
    [NSUserDefaultsManager saveObjectToUserDefaults:container.containerProgramName withKey:selectedProgramName];
    //check if program is distinct or aggregate
    BOOL isDistinctMode = [[Inspection sharedInspection] checkIfProgramIsDistinctMode:container.containerProgramName];
    [NSUserDefaultsManager saveBOOLToUserDefaults:isDistinctMode withKey:programIsDistinctSamplesMode]; //set distinct Samples
    [self.containerOptionButton setTitle:container.name forState:UIControlStateNormal];
    if (container.displayName && ![container.displayName isEqualToString:@""]) {
        [self.containerOptionButton setTitle:container.displayName forState:UIControlStateNormal];
    }
    [[Inspection sharedInspection] setSelectedContainer:container];
    [self addRatingView];
}

- (void) setTheProgramIdAndVersionNumber {
    Container *containerLocal = self.container;
    [NSUserDefaultsManager saveIntegerToUserDefaults:containerLocal.programID withKey:SelectedProgramId];
    [NSUserDefaultsManager saveFloatToUserDefaults:containerLocal.programVersionNumber withKey:SelectedProgramVersion];
}

- (CGFloat)popoverListView:(UIPopoverListView *)popoverListView
   heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (void) addRatingView
{
    ProductRatingViewController *productRatingViewLocal = [[ProductRatingViewController alloc] initWithNibName:kProductRatingViewNIBName bundle:nil];
    productRatingViewLocal.view.frame = CGRectMake(0, 55, self.view.frame.size.width, self.view.frame.size.height);
    productRatingViewLocal.delegate = self;
    productRatingViewLocal.ratingsGlobal = self.containerRatings;
    [productRatingViewLocal.ratingsTableView reloadData];
    productRatingViewLocal.parentView = defineContainerViewController;
    self.productRatingView = productRatingViewLocal;
    [self.view addSubview:productRatingViewLocal.view];
}

- (void) saveButtonTouched {
    if (!self.container) {
        [[[UIAlertView alloc] initWithTitle:@"Cannot proceed" message: @"Select A Container" delegate: self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    } else {
        [NSUserDefaultsManager saveObjectToUserDefaults:self.container.displayName withKey:INSPECTION_TYPE];
        InspectionStatus *inspectionStatus = [[InspectionStatus alloc]init];
        [inspectionStatus getAllStatuses:self.container.displayName];
        [self postNotificationToRemoveUtilityView];
        if (![[Inspection sharedInspection] checkForDateTime] && [[Inspection sharedInspection] checkForOrderData] && ((![[Inspection sharedInspection].poNumberGlobal isEqualToString:@"None"]) && (![[Inspection sharedInspection].grnGlobal isEqualToString:@"None"]))) {
            [[[UIAlertView alloc] initWithTitle:@"Cannot proceed" message: @"Select a date for the PO Number" delegate: self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        } else {
            UIWindow *win = [[UIApplication sharedApplication] keyWindow];
            self.syncOverlayView = [[SyncOverlayView alloc] initWithFrame:CGRectMake(0, 0, win.frame.size.width, win.frame.size.height)];
            self.syncOverlayView.headingTitleLabel.text = SavingContainerRatings;
            [self.syncOverlayView showActivityView];
            [win addSubview:self.syncOverlayView];
            [self.productRatingView submitAnswersTouched:self];
        }
    }
}

- (void) cameraButtonTouched {
    [self postNotificationToRemoveUtilityView];
    [super cameraButtonTouched];
}



// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [super imagePickerController:picker didFinishPickingMediaWithInfo:info];
    return;
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}


- (void) postNotificationToRemoveUtilityView {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveUtilityView" object:self];
}

//- (void) forwardButtonTouched {
//    ProductSelectAutoCompleteViewController *productSelectAutoCompleteViewController = [[ProductSelectAutoCompleteViewController alloc] initWithNibName:@"ProductSelectAutoCompleteViewController" bundle:nil];
//    [self.navigationController pushViewController:productSelectAutoCompleteViewController animated:YES];
//}

#pragma mark - RatingView Controller delegate method.

- (void) proceedToNextGroup:(NSDictionary *) ratingsReponses withSuccess:(BOOL)success {
    if (success) {
        self.container.ratingsFromUI = [[NSMutableArray alloc] init];
        if ([ratingsReponses count] > 0) {
            for (Rating *rating in ratingsReponses) {
                [self.container addRating:rating];
                //Scanout - need to persist the container ratings
                BOOL isScanout = [[User sharedUser]checkForScanOut];
                if(isScanout && ![rating.name containsString:@"HMCODES"]){
                    [self persistContainerRating:rating.ratingID ratingValue:rating.ratingAnswerFromUI];
                }
            }
        }
        //if saved inspection for a matching PONumber and supplier exists - resume the saved inspection
        SavedInspection *savedInspection =[self getSavedInspectionIfExistsForPONumber];
        if(savedInspection)
            [self resumeSavedInspection:savedInspection];
        else
            [self saveContainer];
    } else {
        [self.syncOverlayView dismissActivityView];
        [self.syncOverlayView removeFromSuperview];
    }
}
//save rating to device with id as key and string value
-(void) persistContainerRating:(int)ratingId ratingValue:(NSString*)ratingValue{
    [NSUserDefaultsManager saveObjectToUserDefaults:ratingValue withKey:[NSString stringWithFormat:@"%d",ratingId]];
}

-(NSString*)getPersistedRatingValue:(int)ratingId{
    NSString* value = [NSUserDefaultsManager getObjectFromUserDeafults:[NSString stringWithFormat:@"%d",ratingId]];
    return value;
}

- (void) initInspectionAndSaveContainerRatings {
    if (!self.masterID) {
        [Inspection sharedInspection].containerId = [NSString stringWithFormat:@"%d", self.container.containerID];
        [[Inspection sharedInspection] initInspection];
    }
    [[Inspection sharedInspection] setSavedContainer:self.container];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        [[Inspection sharedInspection] saveContainerImagesToDB];
        [[Inspection sharedInspection] saveContainerRatingsToDB];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.syncOverlayView dismissActivityView];
            [self.syncOverlayView removeFromSuperview];
            [[Inspection sharedInspection] finishInspection];
            [self.navigationController popViewControllerAnimated:YES];
        });
    });
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        //[self.navigationController popViewControllerAnimated:YES];
        [self.syncOverlayView dismissActivityView];
        [self.syncOverlayView removeFromSuperview];
    } else {
        [self initInspectionAndSaveContainerRatings];
    }
}

- (NSString*) findSavedInspectionMasterIdForPONumber:(NSString*)selectedPONumber {
    NSDictionary *dictionaryFromDefaultsManager = [NSUserDefaultsManager getObjectFromUserDeafults:PONUMBER_DICT];
    if (dictionaryFromDefaultsManager) {
        NSArray *keys = [dictionaryFromDefaultsManager allKeys];
        NSString *poNumberInDict = @"";
        for (NSString *key in keys) {
            poNumberInDict = [dictionaryFromDefaultsManager objectForKey:key];
            if([poNumberInDict isEqualToString:selectedPONumber]){
                return key;
            }
        }
    }
    return nil;
}
- (NSString*) findSavedInspectionMasterIdForGRN:(NSString*)selectedGRN {
    NSDictionary *dictionaryFromDefaultsManager = [NSUserDefaultsManager getObjectFromUserDeafults:GRN_DICT];
    if (dictionaryFromDefaultsManager) {
        NSArray *keys = [dictionaryFromDefaultsManager allKeys];
        NSString *poNumberInDict = @"";
        for (NSString *key in keys) {
            poNumberInDict = [dictionaryFromDefaultsManager objectForKey:key];
            if([poNumberInDict isEqualToString:selectedGRN]){
                return key;
            }
        }
    }
    return nil;
}
-(SavedInspection*) getSavedInspectionIfExistsForPONumber{
    NSArray* savedInspections = [[User sharedUser] getAllSavedInspections];
    //for(SavedInspection *savedInspection in savedInspections){
    //    NSString* auditMasterId = savedInspection.auditMasterId;
    NSString* selectedPO = [Inspection sharedInspection].poNumberGlobal;
    NSString* selectedGRN = [Inspection sharedInspection].grnGlobal;
    NSString* auditMasterIdForSavedInspection;
    if((![selectedPO  isEqual: @""]) && (selectedPO != nil))
        auditMasterIdForSavedInspection = [self findSavedInspectionMasterIdForPONumber:selectedPO];
    else
        auditMasterIdForSavedInspection = [self findSavedInspectionMasterIdForGRN:selectedGRN];
    SavedInspection *savedInspectionFromStorage = nil;
    if(auditMasterIdForSavedInspection) { //resume inspection
        //find name of inspection
        for(SavedInspection *savedInspection in savedInspections){
            if([savedInspection.auditMasterId isEqualToString:auditMasterIdForSavedInspection])
                savedInspectionFromStorage = savedInspection;
        }
    }
    return savedInspectionFromStorage;
}

-(void) resumeSavedInspection:(SavedInspection*)savedInspection {
    [[Inspection sharedInspection] resumeSavedInspection:savedInspection.auditMasterId];
    [Inspection sharedInspection].inspectionName = savedInspection.inspectionName;
    [self.syncOverlayView dismissActivityView];
    [self.syncOverlayView removeFromSuperview];
    if (savedInspection.auditsCount > 0) {
        InspectionStatusViewController *inspectionViewController = [[InspectionStatusViewController alloc] initWithNibName:@"InspectionStatusViewController" bundle:nil];
        [self.navigationController pushViewController:inspectionViewController animated:YES];
    } else {
        ProductSelectAutoCompleteViewController *productSelectAutoCompleteViewController = [[ProductSelectAutoCompleteViewController alloc] initWithNibName:@"ProductSelectAutoCompleteViewController" bundle:nil];
        [self.navigationController pushViewController:productSelectAutoCompleteViewController animated:YES];
    }
}
/*
 -(void) resumeSavedInspectionIfExistsForPONumber {
 BOOL savedInspectionExistsForPONumber = NO;
 
 NSArray* savedInspections = [[User sharedUser] getAllSavedInspections];
 //for(SavedInspection *savedInspection in savedInspections){
 //    NSString* auditMasterId = savedInspection.auditMasterId;
 NSString* selectedPO = [Inspection sharedInspection].poNumberGlobal;
 NSString* auditMasterIdForSavedInspection = [self findSavedInspectionMasterIdForPONumber:selectedPO];
 if(auditMasterIdForSavedInspection) { //resume inspection
 savedInspectionExistsForPONumber = YES;
 //find name of inspection
 SavedInspection *savedInspectionFromStorage = nil;
 for(SavedInspection *savedInspection in savedInspections){
 if([savedInspection.auditMasterId isEqualToString:auditMasterIdForSavedInspection])
 savedInspectionFromStorage =savedInspection;
 }
 [[Inspection sharedInspection] resumeSavedInspection:auditMasterIdForSavedInspection];
 [Inspection sharedInspection].inspectionName = savedInspectionFromStorage.inspectionName;
 if (savedInspectionFromStorage.auditsCount > 0) {
 InspectionStatusViewController *inspectionViewController = [[InspectionStatusViewController alloc] initWithNibName:@"InspectionStatusViewController" bundle:nil];
 [self.navigationController pushViewController:inspectionViewController animated:YES];
 } else {
 ProductSelectAutoCompleteViewController *productSelectAutoCompleteViewController = [[ProductSelectAutoCompleteViewController alloc] initWithNibName:@"ProductSelectAutoCompleteViewController" bundle:nil];
 [self.navigationController pushViewController:productSelectAutoCompleteViewController animated:YES];
 }
 }
 
 }
 */
- (void) saveContainer {
    __block NSArray *productGroups;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        if ([[Inspection sharedInspection].productGroups count] <=0) {
            productGroups =  [[Inspection sharedInspection] getProductGroups];
            if ([[Inspection sharedInspection] checkForOrderData]) {
                NSLog(@"%@", [DeviceManager getCurrentTimeString]);
                NSSet *set;
                NSString *poNumber = [Inspection sharedInspection].poNumberGlobal;
                if((![poNumber  isEqual: @""]) && (poNumber != nil))
                    set = [OrderData getItemNumbersForPONumberSelected];
                else
                    set = [OrderData getItemNumbersForGRNSelected];
                NSLog(@"%@", [DeviceManager getCurrentTimeString]);
                productGroups = [[Inspection sharedInspection] filteredProductGroups:set];
            }
        } else {
            productGroups = [Inspection sharedInspection].productGroups;
        }
        if ([productGroups count] < 1) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self handleSaveWithNoProducts];
            });
        } else {
            if (!self.masterID) {
                [Inspection sharedInspection].containerId = [NSString stringWithFormat:@"%d", self.container.containerID];
                [[Inspection sharedInspection] initInspection];
            }
            [[Inspection sharedInspection] setSavedContainer:self.container];
            [[Inspection sharedInspection] saveContainerImagesToDB];
            [[Inspection sharedInspection] saveContainerRatingsToDB];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.syncOverlayView dismissActivityView];
                [self.syncOverlayView removeFromSuperview];
                [self showProductListScreen];
            });
        }
    });
}

-(void)handleSaveWithNoProducts
{
    if ([[[User sharedUser] getAuditorRole] isEqualToString:AUDITOR_ROLE_SCANOUT]) {
        [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Submit Scan Out"] message: @"" delegate: self cancelButtonTitle:@"Cancel" otherButtonTitles: @"Submit", nil] show];
    }
    else
        [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"No products found for %@", self.container.name] message: @"This will finish the inspection" delegate: self cancelButtonTitle:@"Cancel" otherButtonTitles: @"Submit", nil] show];
}

-(void)showProductListScreen
{
    ProductSelectAutoCompleteViewController *productSelectAutoCompleteViewController = [[ProductSelectAutoCompleteViewController alloc] initWithNibName:@"ProductSelectAutoCompleteViewController" bundle:nil];
    [self.navigationController pushViewController:productSelectAutoCompleteViewController animated:YES];
}

- (void) setupPhotosAlbum {
    [super setupPhotosAlbum];
    //    self.galleryView = [[VerticalGalleryViewController alloc] initWithNibName:@"VerticalGalleryViewController" bundle:nil];
    //    self.galleryView.rawImagesArray = [[User sharedUser] allImages];
    //    [self.galleryView addContentsToScrollView];
    //    [self.navigationController pushViewController:self.galleryView animated:YES];
}

- (void) setupPhotoViewer {
    self.galleryView = [[VerticalGalleryViewController alloc] initWithNibName:@"VerticalGalleryViewController" bundle:nil];
    self.galleryView.rawImagesArray = [[User sharedUser] allImages];
    self.galleryView.productView = NO;
    [self.galleryView addContentsToScrollView];
    [self.navigationController pushViewController:self.galleryView animated:YES];
}

@end
