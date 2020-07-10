//
//  LogViewController.h
//  shopwell
//
//  Created by Shyam Ashok on 2/10/14.
//
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "ParentNavigationViewController.h"

@interface LogViewController : ParentNavigationViewController <MFMailComposeViewControllerDelegate, UIAlertViewDelegate, UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UITextView *logsView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *emailButton;

- (IBAction)reset:(id)sender;
- (IBAction)email:(id)sender;
- (void) initiateNotificationForLog;

@end
