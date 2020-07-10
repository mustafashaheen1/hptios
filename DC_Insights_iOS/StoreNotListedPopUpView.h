//
//  StoreNotListedPopUpView.h
//  DC Insights
//
//  Created by Shyam Ashok on 8/27/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Store.h"

@protocol StoreNotListedPopUpViewDelegate <NSObject>
@required
- (void) submitInformation: (Store *) storeValue;
@end

@interface StoreNotListedPopUpView : UIView <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIButton *submitButton;
@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UITextField *addressTextField;
@property (strong, nonatomic) IBOutlet UITextField *zipcodeTextField;
@property (retain) id <StoreNotListedPopUpViewDelegate> delegate;

- (IBAction)submitButtonPressed:(id)sender;

@end
