//
//  ParentNavigationViewController.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/13/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "ParentNavigationViewController.h"
#import "DefectsViewController.h"
#import "InspectionStatusViewController.h"
#import "InspectionStatusViewControllerRetailViewController.h"
#import "DefectsViewController.h"
#import "SettingsViewController.h"
#import "ProductSelectAutoCompleteViewController.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "Image.h"
#import "Inspection.h"
#import "SyncManager.h"
#import "SyncOverlayView.h"
#import "OrderDataDBHelper.h"
#import "AGImagePickerController.h"
#import "UIImage+Resize.h"
#import "CESettingsViewController.h"

#define widthOfButtons 40
#define heightOfButtons 50
#define inspectionButtonsFontSize 8
#define orderDataButtonsFontSize 12
#define squareShapedSize 320

@interface ParentNavigationViewController () <SettingsViewControllerDelegate>

@property (nonatomic, retain) SyncManager *syncManager;
//@property (nonatomic, retain) SyncOverlayView *syncOverlayView;
@end

@implementation ParentNavigationViewController

@synthesize arrowBackIcon;
@synthesize launcherIcon;
@synthesize insightsLabel;
@synthesize backButton;
@synthesize refreshButton;
@synthesize uploadButton;
@synthesize pageTitle;
@synthesize addButton;
@synthesize forwardButton;
@synthesize cameraButton;
@synthesize scanButton;
@synthesize cancelButton;
@synthesize finishButton;
@synthesize saveButton;
@synthesize printButton;
@synthesize saveForInspectionStatus;
@synthesize finishForInspectionStatus;
@synthesize cancelInspectionStatus;
@synthesize markButton;
@synthesize settingsButton;
@synthesize actionSheet;
@synthesize library;
@synthesize assetGroups;
@synthesize imageGalleryButton;
@synthesize listButton;
@synthesize duplicateButton;
@synthesize infoButton;
@synthesize infoButtonGrey;
@synthesize saveForwardButton;
@synthesize orderDataSyncButton;
@synthesize syncManager;
@synthesize syncOverlayView;
@synthesize oldImagePicker;
@synthesize undoImageEditButton;
@synthesize redoImageEditButton;
@synthesize discardButton;
@synthesize forwardArrow;
@synthesize backArrow;
@synthesize warningIcon;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupNavBar];
    //moved to the point of choosing camera option - fix leak
    //self.oldImagePicker = [[UIImagePickerController alloc] init];
    //self.library = [[ALAssetsLibrary alloc] init];
	// Do any additional setup after loading the view.
}

- (void) setupNavBar {
    [self.navigationController setNavigationBarHidden: NO];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.navigationController.navigationBar.translucent = NO;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self backButtonSetup];
    [self rightNavButtonsSetup];
}

- (void) backButtonSetup {
    
    arrowBackIcon = [[UIImageView alloc] initWithFrame:CGRectMake(-10, 5, 10.0, 20.0)];
    arrowBackIcon.image = [UIImage imageNamed:@"arrowwhiteback.png"];

    launcherIcon = [[UIImageView alloc] initWithFrame:CGRectMake(arrowBackIcon.frame.origin.x + arrowBackIcon.frame.size.width + 2, 0, 30.0, 30.0)];
    launcherIcon.image = [UIImage imageNamed:@"ic_launcher.png"];
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    if ([[[User sharedUser] getAuditorRole] isEqualToString:AUDITOR_ROLE_RETAIL] || [appName isEqualToString:@"Retail-Insights"] ) {
        launcherIcon.image = [UIImage imageNamed:@"retail_icon.png"];
    }
    
    //change here 80.0 for the icon text
    insightsLabel = [[UILabel alloc]initWithFrame:CGRectMake(launcherIcon.frame.origin.x + launcherIcon.frame.size.width + 2, 0, 80.0, 30.0)];
    insightsLabel.textColor = [UIColor whiteColor];
    insightsLabel.backgroundColor = [UIColor clearColor];
    insightsLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:(11.0)];
    insightsLabel.text = [NSString stringWithFormat:@"Insights"];
    //NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    if ([[[User sharedUser] getAuditorRole] isEqualToString:AUDITOR_ROLE_SCANOUT] || [appName isEqualToString:@"Scan Out"]) {
        launcherIcon.image = [UIImage imageNamed:@"ic_launcher_scanout.png"];
        insightsLabel.text = [NSString stringWithFormat:@"Scan Out"];
    }
    if([appName isEqualToString:@"PalletShipping"]){
        insightsLabel = [[UILabel alloc]initWithFrame:CGRectMake(launcherIcon.frame.origin.x + launcherIcon.frame.size.width + 2, 0, 80.0, 30.0)];
        insightsLabel.textColor = [UIColor whiteColor];
        insightsLabel.backgroundColor = [UIColor clearColor];
        insightsLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:(11.0)];
        insightsLabel.text = [NSString stringWithFormat:@"PalletShipping"];
        launcherIcon.image = [UIImage imageNamed:@"ic_launcher_scanout.png"];
    }
    if([appName isEqualToString:@"CodeExplorer"]){
        insightsLabel = [[UILabel alloc]initWithFrame:CGRectMake(launcherIcon.frame.origin.x + launcherIcon.frame.size.width + 2, 0, 100.0, 30.0)];
        insightsLabel.textColor = [UIColor whiteColor];
        insightsLabel.backgroundColor = [UIColor clearColor];
        launcherIcon.image = [UIImage imageNamed:@"ic_launcher_scanout.png"];
        insightsLabel.text = [NSString stringWithFormat:@"CodeExplorer"];
        insightsLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:(13.0)];
    }
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    if(([bundleIdentifier isEqualToString:@"com.trimble.harvestmark.enterprise.inventory"]) || ([bundleIdentifier isEqualToString:@"com.trimble.harvestmark.inventory"]))
    {
        launcherIcon.image = [UIImage imageNamed:@"ic_launcher_blue.png"];
        insightsLabel.text = [NSString stringWithFormat:@"  Inventory"];
    }
    backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.bounds = CGRectMake(0, 0, insightsLabel.frame.size.width + insightsLabel.frame.origin.x, 30.0);
    backButton.titleEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    
    //NSArray *viewControllers = self.navigationController.viewControllers;
    
