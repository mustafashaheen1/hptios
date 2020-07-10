//
//  InspectionStatusViewControllerRetailViewController.m
//  Insights
//
//  Created by Shyam Ashok on 8/29/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "InspectionStatusViewControllerRetailViewController.h"
#import "Inspection.h"
#import "SavedAudit.h"
#import "HomeScreenViewController.h"
#import "ProductSelectAutoCompleteViewController.h"
#import "ProductViewController.h"
#import "UIAlertView+NSCookbook.h"


@interface InspectionStatusViewControllerRetailViewController ()

@end

@implementation InspectionStatusViewControllerRetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) setupNavBar {
    [super setupNavBar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.pageTitle = @"InspectionStatusViewControllerRetailViewController";
    [self setupNavBar];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.productAudits = [[Inspection sharedInspection] getAllSavedAuditsForInspection];
    NSMutableArray *productsMutable = [[NSMutableArray alloc] init];
    for (SavedAudit *savedAudit in self.productAudits) {
        Product *product = [self getProduct:savedAudit.productGroupId withProductID:savedAudit.productId];
        [productsMutable addObject:product];
    }
    self.products = [productsMutable copy];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        [self loadTheProducts];
        self.productGroups = [self createProductsAndProductGroupsWithSavedAudits];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self tableViewSetup];
            [self.table reloadData];
        });
    });
}

- (void) loadTheProducts {
    if ([self.productGroups count] > 0) {
        self.productGroups = [[Inspection sharedInspection].productGroups mutableCopy];
    } else {
        self.productGroups = [[[Inspection sharedInspection] getProductGroups] mutableCopy];
        [Inspection sharedInspection].productGroups = self.productGroups;
    }
}

- (NSMutableArray *) createProductsAndProductGroupsWithSavedAudits {
    NSMutableArray *productGroupsLocal = [NSMutableArray array];
    for (int i = 0; i < [self.productGroups count]; i++) {
        if ([[self.productGroups objectAtIndex:i] isKindOfClass:[Product class]]) {
            Product *product = [self.productGroups objectAtIndex:i];
            for (SavedAudit *savedAudit in self.productAudits) {
                if (product.product_id == savedAudit.productId && product.group_id == savedAudit.productGroupId) {
                    product.savedAudit = savedAudit;
                    [productGroupsLocal addObject:product];
                }
            }
        } else if ([[self.productGroups objectAtIndex:i] isKindOfClass:[ProgramGroup class]]) {
            ProgramGroup *pg = [self.productGroups objectAtIndex:i];
            NSMutableArray *savedAuditsMutable = [NSMutableArray array];
            BOOL hasSavedAudit = NO;
            for (Product *product in pg.products) {
                for (SavedAudit *savedAudit in self.productAudits) {
                    if (product.product_id == savedAudit.productId && pg.programGroupID == savedAudit.productGroupId) {
                        [savedAuditsMutable addObject:savedAudit];
                        hasSavedAudit = YES;
                    }
                }
            }
            if (hasSavedAudit) {
                pg.savedAudits = [savedAuditsMutable copy];
                [productGroupsLocal addObject:pg];
            }
        }
    }
    return productGroupsLocal;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void) tableViewSetup {
    //[self.tableSKS removeFromSuperview];
    self.tableSKS = [[SKSTableView alloc] init];
    self.tableSKS.frame = CGRectMake(0, 77, self.view.frame.size.width, self.view.frame.size.height - 230);
    if (IS_OS_7_OR_LATER) {
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
        {
            self.tableSKS.frame = CGRectMake(0, 55, self.view.frame.size.width, 860);
        }
        if (IS_IPHONE5) {
            self.tableSKS.frame = CGRectMake(0, 55, self.view.frame.size.width, self.view.frame.size.height - 58);
        }
    } else {
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
        {
            self.tableSKS.frame = CGRectMake(0, 55, self.view.frame.size.width, 860);
        }
        if (IS_IPHONE5) {
            self.tableSKS.frame = CGRectMake(0, 55, self.view.frame.size.width, self.view.frame.size.height - 120);
        }
        if (IS_IPHONE4) {
            self.tableSKS.frame = CGRectMake(0, 55, self.view.frame.size.width, self.view.frame.size.height - 210);
        }
    }
    [self.tableSKS setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    self.tableSKS.SKSTableViewDelegate = self;
    [self.tableSKS expandAllRowsAtIndexPaths];
    [self.view addSubview:self.tableSKS];
}



#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(SKSTableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(SKSTableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.productGroups count];
}

