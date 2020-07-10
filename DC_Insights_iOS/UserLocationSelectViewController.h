//
//  UserLocationSelectViewController.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/7/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParentNavigationViewController.h"
#import "StoreLocationTableViewCell.h"
#import "SyncManager.h"
#import "SyncOverlayView.h"
#import "CustomIOS7AlertView.h"
#import "StoreSelectPopUpView.h"
#import "StoreNotListedPopUpView.h"

@interface UserLocationSelectViewController : ParentNavigationViewController <UITableViewDataSource, UITableViewDelegate, SyncManagerDelegate, CustomIOS7AlertViewDelegate, StoreNotListedPopUpViewDelegate, StoreSelectPopUpViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *table;
@property (nonatomic, strong) IBOutlet StoreLocationTableViewCell *storeLocationTableViewCell;
@property (nonatomic, strong) NSArray *storesArray;
@property (nonatomic, strong) SyncManager *syncManager;
@property (nonatomic, strong) SyncOverlayView *syncOverlay;
@property (nonatomic, strong) IBOutlet StoreSelectPopUpView *storeSelectPopUp;
@property (nonatomic, strong) IBOutlet StoreNotListedPopUpView *storeNotListedPopUpView;
@property (nonatomic, strong) CustomIOS7AlertView *alertView;
@property (nonatomic, strong) IBOutlet UILabel *storeLocationLabel;
@property (nonatomic, strong) IBOutlet UIButton *nearbyLocationsButton;

/*!
 *  This Reload method is called when "Sync Now" button is tapped from the Settings View.
 */
- (void) reloadTableWithNewSyncValues;

/*!
 *  This method brings a popUp for specifying Nearby locations (Either using Shopwell's store database or user entered store) (Retail Insights)
 *
 *  @param sender self
 */
- (IBAction)nearbyLocationsButtonPressed:(id)sender;

@end
