//
//  UserSelectViewController.h
//  DC_Insights_iOS
//
//  Created by John Gifford on 11/5/13.
//  Copyright (c) 2013 Yottamark. All rights reserved.
//
//  This controller is for the user select view.  Currently implemented
//  as a spinner widget control.  Will save user as a class object that will
//  be passed around.

#import <UIKit/UIKit.h>
#import "User.h"
@class UserSelectViewController;

//Delegation for spinner widget
@protocol UserSelectViewControllerDelegate <NSObject>
- (void)userSelectViewControllerDidCancel: (UserSelectViewController *)controller;
- (void)userSelectViewController:(UserSelectViewController *)controller
                       didAddUser:(User *)user;
@end

@interface UserSelectViewController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate>
@property (strong, nonatomic) IBOutlet UIPickerView *userPicker;
@property (nonatomic, weak) id <UserSelectViewControllerDelegate> delegate;
- (IBAction)done:(id)sender;
- (IBAction)cancel:(id)sender;
//This will be loaded from database through network connection.  
@property (nonatomic, strong) NSArray *usersArray;
@end