- (NSInteger)tableView:(SKSTableView *)tableView numberOfSubRowsAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[self.productGroups objectAtIndex:indexPath.row] isKindOfClass:[ProgramGroup class]]) {
        ProgramGroup *programGroup = [self.productGroups objectAtIndex:indexPath.row];
        return [programGroup.savedAudits count];
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(SKSTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SKSTableViewCell";
    
    SKSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
        cell = [[SKSTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    
    
    NSLog(@"indexpath.row %d", indexPath.row);
    cell.detailTextLabel.textColor = [UIColor blackColor];
    if ([[self.productGroups objectAtIndex:indexPath.row] isKindOfClass:[ProgramGroup class]]) {
        ProgramGroup *programGroup = [self.productGroups objectAtIndex:indexPath.row];
        int count = 0;
        for (SavedAudit *savedAudit in programGroup.savedAudits) {
            count = count + savedAudit.auditsCount;
        }
        cell.textLabel.text = programGroup.name;
        if ([[User sharedUser] checkForRetailInsights]) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d/%d", count, programGroup.audit_count];
        }
        cell.expandable = YES;
    } else {
        Product *product = [self.productGroups objectAtIndex:indexPath.row];
        cell.textLabel.text = product.product_name;
        if ([[User sharedUser] checkForRetailInsights]) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", product.auditsCount];
        }
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d/%d", product.savedAudit.auditsCount, product.auditsCount];
        cell.detailTextLabel.textColor = [UIColor blackColor];
        cell.expandable = NO;
    }
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForSubRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"UITableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    
    if ([[self.productGroups objectAtIndex:indexPath.row] isKindOfClass:[ProgramGroup class]]) {
        ProgramGroup *programGroup = self.productGroups[indexPath.row];
        SavedAudit *savedAudit = programGroup.savedAudits[indexPath.subRow - 1];
        cell.textLabel.text = savedAudit.productName;
        Product *productLocal;
        for (Product *product in self.products) {
            if (product.product_id == savedAudit.productId && programGroup.programGroupID == savedAudit.productGroupId) {
                productLocal = product;
            }
        }
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", savedAudit.auditsCount];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}


- (CGFloat)tableView:(SKSTableView *)tableView heightForSubRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Returns 60.0 points for all subrows.
    return 60.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[self.productGroups objectAtIndex:indexPath.row] isKindOfClass:[Product class]]) {
        Product *product = [self.productGroups objectAtIndex:indexPath.row];
        [self modifyInspectionButtonTouched:product.savedAudit];
    }
}

- (void)tableView:(SKSTableView *)tableView didSelectSubRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[self.productGroups objectAtIndex:indexPath.row] isKindOfClass:[ProgramGroup class]]) {
        ProgramGroup *prg = [self.productGroups objectAtIndex:indexPath.row];
        if ([[prg.products objectAtIndex:indexPath.subRow-1] isKindOfClass:[Product class]]) {
            SavedAudit *savedAudit = [prg.savedAudits objectAtIndex:indexPath.subRow-1];
            [self modifyInspectionButtonTouched:savedAudit];
        }
    }
}