//    if ([viewControllers count] > 2) {
//        [backButton addSubview:arrowBackIcon];
//        [backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
//    }
    [backButton addSubview:launcherIcon];
    [backButton addSubview:insightsLabel];
    
    settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    settingsButton.bounds = CGRectMake(5, 0, widthOfButtons, heightOfButtons);
    [[settingsButton imageView] setContentMode: UIViewContentModeScaleAspectFit];
    [settingsButton setImage:[UIImage imageNamed:@"ic_cog.png"] forState:UIControlStateNormal];
    [settingsButton addTarget:self action:@selector(settingsButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    if((IS_IPHONE5) || (IS_IPHONE4)){
    cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelButton.bounds = CGRectMake(0, 0, widthOfButtons, heightOfButtons);
    
    [[cancelButton imageView] setContentMode: UIViewContentModeScaleAspectFit];
    [cancelButton setImage:[UIImage imageNamed:@"ic_remove.png"] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelInspectionStatusTouched) forControlEvents:UIControlEventTouchUpInside];
    
    finishButton = [UIButton buttonWithType:UIButtonTypeCustom];

    finishButton.bounds = CGRectMake(0, 0, widthOfButtons, heightOfButtons);
    
    [[finishButton imageView] setContentMode: UIViewContentModeScaleAspectFit];
    [finishButton setImage:[UIImage imageNamed:@"ic_accept.png"] forState:UIControlStateNormal];
    [finishButton addTarget:self action:@selector(finishForInspectionStatusTouched) forControlEvents:UIControlEventTouchUpInside];
    saveButton = [UIButton buttonWithType:UIButtonTypeCustom];

        saveButton.bounds = CGRectMake(0, 0, widthOfButtons, heightOfButtons);
    
    [[saveButton imageView] setContentMode: UIViewContentModeScaleAspectFit];
    [saveButton setImage:[UIImage imageNamed:@"ic_save.png"] forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(saveButtonTouched) forControlEvents:UIControlEventTouchUpInside];
        listButton = [UIButton buttonWithType:UIButtonTypeCustom];
        listButton.bounds = CGRectMake(0, 0, widthOfButtons, heightOfButtons);
        [[listButton imageView] setContentMode: UIViewContentModeScaleAspectFit];
        [listButton setImage:[UIImage imageNamed:@"ic_list.png"] forState:UIControlStateNormal];
        [listButton addTarget:self action:@selector(listButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    }
    warningIcon = [UIButton buttonWithType:UIButtonTypeCustom];
    warningIcon.bounds = CGRectMake(5, 0, widthOfButtons, heightOfButtons);
    [[warningIcon imageView] setContentMode: UIViewContentModeScaleAspectFit];
    [warningIcon setImage:[UIImage imageNamed:@"ic_warning_yellow.png"] forState:UIControlStateNormal];
    [warningIcon addTarget:self action:@selector(warningIconTouched) forControlEvents:UIControlEventTouchUpInside];
    
    if ([pageTitle isEqualToString:@"SettingsViewController"] || [pageTitle isEqualToString:@"CESettingsViewController"] || [pageTitle isEqualToString:@"PalletShippingScanCodeViewController"]) {
        [backButton addSubview:arrowBackIcon];
        [backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithCustomView:backButton], nil];
    } else if ([pageTitle isEqualToString:@"UserLoginViewController"]) {
//         if([appName isEqualToString:@"CodeExplorer"]){
//             self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithCustomView:backButton], nil];
//         }else
        self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithCustomView:backButton], [[UIBarButtonItem alloc] initWithCustomView:settingsButton], nil];
    } else if ([pageTitle isEqualToString:@"VerticalGalleryViewController"]) {
        [backButton addSubview:arrowBackIcon];
        [backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithCustomView:backButton], nil];
    } else if ([pageTitle isEqualToString:@"UserLocationSelectViewController"]) {
        self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithCustomView:backButton], [[UIBarButtonItem alloc] initWithCustomView:settingsButton], nil];
    } else if ([pageTitle isEqualToString:@"HomeScreenViewController"]) {
        self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithCustomView:backButton], [[UIBarButtonItem alloc] initWithCustomView:settingsButton], nil];
    } else if ([pageTitle isEqualToString:@"HPTHomeViewController"]) {
        self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithCustomView:backButton], [[UIBarButtonItem alloc] initWithCustomView:settingsButton], nil];
    }else if ([pageTitle isEqualToString:@"InspectionStatusViewController"]) {
        if((!IS_IPHONE5) && (!IS_IPHONE4)){
        self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithCustomView:backButton], nil];
        }else{
            self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithCustomView:backButton],[[UIBarButtonItem alloc] initWithCustomView:saveButton], [[UIBarButtonItem alloc] initWithCustomView:cancelButton], [[UIBarButtonItem alloc] initWithCustomView:finishButton],[[UIBarButtonItem alloc] initWithCustomView:listButton], nil];
            if ([[User sharedUser] checkForRetailInsights]) {
                self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithCustomView:finishButton], [[UIBarButtonItem alloc] initWithCustomView:cancelButton], nil];
            }
        }
    } else if ([pageTitle isEqualToString:@"InspectionStatusViewControllerRetailViewController"]) {
        self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithCustomView:backButton], nil];
    } else if ([pageTitle isEqualToString:@"StarQualityViewController"]) {
        [backButton addSubview:arrowBackIcon];
        [backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithCustomView:backButton], nil];
    } else if ([pageTitle isEqualToString:@"ProductViewController"]) {
        self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithCustomView:backButton], nil];// [[UIBarButtonItem alloc] initWithCustomView:settingsButton], nil];
    }else if ([pageTitle isEqualToString:@"PalletShippingRatingViewController"]) {
        [backButton addSubview:arrowBackIcon];
        [backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithCustomView:backButton], nil];// [[UIBarButtonItem alloc] initWithCustomView:settingsButton], nil];
    }else if ([pageTitle isEqualToString:@"ApplyToAllViewController"]) {
        [backButton addSubview:arrowBackIcon];
        [backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithCustomView:backButton],nil];// [[UIBarButtonItem alloc] initWithCustomView:settingsButton], nil];
    } else if ([pageTitle isEqualToString:@"DefectsViewController"]) {
        self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithCustomView:backButton], nil];// [[UIBarButtonItem alloc] initWithCustomView:settingsButton], nil];
    } else if ([pageTitle isEqualToString:@"ProductSelectAutoCompleteViewController"]) {
        self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithCustomView:backButton], nil];// [[UIBarButtonItem alloc] initWithCustomView:settingsButton], nil];
    } else if ([pageTitle isEqualToString:@"ContainerViewController"]) {
        [backButton addSubview:arrowBackIcon];
        [backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithCustomView:backButton],nil];// [[UIBarButtonItem alloc] initWithCustomView:settingsButton], nil];
    } else if ([pageTitle isEqualToString:@"WebviewForProductViewController"]) {
        [backButton addSubview:arrowBackIcon];
        [backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithCustomView:backButton], nil];// [[UIBarButtonItem alloc] initWithCustomView:settingsButton], nil];
    } else if ([pageTitle isEqualToString:@"WebViewForDefectsViewController"]) {
        [backButton addSubview:arrowBackIcon];
        [backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithCustomView:backButton], nil];// [[UIBarButtonItem alloc] initWithCustomView:settingsButton], nil];
    }else if ([pageTitle isEqualToString:@"ScannerView"]) {
        //[backButton addSubview:arrowBackIcon];
        [backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithCustomView:backButton], nil];// [[UIBarButtonItem alloc] initWithCustomView:settingsButton], nil];
    } else if ([pageTitle isEqualToString:@"CECodeDetailsViewController"]) {
        [backButton addSubview:arrowBackIcon];
        [backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithCustomView:backButton], nil];// [[UIBarButtonItem alloc] initWithCustomView:settingsButton], nil];
    }else if ([pageTitle isEqualToString:@"CompleteInspectionsListViewController"]) {
        [backButton addSubview:arrowBackIcon];
        [backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithCustomView:backButton], nil];
    }else if ([pageTitle isEqualToString:kNibFileImageEditViewController]) {
        [backButton addSubview:arrowBackIcon];
        [backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithCustomView:backButton], nil];// [[UIBarButtonItem alloc] initWithCustomView:settingsButton], nil];
    }else if ([pageTitle isEqualToString:@"CEScanViewController"]) {
        [backButton removeFromSuperview];
        backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        backButton.bounds = CGRectMake(0, 0, insightsLabel.frame.size.width + insightsLabel.frame.origin.x, 30.0);
        backButton.titleEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
        [backButton addSubview:launcherIcon];
        [backButton addSubview:insightsLabel];
        self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithCustomView:backButton], [[UIBarButtonItem alloc] initWithCustomView:settingsButton], nil];
    }
    else {
        [backButton addSubview:arrowBackIcon];
        [backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithCustomView:backButton], [[UIBarButtonItem alloc] initWithCustomView:settingsButton], nil];
    }

}

