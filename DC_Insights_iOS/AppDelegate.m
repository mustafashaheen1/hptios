//
//  AppDelegate.m
//  DC_Insights_iOS
//
//  Created by John Gifford on 11/5/13.
//  Copyright (c) 2013 Yottamark. All rights reserved.
//

#import "AppDelegate.h"
#import "LocationManager.h"
#import "UserLoginViewController.h"
#import "UserLocationSelectViewController.h"
#import "User.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "Inspection.h"
#import "ProductSelectAutoCompleteViewController.h"
#import "User.h"
#import "SavedInspection.h"
#import "InspectionStatusViewController.h"
#import "InspectionStatusViewControllerRetailViewController.h"
#import "HomeScreenViewController.h"
#import "CEScanViewController.h"
#import "CrashLogHandler.h"
#import "BackgroundUpload.h"
//#import "Flurry.h"
#import "IQKeyboardManager.h"

@implementation AppDelegate

@synthesize serverReachability;
@synthesize navigationController;
@synthesize appLaunchFlow;
@synthesize syncOverlay;
@synthesize userLocationSelectViewController;
@synthesize bgTask;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [Fabric with:@[CrashlyticsKit]];
    //remove flurry
    //[Flurry startSession:@"SGPQ298Y8B6ZCYSKM7FR"];
    self.appLaunchFlow = [[AppLaunchFlow alloc] init];
    [self.appLaunchFlow enableDefaultsAtStartup];
    UserLoginViewController *userLoginViewController = [[UserLoginViewController alloc] initWithNibName:@"UserLoginViewController" bundle:nil];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // Running on iPad
        userLoginViewController = [[UserLoginViewController alloc] initWithNibName:@"UserLoginViewController_iPad" bundle:nil];
    }
    userLocationSelectViewController = [[UserLocationSelectViewController alloc] initWithNibName:@"UserLocationSelectViewController" bundle:nil];
    if (![[NSUserDefaultsManager getObjectFromUserDeafults:SyncOverWifiButtonSet] isEqualToString:@"SET"]) {
        [NSUserDefaultsManager saveBOOLToUserDefaults:YES withKey:SyncOverWifi];
    }
    [self addObservers];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:userLoginViewController];
    NSString *documents_dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSLog(@"documents_dir %@", documents_dir);
    
    [CrashlyticsKit setUserIdentifier:[DeviceManager getDeviceID]];
    if ([self.appLaunchFlow isUserLoggedIn]) {
        [CrashlyticsKit setUserEmail:[User sharedUser].email];
        
        //Code-Explorer switch
        NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        //hide google-sign-in for codeexplorer
        if([appName isEqualToString:@"CodeExplorer"]){
            //if (![UserNetworkActivityView sharedActivityView].hidden)
              //  [[UserNetworkActivityView sharedActivityView] hide];
            CEScanViewController *scanViewController = [[CEScanViewController alloc] initWithNibName:@"CEScanViewController" bundle:nil];
            [self.navigationController pushViewController:scanViewController animated:NO];
        }else{//Insights, ScanOut
            if (![self checkForInspection]) {
                [self.navigationController pushViewController:userLocationSelectViewController animated:NO];
            }
        }
    }
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    
    //print sqlite database directory
    if(DEBUG_APP) {
        NSLog(@"SQLite Files: %@",[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory  inDomains:NSUserDomainMask] lastObject]);
        NSLog(@"Stored Preferences: %@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
    }
    
    NSError* configureError;
    [[GGLContext sharedInstance] configureWithError: &configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    
    [GIDSignIn sharedInstance].delegate = self;
    
    NSSetUncaughtExceptionHandler(&onUncaughtException);
    
    
    return YES;
}

void onUncaughtException(NSException* exception)
{
    NSArray* backtrace = [exception callStackSymbols];
    //save exception details
    CrashLogHandler *crashHandler = [[CrashLogHandler alloc]init];
    NSString* deviceName = [DeviceManager getDeviceID];
    NSString* timeStampe = [DeviceManager getCurrentDateTimeWithTimeZone];
    NSString* crashDetails = [NSString stringWithFormat:@"\nDeviceId: %@ \nTime: %@\nException \nName: %@, \nReason: %@, \nDescription: %@, \nTrace: %@",deviceName,timeStampe,exception.name,exception.reason, exception.debugDescription,backtrace];
    [crashHandler addToCrashLogs:crashDetails];
    //NSLog(@"Adding crash: %@",crashDetails);
}

-(void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    NSLog(@"Received memory warning!");
    CrashLogHandler *crashHandler = [[CrashLogHandler alloc]init];
    NSString* deviceName = [DeviceManager getDeviceID];
    NSString* timeStampe = [DeviceManager getCurrentDateTimeWithTimeZone];
    NSString* crashDetails = [NSString stringWithFormat:@"\nDeviceId: %@ \nTime: %@ \nError: applicationDidReceiveMemoryWarning() called in AppDelegate",deviceName,timeStampe];
    [crashHandler addToCrashLogs:crashDetails];
}

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary *)options {
    return [[GIDSignIn sharedInstance] handleURL:url
                               sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                      annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [[GIDSignIn sharedInstance] handleURL:url
                               sourceApplication:sourceApplication
                                      annotation:annotation];
}

- (void)signIn:(GIDSignIn *)signIn
didSignInForUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    // Perform any operations on signed in user here.
    NSString *userId = user.userID;                  // For client-side use only!
    NSString *idToken = user.authentication.idToken; // Safe to send to the server
   
    NSLog(@"name is %@ %@", userId, idToken);
    // ...
}