- (Product *) getProduct:(int) groupId withProductID:(int) productId {
    Store *store = [[User sharedUser] currentStore];
    NSArray *groups = [store getAllGroupsOfProductsForTheStore];
    for (ProgramGroup *pg in groups) {
        if (pg.programGroupID == groupId) {
            NSArray *products = [pg getAllProducts];
            for (Product *p in products) {
                if (productId == p.product_id) {
                    [p getAllRatings];
                    NSMutableArray *ratingsForProductWithDefects = [[NSMutableArray alloc] init];
                    for (Rating *rating in p.ratings) {
                        [rating getAllDefects];
                        [ratingsForProductWithDefects addObject:rating];
                    }
                    p.ratings = [[NSArray alloc] init];
                    p.ratings = [ratingsForProductWithDefects copy];
                    return p;
                }
            }
        }
    }
    return nil;
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    //[self modifyInspectionButtonTouched:indexPath.row];
//}


- (void) cancelInspectionStatusTouched {
    NSString *cancel = @"Cancel Inspection?";
    NSString *cancelMessage = @"Cancelling the inspection will erase all work done";
    if ([[User sharedUser] checkForRetailInsights]) {
        cancel = @"Cancel Audit?";
        cancelMessage = @"Cancelling the audits will erase all work done";
    }
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:cancel message:cancelMessage
                          delegate:self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"Ok", nil];
    [alert setTag:2];
    [alert show];
    
    //[[Inspection sharedInspection] cancelInspection];
    //[self gotoHomeScreen];
}

- (void) finishForInspectionStatusTouched {
    NSString *finish = @"Finish Inspection?";
    NSString *preventString = @"Finishing the inspection will prevent further modifications.";
    NSString *cannotString = @"Cannot finish inspection with no audits completed.";
    if ([[User sharedUser] checkForRetailInsights]) {
        finish = @"Finish Audit?";
        preventString = @"Finishing the audit will prevent further modifications.";
        cannotString = @"Cannot finish audits.";
    }
    if ([self.productAudits count] > 0) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:finish message:preventString
                              delegate:self
                              cancelButtonTitle:@"Cancel"
                              otherButtonTitles:@"Ok", nil];
        [alert setTag:3];
        [alert show];
    } else {
        [[[UIAlertView alloc] initWithTitle:finish message:cannotString delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
    }
    //[[Inspection sharedInspection] finishInspection];
    //[self gotoHomeScreen];
}

- (void) gotoHomeScreen {
    BOOL homeViewPresent = NO;
    int index = 0;
    for (int i = 0; i < [self.navigationController.viewControllers count]; i++) {
        if ([[self.navigationController.viewControllers objectAtIndex:i] isKindOfClass:[HomeScreenViewController class]]) {
            homeViewPresent = YES;
            index = i;
        }
    }
    HomeScreenViewController *homeScreenViewController;
    if (!homeViewPresent) {
        homeScreenViewController = [[HomeScreenViewController alloc] initWithNibName:@"HomeScreenViewController" bundle:nil];
        [self.navigationController pushViewController:homeScreenViewController animated:NO];
    } else {
        homeScreenViewController = (HomeScreenViewController *) [self.navigationController.viewControllers objectAtIndex:index];
        [self.navigationController popToViewController:homeScreenViewController animated:NO];
    }
    [homeScreenViewController startNewInspectionButtonTouched:self];
}

- (IBAction)productSelectButtonTouched:(id)sender {
    BOOL productSelectPresent = NO;
    for (int i = 0; i < [self.navigationController.viewControllers count]; i++) {
        if ([[self.navigationController.viewControllers objectAtIndex:i] isKindOfClass:[ProductSelectAutoCompleteViewController class]]) {
            productSelectPresent = YES;
            ProductSelectAutoCompleteViewController *productSelectAutoCompleteViewController = (ProductSelectAutoCompleteViewController *) [self.navigationController.viewControllers objectAtIndex:i];
            [self.navigationController popToViewController:productSelectAutoCompleteViewController animated:YES];
        }
    }
    if (!productSelectPresent) {
        ProductSelectAutoCompleteViewController *productSelectAutoCompleteViewController = [[ProductSelectAutoCompleteViewController alloc] initWithNibName:@"ProductSelectAutoCompleteViewController" bundle:nil];
        [self.navigationController pushViewController:productSelectAutoCompleteViewController animated:YES];
    }
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
            [self gotoHomeScreen];
        }
    }
    // finish inspection
    else if(alertView.tag==3) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            //NSLog(@"cancelling inspection");
        }
        if (buttonIndex == alertView.firstOtherButtonIndex) {
            //NSLog(@"cancelling inspection");
            SCLAlertView *alert = [[SCLAlertView alloc] init];
            UIWindow *win = [[UIApplication sharedApplication] keyWindow];
            [alert showNotice:win.rootViewController title:@"Finishing Up" subTitle:@"Please wait.." closeButtonTitle:nil duration:1.0f];
            [self performSelector:@selector(performFinish) withObject:self afterDelay:1];
        }
    }
    else {
        if (buttonIndex == 1) {
            if (![[[alertView textFieldAtIndex:0] text] isEqualToString:@""]) {
                [[Inspection sharedInspection] saveInspection:[[alertView textFieldAtIndex:0] text]];
                [self gotoHomeScreen];
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Name Cant be Empty" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            }
        }
    }
}

