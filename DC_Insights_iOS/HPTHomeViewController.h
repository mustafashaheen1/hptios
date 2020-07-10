//
//  HPTHomeViewController.h
//  Insights-Trimble-Enterprise
//
//  Created by Mustafa Shaheen on 6/16/20.
//  Copyright © 2020 Yottamark. All rights reserved.
//

#import "ParentNavigationViewController.h"
#import "InspectionTableViewCell.h"
#import "SyncManager.h"
#import "SyncOverlayView.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "LogViewController.h"
#import "CompleteInspectionsListViewController.h"
#import "UploadCompleteView.h"

@interface HPTHomeViewController : ParentNavigationViewController <SyncManagerDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UIButton *logout;
@property (weak, nonatomic) IBOutlet UIButton *outgoingShipment;
@property (strong, nonatomic) SyncManager *syncManager;
@end