- (void)signIn:(GIDSignIn *)signIn
didDisconnectWithUser:(GIDGoogleUser *)user
     withError:(NSError *)error {

    // Perform any operations when the user disconnects from app here.
    // ...
}

- (BOOL) checkForInspection {
    BOOL inspectionActive = NO;
    NSString *auditMasterId = [NSUserDefaultsManager getObjectFromUserDeafults:PREF_AUDIT_MASTER_ID];
    if ([NSUserDefaultsManager getObjectFromUserDeafults:PREF_AUDIT_MASTER_ID] && ![auditMasterId isEqualToString:@""]) {
        inspectionActive = YES;
        BOOL savedAuditAvailable = NO;
        NSArray *pastInspections = [[User sharedUser] getAllSavedInspections];
        for (SavedInspection *savedInspection in pastInspections) {
            if ([savedInspection.auditMasterId isEqualToString:auditMasterId]) {
                savedAuditAvailable = YES;
                [[Inspection sharedInspection] resumeSavedInspection:savedInspection.auditMasterId];
                if (savedInspection.auditsCount > 0) {
                    if ([[User sharedUser] checkForRetailInsights]) {
                        InspectionStatusViewControllerRetailViewController *inspectionViewController = [[InspectionStatusViewControllerRetailViewController alloc] initWithNibName:@"InspectionStatusViewControllerRetailViewController" bundle:nil];
                        [self.navigationController pushViewController:inspectionViewController animated:YES];
                    } else {
                        InspectionStatusViewController *inspectionViewController = [[InspectionStatusViewController alloc] initWithNibName:@"InspectionStatusViewController" bundle:nil];
                        [self.navigationController pushViewController:inspectionViewController animated:YES];
                    }
                }
                break;
            }
        }
        if (!savedAuditAvailable) {
            [[Inspection sharedInspection] resumeSavedInspection:auditMasterId];
            HomeScreenViewController *homeScreen = [[HomeScreenViewController alloc] initWithNibName:@"HomeScreenViewController" bundle:nil];
            [self.navigationController pushViewController:homeScreen animated:NO];
            ProductSelectAutoCompleteViewController *productSelectAutoCompleteViewController = [[ProductSelectAutoCompleteViewController alloc] initWithNibName:@"ProductSelectAutoCompleteViewController" bundle:nil];
            [self.navigationController pushViewController:productSelectAutoCompleteViewController animated:YES];
        }
        //NSLog(@"pastInspections %@", pastInspections);
    }
    return inspectionActive;
}

- (void) downloadProgress: (BOOL)success {
    
}

- (void) downloadFailed {
    [[[UIAlertView alloc] initWithTitle:@"Sync Failed" message: @"Goto Settings and Sync again" delegate: self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
}

- (void) downloadFailed:(NSString*)failMessage {
    [[[UIAlertView alloc] initWithTitle:@"Sync Failed" message: failMessage delegate: self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     NSLog(@"AppDelegate - applicationWillResignActive - starting backgroundUpload");
    [[User sharedUser].backgroundUpload startBackgroundUpload];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
   /* self.bgTask = [application beginBackgroundTaskWithName:@"MyTask" expirationHandler:^{
        // Clean up any unfinished task business by marking where you
        
        // stopped or ending the task outright.
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    // Start the long-running task and return immediately.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // Do the work associated with the task, preferably in chunks.
        [[[SyncManager alloc]init] uploadDataAndImages];
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    });*/
    
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[LocationManager sharedLocationManager] retrieveCurrentLocationOnlyIfAlreadySet];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//    BackgroundUpload *backgroundUpload = [[BackgroundUpload alloc]init];
//    [backgroundUpload startBackgroundTimer];
    NSLog(@"AppDelegate - applicationDidBecomeActive - starting timer/backgroundUpload");
    [[User sharedUser] initBackgroundUpload];
    [[User sharedUser] initCollaborativeBackgroundUpload];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void) addObservers {
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
	serverReachability = [Reachability reachabilityWithHostName:endPoint_PortalHeartbeat];
    [serverReachability startNotifier];
}



# pragma mark - Reachability

// Called by Reachability whenever status changes.
- (void) reachabilityChanged: (NSNotification* )note
{
	Reachability* curReach = [note object];
    switch ([curReach currentReachabilityStatus]) {
        case NotReachable:
            //DebugLog(@"\n\n ====== reachabilityChanged: [NotReachable] \n\n");
            break;
            
        case ReachableViaWiFi:
            //DebugLog(@"\n\n ====== reachabilityChanged: [ReachableViaWiFi] \n\n");
            break;
            
        case ReachableViaWWAN:
            //DebugLog(@"\n\n ====== reachabilityChanged: [ReachableViaWWAN] \n\n");
            break;
    }
}


- (BOOL) isServerReachable
{
    return !([serverReachability currentReachabilityStatus] == NotReachable);
}


@end
