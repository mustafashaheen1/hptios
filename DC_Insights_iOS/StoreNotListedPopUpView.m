//
//  StoreNotListedPopUpView.m
//  DC Insights
//
//  Created by Shyam Ashok on 8/27/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "StoreNotListedPopUpView.h"
#import "LocationManager.h"

@implementation StoreNotListedPopUpView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (IBAction)submitButtonPressed:(id)sender {
    if (![self.zipcodeTextField.text isEqualToString:@""] && ![self.zipcodeTextField.text isEqualToString:@""] && ![self.zipcodeTextField.text isEqualToString:@""]) {
        Store *store = [self processStoreObject];
        [[self delegate] submitInformation:store];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Fields cannot be empty" message: @"" delegate: self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }
}

- (Store *) processStoreObject {
    Store *store = [[Store alloc] init];
    store.storeEnteredByUser = YES;
    store.name = self.nameTextField.text;
    store.address = self.addressTextField.text;
    store.postCode = [self.zipcodeTextField.text integerValue];
    CLLocation *currentLocation = [[LocationManager sharedLocationManager] currentLocation];
    store.latitude = currentLocation.coordinate.latitude;
    store.longitude = currentLocation.coordinate.longitude;
    return store;
}

@end