- (void) rightNavButtonsSetup {
    
    
    infoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    infoButton.bounds = CGRectMake(0, 0, widthOfButtons, heightOfButtons);
    [[infoButton imageView] setContentMode: UIViewContentModeScaleAspectFit];
    [infoButton setImage:[UIImage imageNamed:@"ic_info_white.png"] forState:UIControlStateNormal];
    [infoButton addTarget:self action:@selector(settingsInfoButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    
    infoButtonGrey = [UIButton buttonWithType:UIButtonTypeCustom];
    infoButtonGrey.bounds = CGRectMake(0, 0, widthOfButtons, heightOfButtons);
    [[infoButtonGrey imageView] setContentMode: UIViewContentModeScaleAspectFit];
    [infoButtonGrey setImage:[UIImage imageNamed:@"ic_info.png"] forState:UIControlStateNormal];
    [infoButtonGrey addTarget:self action:@selector(refreshButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    
    duplicateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    duplicateButton.bounds = CGRectMake(0, 0, widthOfButtons, heightOfButtons);
    [[duplicateButton imageView] setContentMode: UIViewContentModeScaleAspectFit];
    [duplicateButton setImage:[UIImage imageNamed:@"ic_queue_add.png"] forState:UIControlStateNormal];
    [duplicateButton addTarget:self action:@selector(duplicateButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    
    imageGalleryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    imageGalleryButton.bounds = CGRectMake(0, 0, widthOfButtons, heightOfButtons);
    [[imageGalleryButton imageView] setContentMode: UIViewContentModeScaleAspectFit];
    [imageGalleryButton setImage:[UIImage imageNamed:@"ic_menu_gallery.png"] forState:UIControlStateNormal];
    [imageGalleryButton addTarget:self action:@selector(refreshButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
    refreshButton.bounds = CGRectMake(0, 0, widthOfButtons, heightOfButtons);
    [[refreshButton imageView] setContentMode: UIViewContentModeScaleAspectFit];
    [refreshButton setImage:[UIImage imageNamed:@"ic_location_arrow.png"] forState:UIControlStateNormal];
    [refreshButton addTarget:self action:@selector(refreshButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    
    uploadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    uploadButton.bounds = CGRectMake(0, 0, widthOfButtons, heightOfButtons);
    [[uploadButton imageView] setContentMode: UIViewContentModeScaleAspectFit];
    [uploadButton setImage:[UIImage imageNamed:@"ic_upload.png"] forState:UIControlStateNormal];
    [uploadButton addTarget:self action:@selector(uploadButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    
    if((!IS_IPHONE5) && (!IS_IPHONE4)){
    cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelButton.bounds = CGRectMake(0, 0, widthOfButtons, heightOfButtons);
    
    [[cancelButton imageView] setContentMode: UIViewContentModeScaleAspectFit];
    [cancelButton setImage:[UIImage imageNamed:@"ic_remove.png"] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelInspectionStatusTouched) forControlEvents:UIControlEventTouchUpInside];
    
    finishButton = [UIButton buttonWithType:UIButtonTypeCustom];

    finishButton.bounds = CGRectMake(0, 0, widthOfButtons, heightOfButtons);
    
    [[finishButton imageView] setContentMode: UIViewContentModeScaleAspectFit];
    [finishButton setImage:[UIImage imageNamed:@"ic_accept.png"] forState:UIControlStateNormal];
    [finishButton addTarget:self action:@selector(finishForInspectionStatusTouched) forControlEvents:UIControlEventTouchUpInside];
    saveButton = [UIButton buttonWithType:UIButtonTypeCustom];

        saveButton.bounds = CGRectMake(0, 0, widthOfButtons, heightOfButtons);
    
    [[saveButton imageView] setContentMode: UIViewContentModeScaleAspectFit];
    [saveButton setImage:[UIImage imageNamed:@"ic_save.png"] forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(saveButtonTouched) forControlEvents:UIControlEventTouchUpInside];
        printButton = [UIButton buttonWithType:UIButtonTypeCustom];

            printButton.bounds = CGRectMake(0, 0, widthOfButtons, heightOfButtons);
        
        [[printButton imageView] setContentMode: UIViewContentModeScaleAspectFit];
        [printButton setImage:[UIImage imageNamed:@"ic_print.png"] forState:UIControlStateNormal];
        [printButton addTarget:self action:@selector(printButtonTouched) forControlEvents:UIControlEventTouchUpInside];
        listButton = [UIButton buttonWithType:UIButtonTypeCustom];
        listButton.bounds = CGRectMake(0, 0, widthOfButtons, heightOfButtons);
        [[listButton imageView] setContentMode: UIViewContentModeScaleAspectFit];
        [listButton setImage:[UIImage imageNamed:@"ic_list.png"] forState:UIControlStateNormal];
        [listButton addTarget:self action:@selector(listButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    }
    addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.bounds = CGRectMake(0, 0, widthOfButtons, heightOfButtons);
    [[addButton imageView] setContentMode: UIViewContentModeScaleAspectFit];
    [addButton setImage:[UIImage imageNamed:@"ic_menu_btn_add.png"] forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(addButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    
    forwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    forwardButton.bounds = CGRectMake(0, 0, widthOfButtons, heightOfButtons);
    [[forwardButton imageView] setContentMode: UIViewContentModeScaleAspectFit];
    [forwardButton setImage:[UIImage imageNamed:@"ic_menu_send.png"] forState:UIControlStateNormal];
    [forwardButton addTarget:self action:@selector(forwardButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    
    forwardArrow = [UIButton buttonWithType:UIButtonTypeCustom];
    forwardArrow.bounds = CGRectMake(0, 0, widthOfButtons, heightOfButtons);
    [[forwardArrow imageView] setContentMode: UIViewContentModeScaleAspectFit];
    [forwardArrow setImage:[UIImage imageNamed:@"ic_next_white.png"] forState:UIControlStateNormal];
    [forwardArrow addTarget:self action:@selector(forwardArrowTouched) forControlEvents:UIControlEventTouchUpInside];
    
    backArrow = [UIButton buttonWithType:UIButtonTypeCustom];
    backArrow.bounds = CGRectMake(0, 0, widthOfButtons, heightOfButtons);
    [[backArrow imageView] setContentMode: UIViewContentModeScaleAspectFit];
    [backArrow setImage:[UIImage imageNamed:@"ic_previous_white.png"] forState:UIControlStateNormal];
    [backArrow addTarget:self action:@selector(backArrowTouched) forControlEvents:UIControlEventTouchUpInside];
    
    self.cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cameraButton.bounds = CGRectMake(0, 0, widthOfButtons, heightOfButtons);
    [[cameraButton imageView] setContentMode: UIViewContentModeScaleAspectFit];
    [cameraButton setImage:[UIImage imageNamed:@"ic_camera.png"] forState:UIControlStateNormal];
    [cameraButton addTarget:self action:@selector(cameraButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    [self cameraButtonIconDecide];
    
    self.scanButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.scanButton.bounds = CGRectMake(0, 0, widthOfButtons, heightOfButtons);
    [scanButton setImage:[UIImage imageNamed:@"ic_camera.png"] forState:UIControlStateNormal];
    [scanButton addTarget:self action:@selector(scanButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    
    self.saveForwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.saveForwardButton.bounds = CGRectMake(0, 0, widthOfButtons, heightOfButtons);
    [[saveForwardButton imageView] setContentMode: UIViewContentModeScaleAspectFit];
    [saveForwardButton setImage:[UIImage imageNamed:@"ic_menu_forward.png"] forState:UIControlStateNormal];
    [saveForwardButton addTarget:self action:@selector(saveButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    
    markButton = [UIButton buttonWithType:UIButtonTypeCustom];
    markButton.bounds = CGRectMake(0, 0, widthOfButtons, heightOfButtons);
    markButton.titleEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    [[markButton imageView] setContentMode: UIViewContentModeScaleAspectFit];
    [markButton setImage:[UIImage imageNamed:@"ic_accept.png"] forState:UIControlStateNormal];
    [markButton addTarget:self action:@selector(markButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    
    undoImageEditButton = [UIButton buttonWithType:UIButtonTypeCustom];
    undoImageEditButton.bounds = CGRectMake(0, 0, widthOfButtons, heightOfButtons);
    undoImageEditButton.titleEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    [[undoImageEditButton imageView] setContentMode: UIViewContentModeScaleAspectFit];
    [undoImageEditButton setImage:[UIImage imageNamed:@"ic_action_rotate_left.png"] forState:UIControlStateNormal];
    [undoImageEditButton addTarget:self action:@selector(undoButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    
    redoImageEditButton = [UIButton buttonWithType:UIButtonTypeCustom];
    redoImageEditButton.bounds = CGRectMake(0, 0, widthOfButtons, heightOfButtons);
    redoImageEditButton.titleEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    [[redoImageEditButton imageView] setContentMode: UIViewContentModeScaleAspectFit];
    [redoImageEditButton setImage:[UIImage imageNamed:@"ic_action_rotate_right.png"] forState:UIControlStateNormal];
    [redoImageEditButton addTarget:self action:@selector(redoButtonTouched) forControlEvents:UIControlEventTouchUpInside];

    orderDataSyncButton = [UIButton buttonWithType:UIButtonTypeCustom];
    orderDataSyncButton.bounds = CGRectMake(0, 0, widthOfButtons, heightOfButtons);
    orderDataSyncButton.titleEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    [[orderDataSyncButton imageView] setContentMode: UIViewContentModeScaleAspectFit];
    [orderDataSyncButton setImage:[UIImage imageNamed:@"ic_download_white.png"] forState:UIControlStateNormal];
    [orderDataSyncButton addTarget:self action:@selector(orderDataSyncButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    
    self.productInfoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.productInfoButton.bounds = CGRectMake(0, 0, widthOfButtons, heightOfButtons);
    [[self.productInfoButton imageView] setContentMode: UIViewContentModeScaleAspectFit];
    [self.productInfoButton setImage:[UIImage imageNamed:@"ic_menu_info_details.png"] forState:UIControlStateNormal];
    [self.productInfoButton addTarget:self action:@selector(productInfoButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    
    self.addStoreButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addStoreButtonPressed)];
    [self.addStoreButton setTintColor:[UIColor whiteColor]];
    
    self.emailButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.emailButton.bounds = CGRectMake(0, 0, widthOfButtons, heightOfButtons);
    [[self.emailButton imageView] setContentMode: UIViewContentModeScaleAspectFit];
    [self.emailButton setImage:[UIImage imageNamed:@"ic_email.png"] forState:UIControlStateNormal];
    [self.emailButton addTarget:self action:@selector(emailButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    
    discardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    discardButton.bounds = CGRectMake(0, 0, widthOfButtons, heightOfButtons);
    [[discardButton imageView] setContentMode: UIViewContentModeScaleAspectFit];
    [discardButton setImage:[UIImage imageNamed:@"ic_discard.png"] forState:UIControlStateNormal];
    [discardButton addTarget:self action:@selector(discardIconTouched) forControlEvents:UIControlEventTouchUpInside];

    saveForInspectionStatus = [[UIBarButtonItem alloc] initWithTitle:@"SAVE" style:UIBarButtonItemStyleBordered target:self action:@selector(saveForInspectionStatusTouched)];
    [saveForInspectionStatus setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor],  UITextAttributeTextColor, [UIFont boldSystemFontOfSize:inspectionButtonsFontSize], UITextAttributeFont, nil] forState:UIControlStateNormal];
    cancelInspectionStatus = [[UIBarButtonItem alloc] initWithTitle:@"CANCEL" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelInspectionStatusTouched)];
    [cancelInspectionStatus setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor],  UITextAttributeTextColor, [UIFont boldSystemFontOfSize:inspectionButtonsFontSize], UITextAttributeFont, nil] forState:UIControlStateNormal];
    finishForInspectionStatus = [[UIBarButtonItem alloc] initWithTitle:@"FINISH" style:UIBarButtonItemStyleBordered target:self action:@selector(finishForInspectionStatusTouched)];
    [finishForInspectionStatus setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor],  UITextAttributeTextColor, [UIFont boldSystemFontOfSize:inspectionButtonsFontSize], UITextAttributeFont, nil] forState:UIControlStateNormal];
    
    self.logViewButton = [[UIBarButtonItem alloc] initWithTitle:@"LOG" style:UIBarButtonItemStyleBordered target:self action:@selector(logStatusTouched)];
    [self.logViewButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor],  UITextAttributeTextColor, [UIFont boldSystemFontOfSize:12], UITextAttributeFont, nil] forState:UIControlStateNormal];
    
    if ([pageTitle isEqualToString:@"UserLocationSelectViewController"]) {
        //self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: /*[[UIBarButtonItem alloc] initWithCustomView:self.cameraButton],*/ [[UIBarButtonItem alloc] initWithCustomView:refreshButton], nil];
        /*if ([[[User sharedUser] getAuditorRole] isEqualToString:AUDITOR_ROLE_RETAIL]) {
            self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithCustomView:refreshButton], nil];
        }*/
    } else if ([pageTitle isEqualToString:@"HomeScreenViewController"]) {
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: /*[[UIBarButtonItem alloc] initWithCustomView:addButton], */[[UIBarButtonItem alloc] initWithCustomView:uploadButton], [[UIBarButtonItem alloc] initWithCustomView:orderDataSyncButton], nil];
        //self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: /*[[UIBarButtonItem alloc] initWithCustomView:addButton], */ [[UIBarButtonItem alloc] initWithCustomView:uploadButton], [[UIBarButtonItem alloc] initWithCustomView:orderDataSyncButton], self.logViewButton, nil];
        if ([[[User sharedUser] getAuditorRole] isEqualToString:AUDITOR_ROLE_RETAIL] || [[[User sharedUser] getAuditorRole] isEqualToString:AUDITOR_ROLE_SCANOUT]) {
            self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: /*[[UIBarButtonItem alloc] initWithCustomView:addButton], */[[UIBarButtonItem alloc] initWithCustomView:uploadButton], nil];
        }
    } else if ([pageTitle isEqualToString:@"HomeScreenViewController"]) {
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithCustomView:addButton], nil];
    } else if ([pageTitle isEqualToString:@"ContainerViewController"]) {
        [self updateContainerViewNavBar:NO];
    } else if ([pageTitle isEqualToString:@"HPTHomeViewController"]) {
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:[[UIBarButtonItem alloc] initWithCustomView:uploadButton], nil];
    }else if ([pageTitle isEqualToString:@"ProductSelectAutoCompleteViewController"]) {
        [self updateProductListNavBar:NO];
    } else if ([pageTitle isEqualToString:@"ProductViewController"]) {
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithCustomView:saveButton], [[UIBarButtonItem alloc] initWithCustomView:cameraButton],[[UIBarButtonItem alloc] initWithCustomView:duplicateButton], nil];
    } else if ([pageTitle isEqualToString:@"PalletShippingRatingViewController"]) {
           self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithCustomView:saveButton], [[UIBarButtonItem alloc] initWithCustomView:printButton], [[UIBarButtonItem alloc] initWithCustomView:scanButton], nil];
       } else if ([pageTitle isEqualToString:@"InspectionStatusViewController"]) {
        if((!IS_IPHONE5) && (!IS_IPHONE4)){
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithCustomView:finishButton], [[UIBarButtonItem alloc] initWithCustomView:cancelButton], [[UIBarButtonItem alloc] initWithCustomView:saveButton],[[UIBarButtonItem alloc] initWithCustomView:listButton],  nil];
        if ([[User sharedUser] checkForRetailInsights]) {
            self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithCustomView:finishButton], [[UIBarButtonItem alloc] initWithCustomView:cancelButton], nil];
        }
        }
    } else if ([pageTitle isEqualToString:@"InspectionStatusViewControllerRetailViewController"]) {
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithCustomView:finishButton], [[UIBarButtonItem alloc] initWithCustomView:cancelButton], [[UIBarButtonItem alloc] initWithCustomView:saveButton],  nil];
        if ([[User sharedUser] checkForRetailInsights]) {
            self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithCustomView:finishButton], [[UIBarButtonItem alloc] initWithCustomView:cancelButton], nil];
        }
    } else if ([pageTitle isEqualToString:@"DefectsViewController"]) {
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithCustomView:markButton], nil];
    } else if ([pageTitle isEqualToString:@"ScannerView"]) {
        NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        if([appName isEqualToString:@"CodeExplorer"]){
            self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithCustomView:cancelButton], nil];
        }else{
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithCustomView:markButton], nil];
        }
    }else if ([pageTitle isEqualToString:@"StarQualityViewController"]) {
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: nil];
    } else if ([pageTitle isEqualToString:@"SettingsViewController"] || [pageTitle isEqualToString:@"CESettingsViewController"]) {
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithCustomView:infoButton], nil];
    }    else if ([pageTitle isEqualToString:@"CompleteInspectionsListViewController"]) {
        self.navigationItem.rightBarButtonItems = nil;

    } else if ([pageTitle isEqualToString:kNibFileImageEditViewController]) {
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithCustomView:saveButton], [[UIBarButtonItem alloc] initWithCustomView:redoImageEditButton], [[UIBarButtonItem alloc] initWithCustomView:undoImageEditButton], nil];
    }else if ([pageTitle isEqualToString:@"CEScanViewController"]) {
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithCustomView:listButton],nil];
    }else if ([pageTitle isEqualToString:@"CECodeDetailsViewController"]) {
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithCustomView:listButton],[[UIBarButtonItem alloc] initWithCustomView:self.emailButton],nil];
    }
    else if ([pageTitle isEqualToString:@"CEHistoryViewController"]) {
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithCustomView:discardButton],nil];
    }else if ([pageTitle isEqualToString:@"ApplyToAllViewController"]) {
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithCustomView:saveButton], [[UIBarButtonItem alloc] initWithCustomView:cameraButton], nil];
    }
}

