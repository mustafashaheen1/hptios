//
//  CEScanViewController.h
//  Insights
//
//  Created by Vineet Pareek on 16/07/2015.
//  Copyright (c) 2015 Yottamark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "AFAppDotNetAPIClient.h"
#import "ParentNavigationViewController.h"
//#import "SWBarcodePickerManager.h"
#import "ErrorReport.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "ViewController.h"

@interface CEScanViewController : ParentNavigationViewController<UITextFieldDelegate,ScannerProtocol,UIAlertViewDelegate,MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *hmCodeTextBox;
@property (weak, nonatomic) IBOutlet UIButton *checkCodeButton;
@property (weak, nonatomic) IBOutlet UIButton *scanCodeButton;
@property (weak, nonatomic) IBOutlet UIImageView *banner;
@property (strong, nonatomic) SyncOverlayView *syncOverlayView;
@property (strong,nonatomic) ErrorReport* errorReport;
@property BOOL cancelPressed;
-(void) traceCode:(NSString*)hmCode withTraceMethod:(NSString*)traceMethod;
@end