- (void) performFinish {
    UIWindow *win = [[UIApplication sharedApplication] keyWindow];
    self.syncOverlayView = [[SyncOverlayView alloc] initWithFrame:CGRectMake(0, 0, win.frame.size.width, win.frame.size.height)];
    self.syncOverlayView.headingTitleLabel.text = finisingUp;
    [self.syncOverlayView showActivityView];
    [win addSubview:self.syncOverlayView];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        [[Inspection sharedInspection] finishInspection];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self gotoHomeScreen];
            [self.syncOverlayView dismissActivityView];
            [self.syncOverlayView removeFromSuperview];
        });
    });
}

- (void) modifyInspectionButtonTouched: (SavedAudit *) savedAudit {
    BOOL productViewControllerPresent = NO;
    for (int i = 0; i < [self.navigationController.viewControllers count]; i++) {
        if ([[self.navigationController.viewControllers objectAtIndex:i] isKindOfClass:[ProductViewController class]]) {
            productViewControllerPresent = YES;
            ProductViewController *productViewController = (ProductViewController *) [self.navigationController.viewControllers objectAtIndex:i];
            productViewController.savedAudit = savedAudit;
            UserNetworkActivityView *activityView = [UserNetworkActivityView sharedActivityView];
            [activityView setCustomMessage:@"Loading View"];
            if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
                [activityView show:self withOperation:nil showCancel:NO];
            }
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                [productViewController refreshState];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController popToViewController:productViewController animated:YES];
                    if (![UserNetworkActivityView sharedActivityView].hidden)
                        [[UserNetworkActivityView sharedActivityView] hide];
                });
            });
        }
    }
    if (!productViewControllerPresent) {
        ProductViewController *productViewController = [[ProductViewController alloc] initWithNibName:@"ProductViewController" bundle:nil];
        productViewController.savedAudit = savedAudit;
        UIWindow *win = [[UIApplication sharedApplication] keyWindow];
        self.syncOverlayView = [[SyncOverlayView alloc] initWithFrame:CGRectMake(0, 0, win.frame.size.width, win.frame.size.height)];
        self.syncOverlayView.headingTitleLabel.text = @"Loading View";
        [self.syncOverlayView showActivityView];
        [win addSubview:self.syncOverlayView];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            [productViewController refreshState];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController pushViewController:productViewController animated:YES];
                [self.syncOverlayView dismissActivityView];
                [self.syncOverlayView removeFromSuperview];
            });
        });
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