- (void) cameraButtonIconDecide {
    //NSLog(@"pic count %d", [Inspection sharedInspection].currentAudit.currentPictureCount);
    if ([self.pageTitle isEqualToString:@"ContainerViewController"] && [[User sharedUser].allImages count] > 0) {
        NSString *imageName = [NSString stringWithFormat:@"ic_menu_camera_%d.png", [[User sharedUser].allImages count]];
        if ([[User sharedUser].allImages count] > 25) {
            imageName = [NSString stringWithFormat:@"ic_menu_camera_25_plus.png"];
        }
        [cameraButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    } else if ([self.pageTitle isEqualToString:@"ProductViewController"] || [self.pageTitle isEqualToString:@"ProductRatingViewController"]) {
        if ([Inspection sharedInspection].currentAudit.currentPictureCount > 0) {
            NSString *imageName = [NSString stringWithFormat:@"ic_menu_camera_%d.png", [Inspection sharedInspection].currentAudit.currentPictureCount];
            if ([Inspection sharedInspection].currentAudit.currentPictureCount > 25) {
                imageName = [NSString stringWithFormat:@"ic_menu_camera_25_plus.png"];
            }
            [cameraButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        } else {
            [cameraButton setImage:[UIImage imageNamed:@"ic_camera.png"] forState:UIControlStateNormal];
        }
    }
}

-(void)updateContainerViewNavBar:(BOOL)isWarningIconNeeded{
    if ([[User sharedUser] checkForRetailInsights]) {
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithCustomView:saveButton], [[UIBarButtonItem alloc] initWithCustomView:cameraButton], nil];
    }else{
        if(isWarningIconNeeded)
            self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithCustomView:saveForwardButton], [[UIBarButtonItem alloc] initWithCustomView:cameraButton],[[UIBarButtonItem alloc] initWithCustomView:warningIcon], nil];
        else
            self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithCustomView:saveForwardButton], [[UIBarButtonItem alloc] initWithCustomView:cameraButton], nil];
    }
}

