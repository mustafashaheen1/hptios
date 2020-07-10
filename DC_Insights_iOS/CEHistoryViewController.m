//
//  CEHistoryViewController.m
//  Insights
//
//  Created by Vineet Pareek on 19/10/2016.
//  Copyright © 2016 Yottamark. All rights reserved.
//

#import "CEHistoryViewController.h"
#import "CEScanViewController.h"

#define ALERT_DELETE_HISTORY 99

@interface CEHistoryViewController ()

@end

@implementation CEHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void) setupNavBar {
    [super setupNavBar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.pageTitle = @"CEHistoryViewController";
    [self setupNavBar];
    [self populateHistory];
}

-(void)populateHistory{
    CEHistoryList* history = [[CEHistoryList alloc]init];
    self.allHistory = [history getAllHistoryFromPrefs];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //NSLog(@"event attirbs are: %d", [self.event.attributes count]);
    return [self.allHistory.historyList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SKSTableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
    }
    
    CEHistory *history = [self.allHistory.historyList objectAtIndex:indexPath.row];
    NSString* dateAndCodeString = [NSString stringWithFormat:@"(%@) - %@",history.date,history.hmCode ];
    cell.textLabel.text = dateAndCodeString;
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0f];
    cell.detailTextLabel.text = history.productName;
    cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0f];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CEHistory *history = [self.allHistory.historyList objectAtIndex:indexPath.row];
    NSString* code = history.hmCode;
    [self popToScanScreenAndTraceCode:code];
}

-(void)discardIconTouched{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Clear History" message:@"Do you want to clear the history?"
                          delegate:self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"Ok", nil];
    [alert setTag:ALERT_DELETE_HISTORY];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == ALERT_DELETE_HISTORY && buttonIndex == alertView.firstOtherButtonIndex) {
        [self clearHistory];
    }
}

-(void)clearHistory{
    CEHistoryList* history = [[CEHistoryList alloc]init];
    [history clearHistory];
    self.allHistory.historyList = [[NSMutableArray<CEHistory> alloc]init];
    [self.tableView reloadData];
}

- (void) popToScanScreenAndTraceCode:(NSString*)hmCode {
    BOOL homeViewPresent = NO;
    int index = 0;
    for (int i = 0; i < [self.navigationController.viewControllers count]; i++) {
        if ([[self.navigationController.viewControllers objectAtIndex:i] isKindOfClass:[CEScanViewController class]]) {
            homeViewPresent = YES;
            index = i;
        }
    }
    CEScanViewController *homeScreenViewController;
    if (!homeViewPresent) {
        homeScreenViewController = [[CEScanViewController alloc] initWithNibName:@"CEScanViewController" bundle:nil];
        [self.navigationController pushViewController:homeScreenViewController animated:NO];
    } else {
        homeScreenViewController = (CEScanViewController *) [self.navigationController.viewControllers objectAtIndex:index];
        [self.navigationController popToViewController:homeScreenViewController animated:NO];
            }
    //[homeScreenViewController traceCode:@"048733612735DS29" withTraceMethod:CE_TRACE_METHOD_HISTORY] ;
    [homeScreenViewController traceCode:hmCode withTraceMethod:CE_TRACE_METHOD_HISTORY] ;
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
