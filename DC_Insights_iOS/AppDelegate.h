//
//  AppDelegate.h
//  DC_Insights_iOS
//
//  Created by John Gifford on 11/5/13.
//  Copyright (c) 2013 Yottamark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "AppLaunchFlow.h"
#import "SyncOverlayView.h"
#import "SyncManager.h"
#import "UserLocationSelectViewController.h"
//#import <GoogleSignIn/GoogleSignIn.h>
#import <Google/SignIn.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, SyncManagerDelegate, GIDSignInDelegate> {
    Reachability* serverReachability;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) Reachability* serverReachability;
@property (strong, nonatomic) UINavigationController* navigationController;
@property (strong, nonatomic) AppLaunchFlow* appLaunchFlow;
@property (strong, nonatomic) SyncOverlayView* syncOverlay;
@property (strong, nonatomic) UserLocationSelectViewController* userLocationSelectViewController;
@property (nonatomic) UIBackgroundTaskIdentifier bgTask;
//@property BOOL isUploadInProgress;

@end