-(void)updateProductListNavBar:(BOOL)isWarningIconNeeded {
    if ([[User sharedUser] checkForRetailInsights]) {
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithCustomView:listButton],nil];
    }else{
        if(isWarningIconNeeded)
            self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithCustomView:listButton],[[UIBarButtonItem alloc] initWithCustomView:warningIcon],nil];
        else
            self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithCustomView:listButton],nil];
    }
}

//- (void) bringInspection {
//    
//}


- (void) goBack {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"RemoveUtilityView"
     object:self];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) refreshButtonTouched {
//    DefectsViewController *defectsViewController = [[DefectsViewController alloc] initWithNibName:@"DefectsViewController" bundle:nil];
//    [self.navigationController pushViewController:defectsViewController animated:YES];

}

- (void) addButtonTouched {
    
}

- (void) actionSheetSetup {
    self.actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Source" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                            @"Camera",
                            @"Photos Album",
                            @"Photo Viewer",
                            nil];
    //fix issue with iPad Air
if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    [self.actionSheet showInView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
    //actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    //[actionSheet showInView:self.view];
}else{
    [self.actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}
   

}

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        //[self setupCamera];
        [self setupCameraWithCustomization];
    } else if (buttonIndex == 1) {
        [self setupPhotosAlbum];
    } else if (buttonIndex == 2) {
        [self setupPhotoViewer];
    }
}

