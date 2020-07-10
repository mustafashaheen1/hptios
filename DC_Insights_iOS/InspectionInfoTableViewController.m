//
//  InspectionInfoTableViewController.m
//  DC_Insights_iOS
//
//  Created by John Gifford on 11/5/13.
//  Copyright (c) 2013 Yottamark. All rights reserved.
//

#import "InspectionInfoTableViewController.h"
#import "InspectionTypeViewCell.h"
#import "InputScanViewCell.h"
#import "SelectViewCell.h"
#import "InputViewCell.h"
#import "CellBuilder.h"
@interface InspectionInfoTableViewController ()
@end
typedef enum InspectionType : NSUInteger {
    truckLoad,
    deliveryTruck,
    warehouse,
    unassigned
} InspectionType;
InspectionType inspectionType = 4;

@implementation InspectionInfoTableViewController
{
    NSArray *tableData;
    NSArray *inspectionTypes;
    InspectionTypeViewCell *inspectionTypeCell;
}
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    
    
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    tableData = [NSArray arrayWithObjects:@"Inspection Type & Camera Icon",@"", @"", @" ",@" ",@" ",@" ",@" ",@" ",@" ",nil];
    inspectionTypes = [NSArray arrayWithObjects:@"Truck Load",@"Delivery Truck",@"Warehouse",@"Mail",@"Shipment",nil];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
- (void) selectInspectionType
{
    CGFloat xWidth = self.view.bounds.size.width - 20.0f;
    CGFloat yHeight = 272.0f;
    CGFloat yOffset = (self.view.bounds.size.height - yHeight)/2.0f;
    UIPopoverListView *poplistview = [[UIPopoverListView alloc] initWithFrame:CGRectMake(10, yOffset, xWidth, yHeight)];
    poplistview.delegate = self;
    poplistview.datasource = self;
    poplistview.listView.scrollEnabled = TRUE;
    [poplistview setTitle:@"      Select Type"];
    [poplistview show];
    
    
}
#pragma mark - UIPopoverListViewDataSource

- (UITableViewCell *)popoverListView:(UIPopoverListView *)popoverListView
                    cellForIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                   reuseIdentifier:identifier];
    int row = indexPath.row;
    cell.textLabel.text = inspectionTypes[row];
    
    return cell;
}

- (NSInteger)popoverListView:(UIPopoverListView *)popoverListView
       numberOfRowsInSection:(NSInteger)section
{
    return inspectionTypes.count;
}

#pragma mark - UIPopoverListViewDelegate
- (void)popoverListView:(UIPopoverListView *)popoverListView
     didSelectIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%s : %ld", __func__, (long)indexPath.row);
    // your code here
    inspectionType = indexPath.row;
    inspectionTypeCell.inspectionTypeLabel.text = inspectionTypes[indexPath.row];
    NSIndexPath* indexPath1 = [NSIndexPath indexPathForRow:1 inSection:0];
    NSIndexPath* indexPath2 = [NSIndexPath indexPathForRow:2 inSection:0];
    NSIndexPath* indexPath3 = [NSIndexPath indexPathForRow:3 inSection:0];
    NSIndexPath* indexPath4 = [NSIndexPath indexPathForRow:4 inSection:0];
    NSIndexPath* indexPath5 = [NSIndexPath indexPathForRow:5 inSection:0];
    NSArray* indexArray = [NSArray arrayWithObjects:indexPath1, indexPath2,indexPath3, indexPath4, indexPath5, nil];
    [self.tableView reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationAutomatic];
    
}

- (CGFloat)popoverListView:(UIPopoverListView *)popoverListView
   heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableData count];
}
//TODO: Save text field and rating data when scrolling away.
//TODO: Navigate to defects screen upon quality button click.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"%lu is type", inspectionType);
    if(indexPath.row == 0)  //Select Truck or Warehouse
    {
        InspectionTypeViewCell *cell = (InspectionTypeViewCell *)[tableView dequeueReusableCellWithIdentifier:nil];
        if(cell==nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CellInspectionType" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        cell.parentTableView = tableView;
        inspectionTypeCell = cell;
        cell.tapHandler = ^(NSUInteger tag){
            [self selectInspectionType];
        };
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.cameraButton addTarget:self action:@selector(cameraClick:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
    else{
        if(inspectionType == truckLoad)
        {
            if(indexPath.row == 1)
            {
                InputScanViewCell *cell = [CellBuilder createInputScanCell:tableView];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
            
            if(indexPath.row == 3)
            {
                SelectViewCell *cell = [CellBuilder createSelectCell:tableView];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
            if(indexPath.row == 4)
            {
                InputViewCell *cell = [CellBuilder createInputCell:tableView];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }

            
        }
        else if(inspectionType == deliveryTruck)
        {
            /* Delivery Truck:
             -Comments
             -Quality
             -Scan code
             -Scan code
             -Select */
            if(indexPath.row == 1){
                InputViewCell *cell = [CellBuilder createInputCell:tableView];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
        
            if(indexPath.row == 3)
            {
                InputScanViewCell *cell = [CellBuilder createInputScanCell:tableView];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
            if(indexPath.row == 4)
            {
                InputScanViewCell *cell = [CellBuilder createInputScanCell:tableView];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
            if(indexPath.row == 5)
            {
                SelectViewCell *cell = [CellBuilder createSelectCell:tableView];
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
        }
        /*
         Warehouse:
         -Scan Code
         -Comments
         */
        else if(inspectionType == warehouse)
        {
            
            if(indexPath.row == 1)
            {
                InputScanViewCell *cell = [CellBuilder createInputScanCell:tableView];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
            if(indexPath.row == 2)
            {
                InputViewCell *cell = [CellBuilder createInputCell:tableView];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
        }
        
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(cell==nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        // Configure the cell...
        cell.textLabel.text =[tableData objectAtIndex:indexPath.row];
        return cell;
    };
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 78;
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
 #pragma mark - Navigation
 
 // In a story board-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 
 */

//Return to home screen
- (IBAction)homeButtonClick:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:TRUE];
}

- (IBAction)beginInspectionButton:(id)sender {
    [self performSegueWithIdentifier:@"selectProductSegue" sender:self];
}
- (IBAction)selectDefectsClick:(id)sender {
    [self performSegueWithIdentifier:@"inspectDefectsSegue" sender:self];
}
@end
