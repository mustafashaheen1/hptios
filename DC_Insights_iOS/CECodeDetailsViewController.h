//
//  CECodeDetailsViewController.h
//  Insights
//
//  Created by Vineet Pareek on 19/10/2016.
//  Copyright © 2016 Yottamark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CEResponse.h"
#import "ParentNavigationViewController.h"
#import "SKSTableViewCell.h"
#import "SKSTableView.h"
#import "UIPopoverListView.h"
#import "RowSectionPopOverListView.h"
#import <MessageUI/MFMailComposeViewController.h>

@interface CECodeDetailsViewController : ParentNavigationViewController<UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, SKSTableViewDelegate,UIPopoverListViewDelegate,UIAlertViewDelegate,MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *productImage;
@property (weak, nonatomic) IBOutlet UIImageView *brandImage;
@property (weak, nonatomic) IBOutlet UILabel *hmCodeLabel;

@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;
@property (weak, nonatomic) IBOutlet SKSTableView *eventsTableView;

@property (nonatomic,strong) CEResponse* apiResponse;
@property NSString* tracedUrl;

@end
