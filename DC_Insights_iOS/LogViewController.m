//
//  LogViewController.m
//  shopwell
//
//  Created by Shyam Ashok on 2/10/14.
//
//

#import "LogViewController.h"
#import "Constants.h"

@interface LogViewController ()

@end

@implementation LogViewController
@synthesize logsView;
@synthesize emailButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [self.emailButton setEnabled:[MFMailComposeViewController canSendMail]];
    self.pageTitle = @"LogViewController";
    // loads the content of the log file
    NSString *content = [[NSString alloc] initWithContentsOfFile:[self locationFilePath] usedEncoding:nil error:nil];
    [self.logsView setText:content];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logReceived:) name:@"logReceived" object:nil];
    [super viewDidLoad];
}

- (NSString *)locationFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [NSString stringWithFormat:@"%@/%@.%@", documentsDirectory, LOCATIONS_FILE, LOCATIONS_FILE_TYPE];
    return path;
}


- (void) logReceived:(NSNotification *)notification
{
    NSLog(@"lsodjf %@", self.logsView.text);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.logsView setText:[NSString stringWithFormat:@"%@%@", self.logsView.text, notification.object]];
        [self.logsView scrollRangeToVisible:NSMakeRange([self.logsView.text length], 0)];
    });
}

- (IBAction)reset:(id)sender {
    UIAlertView *debugAlert = [[UIAlertView alloc] initWithTitle:@"Are you sure you want to reset the log file?" message:nil delegate:self cancelButtonTitle:@"Reset" otherButtonTitles:@"Cancel", nil];
    [debugAlert show];
}

- (IBAction)email:(id)sender {
    NSData * data = [NSData dataWithContentsOfFile: [self locationFilePath]];
    NSString *content = self.logsView.text;
    NSLog(@"content %@", content);
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setSubject:@"Debug Log"];
    [controller setMessageBody:self.logsView.text isHTML:NO];
    [controller addAttachmentData:data mimeType:@"text/plain" fileName:@"AuditsLog "];
    if (controller) {
        [self presentModalViewController:controller animated:YES];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == alertView.cancelButtonIndex) {
        //NSLog(@"cancelling inspection");
    }
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        self.logsView.text = @"";
    }
}


#pragma mark - Alert View delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Reset"]) {
        NSDate *date = [NSDate date];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy/MM/dd hh:mm aaa"];
        NSString *content = [NSString stringWithFormat:@"%@", [dateFormat stringFromDate:date]];
        [content writeToFile:[self locationFilePath]
                  atomically:NO
                    encoding:NSStringEncodingConversionAllowLossy
                       error:nil];
        [self.logsView setText:content];
    }
}

#pragma mark - Mail delegate

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.logsView scrollRangeToVisible:NSMakeRange([self.logsView.text length], 0)];
    [super viewWillAppear:animated];
}

- (void)viewDidUnload
{
    [self setLogsView:nil];
    [self setEmailButton:nil];
    [super viewDidUnload];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSRange resultRange = [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet] options:NSBackwardsSearch];
    if ([text length] == 1 && resultRange.location != NSNotFound) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}


@end
