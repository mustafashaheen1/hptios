//
//  InspectionViewControllerWithTableViewController.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/19/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "InspectionViewControllerWithTableViewController.h"

#define heightForCells 50;

@interface InspectionViewControllerWithTableViewController ()

@end

@implementation InspectionViewControllerWithTableViewController

@synthesize defectsArray;
@synthesize majorMinorMediumArray;
@synthesize tableDefectsTotalArray;
@synthesize table;

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.pageTitle = @"InspectionViewControllerWithTableViewController";
    [self setupNavBar];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupContentForTheTableView];
    self.table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 500) style:UITableViewStylePlain];
    self.table.delegate = self;
    self.table.dataSource = self;
    [self.view addSubview:self.table];
    //[self calculateTheNumberOfRowsAndReturnHeight];
    
    // Do any additional setup after loading the view from its nib.
}

- (CGFloat) calculateTheNumberOfRowsAndReturnHeight {
    int numberOfRows = 2+5+5+1;
    CGFloat heightForTableView = numberOfRows * heightForCells;
    int numberOfProductsHeights = 50;
    heightForTableView = heightForTableView + numberOfProductsHeights;
    return heightForTableView;
}

- (void) setupContentForTheTableView {
    self.defectsArray = [[NSMutableArray alloc] init];
    [self.defectsArray addObject:@"Discoloration"];
    //[self.defectsArray addObject:@"Expired"];
    //[self.defectsArray addObject:@"Size Defects"];
    
    self.majorMinorMediumArray = [[NSMutableArray alloc] init];
    [self.majorMinorMediumArray addObject:@"Major"];
    [self.majorMinorMediumArray addObject:@"Medium"];
    [self.majorMinorMediumArray addObject:@"Minor"];
    
    self.tableDefectsTotalArray = [[NSMutableArray alloc] init];
    [self.tableDefectsTotalArray addObject:@"Discoloration"];
    [self.tableDefectsTotalArray addObject:@"Major"];
    [self.tableDefectsTotalArray addObject:@"Medium"];
    [self.tableDefectsTotalArray addObject:@"Minor"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return 2;
    } else if (section == 1) {
        return [self.tableDefectsTotalArray count] + 1;
    } else if (section == 2) {
        return 5;
    } else if (section == 3) {
        return 1;
    }
    
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Inspection Samples";
            cell.textLabel.textColor = [UIColor blueColor];
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Percentage Of Cases";
            cell.textLabel.textColor = [UIColor blueColor];
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Product Quality";
            cell.textLabel.textColor = [UIColor blueColor];
        } else {
            cell.textLabel.text = [self.tableDefectsTotalArray objectAtIndex:indexPath.row-1];
        }
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Totals";
            cell.textLabel.textColor = [UIColor blueColor];
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Major";
        } else if (indexPath.row == 2) {
            cell.textLabel.text = @"Medium";
        } else if (indexPath.row == 3) {
            cell.textLabel.text = @"Minor";
        } else if (indexPath.row == 4) {
            cell.textLabel.text = @"Grand Total";
            cell.textLabel.textColor = [UIColor blueColor];
        }
    } else if (indexPath.section == 3) {
        cell.textLabel.text = @"Inspection Status";
        cell.textLabel.textColor = [UIColor blueColor];
    }
    // Configure the cell...
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return heightForCells;
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Table view delegate
 
 // In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Navigation logic may go here, for example:
 // Create the next view controller.
 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
 
 // Pass the selected object to the new view controller.
 
 // Push the view controller.
 [self.navigationController pushViewController:detailViewController animated:YES];
 }
 
 */

@end