- (void) setupPhotoViewer {
    
}

- (void) setupPhotosAlbum {
    AGImagePickerController *imagePickerController = [[ImageGalleryPicker sharedPicker] getImageGalleryPicker];
    __weak ParentNavigationViewController* weakSelf = self;
    [imagePickerController setDidFailBlock:^(NSError *error) {
        //run on UI thread to fix crash
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf dismissViewControllerAnimated:NO completion:nil];
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        });
    }];
    
    [imagePickerController setDidFinishBlock:^(NSArray *info) {
        //show loading for attaching images
        UserNetworkActivityView *activityView = [UserNetworkActivityView sharedActivityView];
        [activityView setCustomMessage:@"Saving Pictures..."];
        //load in background thread
        dispatch_queue_t backgroundQueue = dispatch_queue_create("com.mycompany.myqueue", 0);
        dispatch_async(backgroundQueue,^{
            for (ALAsset *asset in info) {
                @autoreleasepool {
                    //use fullScreenImage to optimize for memory
                    //UIImage *image = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullResolutionImage]];
                    UIImage *image = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
                    image = [image squareImageWithImage:image scaledToSize:CGSizeMake(squareShapedSize, squareShapedSize)];
                    [weakSelf saveImage:image];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf cameraButtonIconDecide];
                if (![UserNetworkActivityView sharedActivityView].hidden)
                    [[UserNetworkActivityView sharedActivityView] hide];
            });
        });
        [weakSelf dismissViewControllerAnimated:NO completion:nil];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    }];
    //fix crash on iPad
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:imagePickerController animated:YES completion:nil];
        });
   
}

