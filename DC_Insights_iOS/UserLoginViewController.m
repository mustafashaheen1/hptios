//
//  UserLocationSelectViewController.m
//  DC_Insights_iOS
//
//  Created by John Gifford on 11/5/13.
//  Copyright (c) 2013 Yottamark. All rights reserved.
//

#import "UserLoginViewController.h"
#import "UserLocationSelectViewController.h"
#import "Post.h"
#import "DBManager.h"
#import "NSUserDefaultsManager.h"
#import "InsightsDBHelper.h"
#import "AppDataDBHelper.h"
#import "User.h"
#import "CurrentAudit.h"
#import <Crashlytics/Crashlytics.h>
#import "CEScanViewController.h"

#define rowHeight 35;

@interface UserLoginViewController () {
    NSMutableArray *nameList;
    UserAPI *userAPI;
}
@property (strong, nonatomic) UserAPI *userAPI;

@end

@implementation UserLoginViewController

@synthesize usernameTextField;
@synthesize passwordTextField;
@synthesize selectUserButton;
@synthesize userAPI;
@synthesize checkBoxButton;
@synthesize forgotPasswordButton;
@synthesize table;
@synthesize previousSignIns;
@synthesize previousSignInsForAutoComplete;

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

- (IBAction)displayEndpointSelectionMenu {
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bannerTapped)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [self.brandingImage addGestureRecognizer:singleTap];
    [self.brandingImage setUserInteractionEnabled:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
//        case 0:
//           [NSUserDefaultsManager saveObjectToUserDefaults:endPointURL_QA3 withKey:PORTAL_ENDPOINT];
//        [[[UIAlertView alloc] initWithTitle:@"Endpoint changed" message: @"QA3" delegate: self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
//            break;

        case 0:
            [NSUserDefaultsManager saveObjectToUserDefaults:endPointURL_QA_AZURE withKey:PORTAL_ENDPOINT];
            [[[UIAlertView alloc] initWithTitle:@"Endpoint changed" message: @"QA AZURE" delegate: self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            break;

        case 1:
            [NSUserDefaultsManager saveObjectToUserDefaults:endPointURL_PROD withKey:PORTAL_ENDPOINT];
            [[[UIAlertView alloc] initWithTitle:@"Endpoint changed" message: @"Production" delegate: self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            break;

        case 2:{
            UIAlertView* dialog = [[UIAlertView alloc] initWithTitle:@"Enter Custom URL"
                                                             message:@"Ex: https://qa.harvestmark.com/ \n(Requires slash at the end) "
                                                            delegate:self
                                                   cancelButtonTitle:@"Cancel"
                                                   otherButtonTitles:@"OK", nil];
            dialog.tag = 99;
            [dialog setAlertViewStyle:UIAlertViewStylePlainTextInput];
            [[dialog textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeDefault];
            [dialog show];
        }
            break;
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 99) { //handle OK and cancel
        if(buttonIndex == alertView.firstOtherButtonIndex){
            NSString* url = [alertView textFieldAtIndex:0].text;
            [NSUserDefaultsManager saveObjectToUserDefaults:url withKey:PORTAL_ENDPOINT];
        }
    }
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch=[touches anyObject];
    
    if([[touch valueForKey:@"view"] isKindOfClass:[UIImageView class]])
    {
        self.tapCount++;
        if(self.tapCount%10==0)
           [self bannerTapped];
        
    }
}

-(void) bannerTapped {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"%@ (SELECT SERVER)",  [NSUserDefaultsManager getObjectFromUserDeafults:PORTAL_ENDPOINT]] delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
                                                    otherButtonTitles:@"QA Azure",@"Production",@"Custom", nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault; [actionSheet showInView:self.view];
}

- (IBAction)checkButton:(id)sender {
    if (!checked) {
        [checkBoxButton setImage:[UIImage imageNamed:@"checkBoxMarked.png"] forState:UIControlStateNormal];
        [NSUserDefaultsManager saveBOOLToUserDefaults:YES withKey:@"rememberme"];
        checked = YES;
    }
    
    else if (checked) {
        [checkBoxButton setImage:[UIImage imageNamed:@"checkBox.png"] forState:UIControlStateNormal];
        [NSUserDefaultsManager saveBOOLToUserDefaults:NO withKey:@"rememberme"];
        checked = NO;
    }
}

- (IBAction)didTapSignOut:(id)sender {
    [[GIDSignIn sharedInstance] signOut];
}

#pragma mark - Google Sign In

-(void) initGoogleSignIn {
    NSError* configureError;
    [[GGLContext sharedInstance] configureWithError: &configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    [GIDSignIn sharedInstance].delegate = self;
    [GIDSignIn sharedInstance].uiDelegate = self;
    [self.signInButton setColorScheme:kGIDSignInButtonColorSchemeDark];
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    
    //hide google-sign-in for codeexplorer
    if([appName isEqualToString:@"CodeExplorer"]){
        [self.signInButton setHidden:YES];
        if(!PROGRAM_ZESPRI)
        [self.banner setImage:[UIImage imageNamed:@"driscoll_banner.png"]];
    }
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    NSDictionary *options = @{UIApplicationOpenURLOptionsSourceApplicationKey: sourceApplication,
                              UIApplicationOpenURLOptionsAnnotationKey: annotation};
    return [self application:application
                     openURL:url
                     options:options];
}

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary *)options {
    return [[GIDSignIn sharedInstance] handleURL:url
                               sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                      annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
}

-(void)signIn:(GIDSignIn *)signIn
didSignInForUser:(GIDGoogleUser *)user
    withError:(NSError *)error {
    
    if(error){
        [[[UIAlertView alloc] initWithTitle:@"Google Sign-In Failed" message: error.description delegate: self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }else {
        // Perform any operations on signed in user here.
        NSString *idToken = user.authentication.idToken; // Safe to send to the server
        NSString *email = user.profile.email;
        
        NSArray *arrayValues = @[email, idToken];
        NSArray *arrayKeys = @[@"email", @"auth_token"];
        NSDictionary *registrationDetails = [[NSDictionary alloc] initWithObjects:arrayValues forKeys:arrayKeys];
        [self callGoogleLogin:registrationDetails];
    }
}

- (void)signIn:(GIDSignIn *)signIn
didDisconnectWithUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    // Perform any operations when the user disconnects from app here.
    // ...
    if(error){
        [[[UIAlertView alloc] initWithTitle:@"Google Sign-In Disconnected with error" message: error.description delegate: self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }else{
        [[[UIAlertView alloc] initWithTitle:@"Google Sign-In Disconnected " message: @"Disconnected" delegate: self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }
}


- (void) callGoogleLogin : (NSDictionary *) dictionaryValues {
    if (dictionaryValues) {
        UserNetworkActivityView *activityView = [UserNetworkActivityView sharedActivityView];
        UIWindow *win = [[UIApplication sharedApplication] keyWindow];
        //self.frame = CGRectMake(0, -20, win.frame.size.width, win.frame.size.height);
        [activityView setFrame:CGRectMake(0, 0, win.frame.size.width, win.frame.size.height)];
        [activityView setCustomMessage:@"Logging in ..."];
        if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
            [activityView show:self withOperation:nil showCancel:NO];
        }
        
        UIActivityIndicatorView *progress_ind = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        progress_ind.center = CGPointMake (self.view.bounds.size.width * 0.5F, self.view.bounds.size.height * 0.5F);
        [progress_ind startAnimating];
        progress_ind.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [self.view addSubview:progress_ind];
        }
        
        [self.userAPI googleLoginWithBlock:^(BOOL isSuccess, NSError *error){
            [progress_ind removeFromSuperview];
            if (error) {
                if (![UserNetworkActivityView sharedActivityView].hidden)
                    [[UserNetworkActivityView sharedActivityView] hide];
                [[[UIAlertView alloc] initWithTitle:@"Login Failed" message: [NSString stringWithFormat:@"%@", [error localizedDescription]] delegate: self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
                DebugLog(@"\n Error: %@  \n", [error localizedDescription]);
            } else {
                if (isSuccess) {
                    /*if ([NSUserDefaultsManager getBOOLFromUserDeafults:@"rememberme"]) {
                     NSMutableDictionary *usersDictionaryMutable = [[NSMutableDictionary alloc] init];
                     NSDictionary *retrievedDictionary = [NSUserDefaultsManager getObjectFromUserDeafults:@"usersDictionary"];
                     [usersDictionaryMutable addEntriesFromDictionary:retrievedDictionary];
                     [usersDictionaryMutable setObject:[NSString stringWithFormat:@"%@", self.passwordTextField.text] forKey:[NSString stringWithFormat:@"%@", self.usernameTextField.text]];
                     [NSUserDefaultsManager saveObjectToUserDefaults:[usersDictionaryMutable mutableCopy] withKey:@"usersDictionary"];
                     
                     NSLog(@"retrievedDictionary %@", [NSUserDefaultsManager getObjectFromUserDeafults:@"usersDictionary"]);
                     }
                     self.previousSignIns = [[NSMutableArray alloc] initWithArray:[[User sharedUser] retrievePreviousUsers]];
                     self.previousSignInsForAutoComplete = [[NSArray alloc] init];
                     self.previousSignInsForAutoComplete = [self.previousSignIns copy];
                     
                     if (![[NSString stringWithFormat:@"%@", self.usernameTextField.text] isEqualToString:[NSUserDefaultsManager getObjectFromUserDeafults:usernameForLogoutSaved]]) {
                     [self downloadProgramsForTeamCheck:^(BOOL same) {
                     [self callOtherAPISForsuccessfulSignIn];
                     }];
                     } else {
                     [self callOtherAPISForsuccessfulSignIn];
                     }*/
                    [self callOtherAPISForsuccessfulSignIn];
                    NSString* email = (NSString*)[dictionaryValues objectForKey:@"email"];
                    //[NSUserDefaultsManager saveObjectToUserDefaults:[NSString stringWithFormat:@"%@", self.usernameTextField.text] withKey:usernameForLogoutSaved];
                    [CrashlyticsKit setUserIdentifier:email];
                    [self.usernameTextField setText:@""];
                    [self.passwordTextField setText:@""];
                } else {
                    [[[UIAlertView alloc] initWithTitle:@"Login Failed" message: @"Check your credentials and try again" delegate: self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
                }
                if (![UserNetworkActivityView sharedActivityView].hidden)
                    [[UserNetworkActivityView sharedActivityView] hide];
            }
        }withDictionaryValues:dictionaryValues];
    }
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    //google
    [self initGoogleSignIn];
    //initialize the portal endpoint with production

        [NSUserDefaultsManager saveObjectToUserDefaults:endPointURL_PROD withKey:PORTAL_ENDPOINT];
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];

    if(([bundleIdentifier isEqualToString:@"com.trimble.harvestmark.enterprise.hpt"]) || ([bundleIdentifier isEqualToString:@"com.trimble.harvestmark.hpt"]))
    {
        [NSUserDefaultsManager saveObjectToUserDefaults:endPointURL_QA_AZURE withKey:PORTAL_ENDPOINT];
    }
    NSLog(@"device %@", [DeviceManager getDeviceID]);
    self.pageTitle = @"UserLoginViewController";
    checked = NO;
    [self.usernameTextField addTarget:self action:@selector(textFieldKeepsChanging:) forControlEvents:UIControlEventEditingChanged];
    self.usernameTextField.autocorrectionType = FALSE; // or use  UITextAutocorrectionTypeNo
    //self.usernameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.previousSignIns = [[NSMutableArray alloc] initWithArray:[[User sharedUser] retrievePreviousUsers]];
    self.previousSignInsForAutoComplete = [[NSArray alloc] init];
    self.previousSignInsForAutoComplete = [self.previousSignIns copy];
    if (!self.userAPI) {
        self.userAPI = [[UserAPI alloc] init];
    }
    [self tableViewSetup];
    [self loadValuesIfAlreadyPresent];
    
}

- (void)viewWillAppear:(BOOL)animated
{   
    [super viewWillAppear:animated];
    [self loadValuesIfAlreadyPresent];
    [self setupNavBar];
    [self displayPoweredByLogo];
}

-(void)displayPoweredByLogo{
    [self.poweredByLogo setHidden:YES];
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    //hide google-sign-in for codeexplorer
    if([appName isEqualToString:@"CodeExplorer"]){
        [self.poweredByLogo setHidden:NO];
        [self.poweredByLogo setNeedsDisplay];
    }
}

- (void) tableViewSetup {
    self.table = [[UITableView alloc] initWithFrame:CGRectMake(30, 132, 260, 0)];
    self.table.layer.borderWidth = 1.0;
    self.table.layer.cornerRadius = 5.0;
    self.table.backgroundColor = [UIColor clearColor];
    self.table.layer.borderColor = [[UIColor blackColor] CGColor];
    self.table.delegate = self;
    self.table.dataSource = self;
    if ([table respondsToSelector:@selector(setSeparatorInset:)]) {
        [table setSeparatorInset:UIEdgeInsetsZero];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) callLogin : (NSDictionary *) dictionaryValues {
    if (dictionaryValues) {
        UserNetworkActivityView *activityView = [UserNetworkActivityView sharedActivityView];
        UIWindow *win = [[UIApplication sharedApplication] keyWindow];
        //self.frame = CGRectMake(0, -20, win.frame.size.width, win.frame.size.height);
        [activityView setFrame:CGRectMake(0, 0, win.frame.size.width, win.frame.size.height)];
		[activityView setCustomMessage:@"Logging in ..."];
        if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
            [activityView show:self withOperation:nil showCancel:NO];
        }
        
        UIActivityIndicatorView *progress_ind = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        progress_ind.center = CGPointMake (self.view.bounds.size.width * 0.5F, self.view.bounds.size.height * 0.5F);
        [progress_ind startAnimating];
        progress_ind.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [self.view addSubview:progress_ind];
        }
        
        [self.userAPI globalLoginWithBlock :^(BOOL isSuccess, NSError *error){
            [progress_ind removeFromSuperview];
            if (error) {
                if (![UserNetworkActivityView sharedActivityView].hidden)
                    [[UserNetworkActivityView sharedActivityView] hide];
                [[[UIAlertView alloc] initWithTitle:@"Login Failed" message: [NSString stringWithFormat:@"%@", [error localizedDescription]] delegate: self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
                DebugLog(@"\n Error: %@  \n", [error localizedDescription]);
            } else {
                if (isSuccess) {
                    if ([NSUserDefaultsManager getBOOLFromUserDeafults:@"rememberme"]) {
                        NSMutableDictionary *usersDictionaryMutable = [[NSMutableDictionary alloc] init];
                        NSDictionary *retrievedDictionary = [NSUserDefaultsManager getObjectFromUserDeafults:@"usersDictionary"];
                        [usersDictionaryMutable addEntriesFromDictionary:retrievedDictionary];
                        [usersDictionaryMutable setObject:[NSString stringWithFormat:@"%@", self.passwordTextField.text] forKey:[NSString stringWithFormat:@"%@", self.usernameTextField.text]];
                        [NSUserDefaultsManager saveObjectToUserDefaults:[usersDictionaryMutable mutableCopy] withKey:@"usersDictionary"];
                        
                        NSLog(@"retrievedDictionary %@", [NSUserDefaultsManager getObjectFromUserDeafults:@"usersDictionary"]);
                    }
                    self.previousSignIns = [[NSMutableArray alloc] initWithArray:[[User sharedUser] retrievePreviousUsers]];
                    self.previousSignInsForAutoComplete = [[NSArray alloc] init];
                    self.previousSignInsForAutoComplete = [self.previousSignIns copy];
                    
                    //Code-Explorer switch
                    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
                    //hide google-sign-in for codeexplorer
                    if([appName isEqualToString:@"CodeExplorer"]){
                        if (![UserNetworkActivityView sharedActivityView].hidden)
                            [[UserNetworkActivityView sharedActivityView] hide];
                        CEScanViewController *scanViewController = [[CEScanViewController alloc] initWithNibName:@"CEScanViewController" bundle:nil];
                        [self.navigationController pushViewController:scanViewController animated:NO];
                        return;
                    }
                    
                    if (![[NSString stringWithFormat:@"%@", self.usernameTextField.text] isEqualToString:[NSUserDefaultsManager getObjectFromUserDeafults:usernameForLogoutSaved]]) {
                        [self downloadProgramsForTeamCheck:^(BOOL same) {
                            [self callOtherAPISForsuccessfulSignIn];
                        }];
                    } else {
                        [self callOtherAPISForsuccessfulSignIn];
                    }
                    [NSUserDefaultsManager saveObjectToUserDefaults:[NSString stringWithFormat:@"%@", self.usernameTextField.text] withKey:usernameForLogoutSaved];
                    [CrashlyticsKit setUserIdentifier:self.usernameTextField.text];
                    [self.usernameTextField setText:@""];
                    [self.passwordTextField setText:@""];
                } else {
                    [[[UIAlertView alloc] initWithTitle:@"Login Failed" message: @"Check your credentials and try again" delegate: self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
                }
                if (![UserNetworkActivityView sharedActivityView].hidden)
                    [[UserNetworkActivityView sharedActivityView] hide];
            }
        }withDictionaryValues:dictionaryValues];
    }
}

- (void) downloadProgramsForTeamCheck:(void (^)(BOOL isSuccess))block {
    ProgramAPI *programLocal = [[ProgramAPI alloc] init];
    [programLocal programsCallForChecking:^(BOOL same, NSArray *array, NSError *error) {
        if (error) {
            DebugLog(@"\n Error: %@  \n", [error localizedDescription]);
        } else {
            NSLog(@"posts %d", same);
            if (block) {
                block(same);
            }
        }
    }];
}


- (void) callOtherAPISForsuccessfulSignIn {
    [self turnOffCameraFlashAtLogin];
    UserLocationSelectViewController *userLocationSelectViewController = [[UserLocationSelectViewController alloc] initWithNibName:@"UserLocationSelectViewController" bundle:nil];
    [self.navigationController pushViewController:userLocationSelectViewController animated:NO];
}

-(void)turnOffCameraFlashAtLogin{
    [self saveCameraFlashModeInPreferences:UIImagePickerControllerCameraFlashModeOff];
}

- (IBAction)loginUserButton:(id)sender {
    NSString *fieldEmpty = @"Username or Password fields cannot be empty";
    [self resignResponders];
    if (![self.usernameTextField.text isEqualToString:@""] && ![self.passwordTextField.text isEqualToString:@""]) {
        NSArray *arrayValues = @[self.usernameTextField.text, self.passwordTextField.text];
        NSArray *arrayKeys = @[@"email", @"password"];
        NSDictionary *registrationDetails = [[NSDictionary alloc] initWithObjects:arrayValues forKeys:arrayKeys];
        [self callLogin:registrationDetails];
    } else {
        [[[UIAlertView alloc] initWithTitle:fieldEmpty message: @"" delegate: self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }
}

- (void) forgotPasswordButtonTouched:(id) sender {
    
}

#pragma mark - TextField delegate methods.


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.usernameTextField || textField == self.passwordTextField) {
        [self resignResponders];
        if (![self.usernameTextField.text isEqualToString:@""] && ![self.passwordTextField.text isEqualToString:@""]) {
            [self loginUserButton:nil];
        }
    }

    return YES;
}

- (void) resignResponders {
    [self.table removeFromSuperview];
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

- (void) loadValuesIfAlreadyPresent {
    if ([NSUserDefaultsManager getBOOLFromUserDeafults:@"rememberme"]) {
        checked = YES;
        [checkBoxButton setImage:[UIImage imageNamed:@"checkBoxMarked.png"] forState:UIControlStateNormal];
//        [self.usernameTextField setText:[NSUserDefaultsManager getObjectFromUserDeafults:@"username"]];
//        [self.passwordTextField setText:[NSUserDefaultsManager getObjectFromUserDeafults:@"password"]];
    } else {
        [self.usernameTextField setText:@""];
        [self.passwordTextField setText:@""];
    }
}

- (IBAction)usernameTextFieldTouched:(id)sender {
    NSLog(@"toucjef");
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.usernameTextField) {
//        if (![textField.text isEqualToString:@""]) {
//            [self searchAndRefreshTableViewWithString:textField.text];
//            [self.table reloadData];
//        } else {
//            self.previousSignIns = [[NSMutableArray alloc] init];
//            [self.previousSignIns addObjectsFromArray:self.previousSignInsForAutoComplete];
//            [self.table reloadData];
//        }
//        [self bringTableUp];
    } else if (textField == self.passwordTextField) {
        [self.table removeFromSuperview];
    }
}


- (void) textFieldKeepsChanging: (UITextField *)textField {
    if (textField == self.usernameTextField) {
        if (![textField.text isEqualToString:@""]) {
            [self searchAndRefreshTableViewWithString:textField.text];
            [self.table reloadData];
        } else {
            self.previousSignIns = [[NSMutableArray alloc] init];
            [self.previousSignIns addObjectsFromArray:self.previousSignInsForAutoComplete];
            [self.table reloadData];
        }
        [self bringTableUp];
    } else if (textField == self.passwordTextField) {
        [self.table removeFromSuperview];
    }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if (textField == self.usernameTextField) {
        self.passwordTextField.text = @"";
        self.previousSignIns = [[NSMutableArray alloc] init];
        
        [self.previousSignIns addObjectsFromArray:self.previousSignInsForAutoComplete];
        [self.table reloadData];
        [self bringTableUp];
    }
    return YES;
}

- (void) bringTableUp {
    CGFloat height = rowHeight;
    float h = height * [self.previousSignIns count];
    if(h > 150.0)
    {
        [UIView animateWithDuration:0.3
                              delay:0
                            options: UIViewAnimationOptionAllowUserInteraction
                         animations:^ {
                             self.table.frame = CGRectMake(30, self.usernameTextField.frame.origin.y + self.usernameTextField.frame.size.height + 5, 260, 150);
                             if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                                 self.table.frame = CGRectMake(30, self.usernameTextField.frame.origin.y + self.usernameTextField.frame.size.height + 5, 260, 150);
                             }
                         }
                         completion:^(BOOL finished){}];
    }
    else
    {
        [UIView animateWithDuration:0.3
                              delay:0
                            options: UIViewAnimationOptionAllowUserInteraction
                         animations:^ {
                             self.table.frame = CGRectMake(30, self.usernameTextField.frame.origin.y + self.usernameTextField.frame.size.height + 5, 260, h);
                             if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                                 self.table.frame = CGRectMake(30, self.usernameTextField.frame.origin.y + self.usernameTextField.frame.size.height + 5, 260, h);
                             }
                         }
                         completion:^(BOOL finished){}];
    }
    [self.view addSubview:self.table];
}

#pragma mark - UserNetworkActivityViewProtocol Method

- (void) userCancelledOperation
{
	// Cancel not used, no implementation needed
}

#pragma mark - TableView Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;    //count of section
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.previousSignIns count];    //count number of row from counting array hear cataGorry is An Array
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
    }
    User *user = [self.previousSignIns objectAtIndex:indexPath.row];
    cell.textLabel.text = user.email;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return rowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self resignResponders];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    User *user = [self.previousSignIns objectAtIndex:indexPath.row];
    self.usernameTextField.text = user.email;
    self.passwordTextField.text = user.password;
    [self.table removeFromSuperview];
}

- (void) searchAndRefreshTableViewWithString: (NSString *) string {
    self.previousSignIns = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.previousSignInsForAutoComplete count]; i++) {
        if ([[self.previousSignInsForAutoComplete objectAtIndex:i] isKindOfClass:[User class]]) {
            User *user = [self.previousSignInsForAutoComplete objectAtIndex:i];
            NSRange substringRange = [[user.email lowercaseString] rangeOfString:[string lowercaseString]];
            if (substringRange.length != 0) {
                [self.previousSignIns addObject:user];
            }
        }
    }
}

@end
