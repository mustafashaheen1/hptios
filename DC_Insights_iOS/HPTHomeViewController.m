//
//  HPTHomeViewController.m
//  Insights-Trimble-Enterprise
//
//  Created by Mustafa Shaheen on 6/16/20.
//  Copyright © 2020 Yottamark. All rights reserved.
//

#import "HPTHomeViewController.h"
#import "InspectionTableViewCell.h"
#import "MasterProductRatingManager.h"
#import "User.h"
#import "Inspection.h"
#import "AuditApiContainerParent.h"
#import "HPTCaseCodeViewController.h"
#import "Inspection.h"
#import "LocationManager.h"
#import "SavedInspection.h"
#import "UserLocationSelectViewController.h"
#import <Google/SignIn.h>
#import "OrderData.h"
#import "ImageArray.h"
#import "BackgroundUpload.h"
@interface HPTHomeViewController ()

@end

@implementation HPTHomeViewController

@synthesize username;
@synthesize syncManager;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.username.text = [[User sharedUser] email];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    self.pageTitle = @"HPTHomeViewController";
    [self setupNavBar];
}
- (IBAction)logoutPressed:(UIButton *)sender {
    [[User sharedUser] logoutUser];
    [[GIDSignIn sharedInstance] signOut];
    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (IBAction)outgoingShipmentPressed:(UIButton *)sender {
    
    UIWindow *win = [[UIApplication sharedApplication] keyWindow];
    self.syncOverlayView = [[SyncOverlayView alloc] initWithFrame:CGRectMake(0, 0, win.bounds.size.width, win.bounds.size.height)];
    self.syncOverlayView.headingTitleLabel.text = LoadingPalletShippingRating;
    [self.syncOverlayView showActivityView];
    [win addSubview:self.syncOverlayView];
    
    dispatch_queue_t backgroundQueue = dispatch_queue_create("com.mycompany.myqueue", 0);
    dispatch_async(backgroundQueue, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.syncOverlayView dismissActivityView];
                [self.syncOverlayView removeFromSuperview];;
                
                HPTCaseCodeViewController *containerViewController;
                containerViewController = [[HPTCaseCodeViewController alloc] initWithNibName:kCaseCodeViewNIBName bundle:nil];
                [self.navigationController pushViewController:containerViewController animated:YES];
            });
    });
    
}
- (void) setupNavBar {
    [super setupNavBar];
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

@end
