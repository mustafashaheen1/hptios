//
//  StoreSelectPopUp.h
//  DC Insights
//
//  Created by Shyam Ashok on 8/27/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Store.h"
#import "SyncOverlayView.h"

@protocol StoreSelectPopUpViewDelegate <NSObject>
@required
- (void) submitInformationStoreSelect: (Store *) storeValue;
@end


@interface StoreSelectPopUpView : UIView <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) IBOutlet UIButton *storeNotListedButton;
@property (strong, nonatomic) NSArray *stores;
@property (strong, nonatomic) SyncOverlayView *syncOverlayView;
@property (strong, nonatomic) IBOutlet UILabel *selectYourStoreLabel;
@property (strong, nonatomic) IBOutlet UILabel *alertMessage;
@property (retain) id <StoreSelectPopUpViewDelegate> delegate;

- (void) retrieveStores;
- (void) hideTableViewAndShowAlert;

@end