- (void) saveImage: (UIImage *) image {
    if (image) {
        //Save to device with currentTime_<pictureCount> format, increment image count for inspection
        if ([pageTitle isEqualToString:@"ProductViewController"]) {
            Image *savedImage = [[Image alloc]init];
            if ([Inspection sharedInspection].currentAudit) {
                NSString *deviceUrl = [[Inspection sharedInspection].currentAudit getDeviceUrl];
                [savedImage setDeviceUrl:deviceUrl];
                NSString *remoteUrl = [[Inspection sharedInspection].currentAudit getRemoteUrl];
                [savedImage setRemoteUrl:remoteUrl];
                NSString *path = [[Inspection sharedInspection].currentAudit getPath];
                [savedImage setPath:path];
                // save image in CurrentAudit class
                [savedImage saveImageToDevice:image];
                [[Inspection sharedInspection].currentAudit addImage:savedImage];
                [Inspection sharedInspection].currentAudit.currentPictureCount++;
            }
        } else if ([pageTitle isEqualToString:@"ContainerViewController"]) {
            [[User sharedUser].allImages addObject:image];
    
        }
    }
}

- (void) setupCamera {
    if (oldImagePicker) {
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"You don't have a camera for this device" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        } else {
            oldImagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            oldImagePicker.delegate = self;
            
            [self presentViewController:oldImagePicker animated:YES completion:nil];
        }
    }
}

- (void) setupCameraWithCustomization {
    self.oldImagePicker = [[UIImagePickerController alloc] init];
    if (oldImagePicker) {
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"You don't have a camera for this device" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        } else {
            oldImagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            oldImagePicker.modalPresentationStyle = UIModalPresentationCurrentContext;
            oldImagePicker.delegate = self;
            oldImagePicker.showsCameraControls = NO;
            
            [[NSBundle mainBundle] loadNibNamed:@"CameraOverlayView" owner:self options:nil];
            UIWindow *win = [[UIApplication sharedApplication] keyWindow];
            self.overlayView.frame = oldImagePicker.cameraOverlayView.frame;
            oldImagePicker.cameraOverlayView = self.overlayView;
            self.overlayView = nil;

            int flashMode = [self getCameraFlashModeFromPreferences];
            //set flash status
            if(flashMode == UIImagePickerControllerCameraFlashModeOff){
                [self.flashStatus setText:@"Off"];
            }
            else if(flashMode == UIImagePickerControllerCameraFlashModeOn){
                [self.flashStatus setText:@"On"];
            }
            else if(flashMode == UIImagePickerControllerCameraFlashModeAuto){
                [self.flashStatus setText:@"Auto"];
            }
            else{
                [self.flashStatus setText:@"Off"]; //error
            }

            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                dispatch_async(dispatch_get_main_queue(), ^ {
                    [self presentViewController:oldImagePicker animated:YES completion:nil];
                });
            }else{
                [self presentViewController:oldImagePicker animated:YES completion:nil];
            }
            
        }
    }
}

- (IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)takePhoto:(id)sender {
    
    [self.oldImagePicker takePicture];
    
    //show loading to give time to process the image in callback
    UserNetworkActivityView *activityView = [UserNetworkActivityView sharedActivityView];
    [activityView setCustomMessage:@"Saving....."];
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        [activityView show:self withOperation:nil showCancel:NO];
    }
    
    [self performSelector:@selector(hideLoadingScreen) withObject:nil afterDelay:2.0];
}

-(void)saveCameraFlashModeInPreferences:(int)flashMode{
    [NSUserDefaultsManager saveIntegerToUserDefaults:flashMode withKey:CAMERA_FLASH_SETTING];
}

-(int)getCameraFlashModeFromPreferences{
    int mode =[NSUserDefaultsManager getIntegerFromUserDeafults:CAMERA_FLASH_SETTING];
    return mode;
}

