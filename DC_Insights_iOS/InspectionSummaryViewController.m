//
//  InspectionSummaryViewController.m
//  Insights
//
//  Created by Vineet Pareek on 26/10/2015.
//  Copyright © 2015 Yottamark. All rights reserved.
//

#import "InspectionSummaryViewController.h"
#import "Inspection.h"
#import "UIAlertView+NSCookbook.h"

@interface InspectionSummaryViewController ()

@end

@implementation InspectionSummaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setupNavBar {
    [super setupNavBar];
    self.cancelButton.enabled = NO;
    self.finishButton.enabled = NO;
    self.saveButton.enabled = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.pageTitle = @"InspectionSummaryViewController";
    self.statusValues = [NSArray arrayWithObjects: @"Accept", @"Accept With Issues", @"Reject", nil];
    [self showLoadingScreenWithMessage:@"Loading Summary..."];
    [self setupNavBar];
    //[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:introducingDelayForDuplicates]];
    self.cancelButton.enabled = YES;
    self.finishButton.enabled = YES;
    self.saveButton.enabled = YES;
}

//adding table manually
- (void) tableViewSetup {
    self.table = [[SKSTableView alloc] initWithFrame:CGRectMake(0, 55, self.view.frame.size.width, self.view.frame.size.height - 50)];
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        self.table.frame = CGRectMake(0, 95, self.view.frame.size.width, self.view.frame.size.height);
    }
    if (IS_IPHONE5) {
        self.table.frame = CGRectMake(0, 55, self.view.frame.size.width, self.view.frame.size.height - 50);
    }
    self.table.SKSTableViewDelegate = self;
    self.table.shouldExpandOnlyOneCell = YES;
    self.table.inspectionStatusViewController = YES;
    [self.view addSubview:self.table];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //get array of SavedAudits that would be shown on screen
        if ([[Inspection sharedInspection] checkForOrderData]) {
            if ([[Inspection sharedInspection].productGroups count] < 1) {
                [Inspection sharedInspection].productGroups = [[User sharedUser].currentStore getProductGroups];
            }
            NSString *poNumber = [Inspection sharedInspection].poNumberGlobal;
            NSSet *set;
            if((![poNumber  isEqual: @""]) && (poNumber != nil)){
                set = [OrderData getItemNumbersForPONumberSelected];
            }
            else{
                set = [OrderData getItemNumbersForGRNSelected];
            }
            NSArray *newProductGroupsArray = [[Inspection sharedInspection] filteredProductGroups:set];
            [Inspection sharedInspection].productGroups = newProductGroupsArray;
            self.allSavedAudits = [[Inspection sharedInspection] getAllSavedAndFakeAuditsForInspection];
        }else
            self.productAudits = [[Inspection sharedInspection] getAllSavedAuditsForInspection];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //when non-orderdata, showCountOfCases dialog
            [self tableViewSetup];
            [self.syncOverlayView dismissActivityView];
            [self.syncOverlayView removeFromSuperview];
        });
        
    });
    
}

-(void)showCountOfCasesDialog {
    for (SavedAudit *savedAudit in self.productAudits) {
        if (savedAudit.countOfCases <= 0 && ![[Inspection sharedInspection] checkForOrderData]) {
            //[self showAlertForCountOfCasesEntering:savedAudit.productName];
            }
    }
}

- (void) showAlertForCountOfCasesEntering: (NSString *) productName withSavedAudit:(SavedAudit *) savedAudit {
    NSString *text = [NSString stringWithFormat:@"Please enter count of cases for %@.", savedAudit.productName];
    if ([savedAudit.productName isEqualToString:@""]) {
        text = [NSString stringWithFormat:@"Please enter count of cases."];
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:text
                                                    message:@""
                                                   delegate:self
                                          cancelButtonTitle:@"Done"
                                          otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textField = [alert textFieldAtIndex:0];
    textField.keyboardType = UIKeyboardTypeNumberPad;
    [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
        NSLog(@"%@", [alertView textFieldAtIndex:0].text);
        if (![[alertView textFieldAtIndex:0].text isEqualToString:@""]) {
            NSString *countString = [alertView textFieldAtIndex:0].text;
            int countOfCases = [countString integerValue];
            if (countOfCases > 0) {
                //[self getSummaryAndUpdateCountOfCasesNoMatterWhat:savedAudit withCountOfCases:countOfCases withDatabase:nil];
            } else {
                [self showAlertForCountOfCasesEntering:@"" withSavedAudit:savedAudit];
            }
        } else {
            [self showAlertForCountOfCasesEntering:@"" withSavedAudit:savedAudit];
        }
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
       // cancel inspection
   if(alertView.tag==2) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            //NSLog(@"cancelling inspection");
        }
        if (buttonIndex == alertView.firstOtherButtonIndex) {
            //NSLog(@"cancelling inspection");
            [[Inspection sharedInspection] cancelInspection];
            //[self gotoHomeScreen];
        }
    }
    // finish inspection
    else if(alertView.tag==3) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            //NSLog(@"cancelling inspection");
        }
        if (buttonIndex == alertView.firstOtherButtonIndex) {
            //NSLog(@"cancelling inspection");
            //[self finishButtonTapped];
        }
    }
    else {
        if (buttonIndex == 1) {
            if (![[[alertView textFieldAtIndex:0] text] isEqualToString:@""]) {
                [[Inspection sharedInspection] saveInspection:[[alertView textFieldAtIndex:0] text]];
               // [self gotoHomeScreen];
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Name Cant be Empty" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            }
        }
    }
}




    -(void)showLoadingScreenWithMessage:(NSString*)message{
        if(!message)
            message = @"Loading...";
        UIWindow *win = [[UIApplication sharedApplication] keyWindow];
        self.syncOverlayView = [[SyncOverlayView alloc] initWithFrame:CGRectMake(0, 0, win.frame.size.width, win.frame.size.height)];
        self.syncOverlayView.headingTitleLabel.text = message;
        [self.syncOverlayView showActivityView];
        [win addSubview:self.syncOverlayView];
    }
    
    -(void)dismissLoadingScreen{
        [self.syncOverlayView dismissActivityView];
        [self.syncOverlayView removeFromSuperview];
    }
    
    
    - (IBAction)selectProductButtonTouched:(id)sender {
        
    }
    
    /*
     #pragma mark - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     }
     */
    
    @end
