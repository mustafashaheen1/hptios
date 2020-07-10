//
//  CESettingsViewController.m
//  Insights
//
//  Created by Vineet Pareek on 20/10/2016.
//  Copyright © 2016 Yottamark. All rights reserved.
//

#import "CESettingsViewController.h"
#import "SettingsUserDetailsView.h"
#import "User.h"
#import "UserPreferencesViewCell.h"
#import "SettingsLogoutView.h"
#import "SettingsTestButtonView.h"
#import "OpenUDID.h"

@interface CESettingsViewController ()

@end

#define ROW_TYPE_USER_DETAILS @"ROW_TYPE_USER_DETAILS"
#define ROW_TYPE_LOGOUT @"ROW_TYPE_LOGOUT"
#define ROW_TYPE_TEST_CONNECTION @"ROW_TYPE_TEST_CONNECTION"

@implementation CESettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) setupNavBar {
    [super setupNavBar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.pageTitle = @"CESettingsViewController";
    [self setupNavBar];
    [self populateViews];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

-(void)populateViews{
    self.viewList = [[NSMutableArray alloc]init];
    //UIView *containerView = [[[NSBundle mainBundle] loadNibNamed:@"SettingUserDetailsView" owner:self options:nil] lastObject];
    //SettingsUserDetailsView *view = [[SettingsUserDetailsView alloc]initWithFrame:CGRectMake(0,0, self.view.frame.size.width, 200)];
    if ([[User sharedUser] checkIfUserLoggedIn]){
        [self.viewList addObject:[self getViewForUserDetails]];
        [self.viewList addObject:[self getViewForLogoutButton]];
        [self.viewList addObject:[self getViewForTestConnection]];
    }else{
         [self.viewList addObject:[self getViewForTestConnection]];
    }
    
    
//    [self.viewList addObject:@"ROW_TYPE_USER_DETAILS"];
//    [self.viewList addObject:@"ROW_TYPE_LOGOUT"];
//    [self.viewList addObject:@"ROW_TYPE_TEST_CONNECTION"];
}

-(UIView*)getViewForTestConnection{
    SettingsTestButtonView *view = (SettingsTestButtonView*)[[[NSBundle mainBundle] loadNibNamed:@"SettingsTestButtonView" owner:self options:nil]lastObject];
    //SettingsTestConnectionView *view = [[SettingsTestConnectionView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 70)];
    [view.testButton setBackgroundColor:[UIColor colorWithRed:76.0/255.0 green:76.0/255.0 blue:76.0/255.0 alpha:1.0]];
    view.testButton.titleLabel.font = [UIFont systemFontOfSize:18.0];
    view.testButton.layer.cornerRadius = BUTTON_CORNER_RADIUS;
    [view.testButton addTarget:self action:@selector(testConnectionButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    return view;
}

-(UIView*)getViewForLogoutButton{
    SettingsLogoutView *view = (SettingsLogoutView*)[[[NSBundle mainBundle] loadNibNamed:@"SettingsLogoutView" owner:self options:nil]lastObject];
    [view.logoutButton setBackgroundColor:[UIColor colorWithRed:76.0/255.0 green:76.0/255.0 blue:76.0/255.0 alpha:1.0]];
    view.logoutButton.titleLabel.font = [UIFont systemFontOfSize:18.0];
    view.logoutButton.layer.cornerRadius = BUTTON_CORNER_RADIUS;
    [view.logoutButton addTarget:self action:@selector(clearLoginInfo) forControlEvents:UIControlEventTouchUpInside];
    return view;
}

-(void)clearLoginInfo{
    NSLog(@"Logging Out");
    [[User sharedUser] logoutUser];
    [self.navigationController popToRootViewControllerAnimated:YES];
}




-(UIView*)getViewForUserDetails{
    SettingsUserDetailsView *view = (SettingsUserDetailsView*)[[[NSBundle mainBundle] loadNibNamed:@"SettingUserDetailsView" owner:self options:nil]lastObject];
    view.username.text = [[User sharedUser] email];
    view.role.text = [[User sharedUser] getAllRoles];
    return view;
   /*
    NSString* name = [[User sharedUser] email];
    NSString* role = [[User sharedUser] getAuditorRole];
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 95)];
    //[view setBackgroundColor:[UIColor lightGrayColor]];
    
    UILabel *headerLabel = [[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width/2)-50, 0, 100, 25)];
    headerLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0f];
    headerLabel.text = @"User Details";
    
    UILabel *username = [[UILabel alloc]initWithFrame:CGRectMake(15, 35, self.view.frame.size.width, 25)];
    username.font = [UIFont fontWithName:@"Helvetica" size:15.0f];
    username.text = [NSString stringWithFormat:@"User: %@",name];
    
    UILabel *userRole = [[UILabel alloc]initWithFrame:CGRectMake(15, 65, self.view.frame.size.width, 25)];
    userRole.font = [UIFont fontWithName:@"Helvetica" size:15.0f];
    userRole.text = [NSString stringWithFormat:@"Role: %@",role];
    
    [view addSubview:headerLabel];
    [view addSubview:username];
    [view addSubview:userRole];
    */
    return view;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //NSLog(@"event attirbs are: %d", [self.event.attributes count]);
    return [self.viewList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIView *view =[self.viewList objectAtIndex:indexPath.row];
    return view.frame.size.height;
//    NSString* type =[self.viewList objectAtIndex:indexPath.row];
//    if([type isEqualToString:ROW_TYPE_USER_DETAILS]){
//        return 70;
//    }else
//        return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SKSTableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
    }
    UIView *view =[self.viewList objectAtIndex:indexPath.row];
    [cell addSubview:view];
    
//    NSString* type =[self.viewList objectAtIndex:indexPath.row];
//    if([type isEqualToString:ROW_TYPE_USER_DETAILS]){
//        UIView* view = [self getViewForUserDetails];
//        [cell addSubview:view];
//    }else if([type isEqualToString:ROW_TYPE_LOGOUT]){
//        [cell addSubview:[self getViewForLogoutButton]];
//    }else if([type isEqualToString:ROW_TYPE_TEST_CONNECTION]){
//        [cell addSubview:[self getViewForLogoutButton]];
//    }
    return cell;
}


- (void) testConnectionButtonTouched {
    BOOL connectionAvailable = NO;
    NSString *endpoint = [NSUserDefaultsManager getObjectFromUserDeafults:PORTAL_ENDPOINT];
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
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Network Availability"
                                                          message:[NSString stringWithFormat:@"Connected To Endpoint:\n%@",endpoint]
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        
        [message show];
    }
}

- (void) settingsInfoButtonTouched {
    NSString* openUDID = [OpenUDID value];
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    if ([appName isEqualToString:@"CodeExplorer"]) {
        [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"CodeExplorer %@ \n Device Id: %@ \n", [DeviceManager getCurrentVersionOfTheApp], openUDID] message:@"Harvestmark Division Trimble Inc. © 2016. Protected by US Patent 7,770,783 and others. International and other patents pending." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