- (IBAction)showGallery:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
    [self setupPhotoViewer];
}

- (IBAction)toggleFlash:(id)sender {
    if([self.oldImagePicker cameraFlashMode] == UIImagePickerControllerCameraFlashModeOff){
        self.oldImagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOn;
        [self.flashStatus setText:@"On"];
        [self saveCameraFlashModeInPreferences:UIImagePickerControllerCameraFlashModeOn];
    }
    else if([self.oldImagePicker cameraFlashMode] == UIImagePickerControllerCameraFlashModeOn){
        self.oldImagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
         [self.flashStatus setText:@"Auto"];
        [self saveCameraFlashModeInPreferences:UIImagePickerControllerCameraFlashModeAuto];
    }
    else if([self.oldImagePicker cameraFlashMode] == UIImagePickerControllerCameraFlashModeAuto){
        self.oldImagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
         [self.flashStatus setText:@"Off"];
        [self saveCameraFlashModeInPreferences:UIImagePickerControllerCameraFlashModeOff];
    }
}


-(void) hideLoadingScreen {
    if (![UserNetworkActivityView sharedActivityView].hidden)
        [[UserNetworkActivityView sharedActivityView] hide];
}


- (void) orderDataSyncButtonTouched {
    //DI-2952 Prevent order download if there is a saved inspection
    NSArray *savedInspections = [[User sharedUser] getAllSavedInspections];
    if ([savedInspections count] > 0) {
        [[[UIAlertView alloc] initWithTitle: @"Complete the Saved Inspections before downloading Order Data " message:nil delegate: self cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
        return;
    }
    
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
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Network Availability"
                                                          message:[NSString stringWithFormat:@"%@", connectionString]
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        
        [message show];
    } else {
        [self initializeOrderDataTable];
        UIWindow *win = [[UIApplication sharedApplication] keyWindow];
        self.syncOverlayView = [[SyncOverlayView alloc] initWithFrame:CGRectMake(0, 0, win.bounds.size.width, win.bounds.size.height)];
        self.syncOverlayView.headingTitleLabel.text = @"Downloading Order Data..";
        //   [self.syncOverlayView showActivityView];
        self.syncManager = [[SyncManager alloc] init];
        [self.syncManager orderDataCallDownload:self.syncOverlayView];
        [win addSubview:self.syncOverlayView];
        self.syncManager.delegate = self;
        [UIApplication sharedApplication].idleTimerDisabled = YES;
    }
}

- (void) initializeOrderDataTable {
    OrderDataDBHelper *orderDataDBHelper = [[OrderDataDBHelper alloc] init];
    [orderDataDBHelper deleteAllTables];
    [orderDataDBHelper createAllTables];
}

- (void) orderDataDownloadComplete {
    [self.syncOverlayView removeFromSuperview];
    UIWindow *win = [[UIApplication sharedApplication] keyWindow];
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    [alert addButton:@"Ok" actionBlock:^(void) {
        NSLog(@"Ok button tapped");
    }];
    [alert showSuccess:win.rootViewController title:@"Download Successful" subTitle:@"" closeButtonTitle:nil duration:0.0f];
    [[Inspection sharedInspection] clearOrderDataArray];
}

- (void) orderDataMissing {
    [self.syncOverlayView removeFromSuperview];
    UIWindow *win = [[UIApplication sharedApplication] keyWindow];
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    [alert addButton:@"Ok" actionBlock:^(void) {
        NSLog(@"Ok button tapped");
    }];
    [alert showWarning:win.rootViewController title:@"Order data not available" subTitle:@"" closeButtonTitle:nil duration:0.0f];
}

- (void) orderDataDownloadFailedWithMessage:(NSString*)message{
    [self.syncOverlayView removeFromSuperview];
    [[[UIAlertView alloc] initWithTitle:@"Download Failed" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
}

- (void)cameraButtonTouched
{
    //[self setupCamera];
    [self actionSheetSetup];
}

- (void) addStoreButtonPressed {
    NSLog(@"wdvdvs");
}

#pragma mark - Camera Picker Delegate Methods

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image;
    if (info){
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
        image = [image squareImageWithImage:image scaledToSize:CGSizeMake(squareShapedSize, squareShapedSize)]; //resize at point of capture
    }
    [self saveImage:image];
    return; //continue taking picture
    //[self dismissViewControllerAnimated:YES completion:nil];
}

- (void) downloadSyncDone: (BOOL)success {
    
}

- (void) downloadFailed {
    [[[UIAlertView alloc] initWithTitle:@"Sync Failed" message: @"Goto Settings and Sync again" delegate: self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
}

- (void) downloadFailed:(NSString*)failMessage {
    [[[UIAlertView alloc] initWithTitle:@"Sync Failed" message: failMessage delegate: self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
}

- (void) settingsButtonTouched {
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    if([appName isEqualToString:@"CodeExplorer"]){
        CESettingsViewController *settingsViewController = [[CESettingsViewController alloc] initWithNibName:@"CESettingsViewController" bundle:nil];;
        [self.navigationController pushViewController:settingsViewController animated:YES];
    }
    else{
    SettingsViewController *settingsViewController = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
    settingsViewController.delegate = self;
    [self.navigationController pushViewController:settingsViewController animated:YES];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showLoadingScreenWithText:(NSString*)message
{
    if(!message || [message length]==0)
        message = @"Loading....";
    UIWindow *win = [[UIApplication sharedApplication] keyWindow];
    self.syncOverlayView = [[SyncOverlayView alloc] initWithFrame:CGRectMake(0, 0, win.bounds.size.width, win.bounds.size.height)];
    self.syncOverlayView.headingTitleLabel.text = message;
    [self.syncOverlayView showActivityView];
    [win addSubview:self.syncOverlayView];
}

-(void)dismissLoadingScreen
{
    [self.syncOverlayView dismissActivityView];
    [self.syncOverlayView removeFromSuperview];
    
}

-(void)showSimpleAlertWithMessage:(NSString*)message withTitle:(NSString*)title{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                      message:[NSString stringWithFormat:@"%@", message]
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    
    [alertView show];
}

@end
