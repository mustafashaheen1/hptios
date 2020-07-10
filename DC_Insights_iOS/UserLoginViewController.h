//
//  UserLocationSelectViewController.h
//  DC_Insights_iOS
//
//  Created by John Gifford on 11/5/13.
//  Copyright (c) 2013 Yottamark. All rights reserved.
//
//  This is the location selection view controller, currently
//  also the root view.  The location table is hidden until
//  a user is selected.  Once a location is selected,
//  the "inspectioninfotableview" will be loaded.

#import <UIKit/UIKit.h>
#import "UIPopoverListView.h"
#import "UserAPI.h"
#import "UserNetworkActivityViewProtocol.h"
#import "UserNetworkActivityView.h"
#import "ParentNavigationViewController.h"
#import <Google/SignIn.h>

@interface UserLoginViewController : ParentNavigationViewController <UITextFieldDelegate, UserNetworkActivityViewProtocol, UITableViewDelegate, UITableViewDataSource,GIDSignInUIDelegate, GIDSignInDelegate> {
    BOOL checked;
}

@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UIButton *selectUserButton;
@property (strong, nonatomic) IBOutlet UIButton *forgotPasswordButton;
@property (weak, nonatomic) IBOutlet UIButton *checkBoxButton;
@property (strong, nonatomic) UITableView *table;
@property (strong, nonatomic) NSMutableArray *previousSignIns;
@property (strong, nonatomic) NSArray *previousSignInsForAutoComplete;
@property (strong,nonatomic) UIImageView *brandingImage;
@property (assign,atomic) int tapCount;
@property(weak, nonatomic) IBOutlet GIDSignInButton *signInButton;
@property (weak, nonatomic) IBOutlet UIImageView *banner;
@property (weak, nonatomic) IBOutlet UIImageView *poweredByLogo;



- (IBAction)loginUserButton:(id)sender;
- (IBAction)forgotPasswordButtonTouched:(id)sender;
- (IBAction)Exit:(id)sender;
- (IBAction)checkButton:(id)sender;
- (IBAction)usernameTextFieldTouched:(id)sender;
- (IBAction)displayEndpointSelectionMenu:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *headerImage;


@end
