//
//  CECodeDetailsViewController.m
//  Insights
//
//  Created by Vineet Pareek on 19/10/2016.
//  Copyright © 2016 Yottamark. All rights reserved.
//

#import "CECodeDetailsViewController.h"
#import "UIImageView+WebCache.h"
#import "CECodeDetailsExapndedView.h"
#import "Constants.h"
#import "CEHistoryViewController.h"


@interface CECodeDetailsViewController ()

@end

#define EXPANDED_VIEW_BUFFER 20;

@implementation CECodeDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //NSLog(@"Api Response is: %@", self.apiResponse);
}

- (void) setupNavBar {
    [super setupNavBar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.pageTitle = @"CECodeDetailsViewController";
    [self setupNavBar];
    self.productNameLabel.text = self.apiResponse.product.name;
    self.productNameLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:20.0f];
    self.hmCodeLabel.text = self.apiResponse.code;
    self.hmCodeLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:20.0f];
    NSString* productImageUrl = self.apiResponse.product.image_url;
    NSString* brandImageUrl = self.apiResponse.product.brand.image_url;
    
    [self.brandImage sd_setImageWithURL:[NSURL URLWithString:brandImageUrl] placeholderImage:nil];
    [self.productImage sd_setImageWithURL:[NSURL URLWithString:productImageUrl]
                         placeholderImage:nil];
    
    [self tableViewSetup];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)emailButtonTouched {
    //NSString *string = [self.apiResponse toJSONString]; //need to show the exact email format
    NSString *emailText = [self getEmailText]; //need to show the exact email format
    if([[DeviceManager getDeviceID] isEqualToString:@"iOS_Simulator"]){
        NSLog(@"CodeExplorer Email: \n %@",emailText);
        return;
    }
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setSubject:[self getEmailSubject]];
    [controller setToRecipients:[NSArray arrayWithObjects:@"nkaura@yottamark.com", nil]];
    [controller setMessageBody:emailText isHTML:NO];
    NSLog(@"Debug Log Email: \n %@",emailText);
    //[controller addAttachmentData:data mimeType:@"db" fileName:@"offlineData"];
    if (controller) {
        [self presentModalViewController:controller animated:YES];
    }

}

#pragma mark - Mail delegate

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    [self dismissModalViewControllerAnimated:YES];
}


-(void) listButtonTouched {
    CEHistoryViewController* historyViewController = [[CEHistoryViewController alloc]initWithNibName:@"CEHistoryViewController" bundle:nil];
    [self.navigationController pushViewController:historyViewController animated:NO]; //push or modal??
}


#pragma mark - TableView
- (void) tableViewSetup {
    self.eventsTableView.SKSTableViewDelegate = self;
    self.eventsTableView.shouldExpandOnlyOneCell = YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.apiResponse.events count];
}

- (NSInteger)tableView:(SKSTableView *)tableView numberOfSubRowsAtIndexPath:(NSIndexPath *)indexPath
{
    return 1; //CECodeDetailsExapndedView
}

- (CGFloat)tableView:(SKSTableView *)tableView heightForSubRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self getHeightForEventAtIndexPath:indexPath];
}

- (CGFloat)tableView:(SKSTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CE_EVENT_NAME_ROW_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SKSTableViewCell";
    
    SKSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[SKSTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    CEEvent* event =[self.apiResponse.events objectAtIndex:indexPath.row];
    cell.textLabel.text = event.name;
    cell.textLabel.numberOfLines = 1;
    //[cell setBackgroundColor:[UIColor lightGrayColor]];
    [cell setBackgroundColor:[UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0]];
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:19.0f];
    cell.layer.borderColor = [UIColor whiteColor].CGColor;
    cell.layer.borderWidth=3.0;
    return cell;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForSubRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"UITableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
//    }
    double height = [self getHeightForEventAtIndexPath:indexPath];
    height+=EXPANDED_VIEW_BUFFER;//table needs extra space to avoid bottom cut-off
    
    CEEvent* event =[self.apiResponse.events objectAtIndex:indexPath.row];
    CECodeDetailsExapndedView *view = [[CECodeDetailsExapndedView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, height)];
    view.event =event;
    [cell addSubview:view];
    return cell;
}

    //get height for all the attributes in the event
-(CGFloat)getHeightForEventAtIndexPath:(NSIndexPath*)indexPath{
    CEEvent* event =[self.apiResponse.events objectAtIndex:indexPath.row];
    double height = 0;
    for(CEEventAttribute* attribute in event.attributes){
        height+= [attribute getHeightWithFont:[UIFont fontWithName:@"Helvetica" size:15.0f] withFrameWidth:self.view.frame.size.width];
    }
    return height;
}

-(NSString*)getEmailSubject{
    NSString* emailSubject = [NSString stringWithFormat:@"I just traced %@ with HarvestMark Code Explorer",self.apiResponse.product.name];
    return emailSubject;
}

-(NSString*)getEmailText{
    NSMutableString* eventDetails = [@"" mutableCopy];
    if(self.apiResponse.events && self.apiResponse.events.count>0){
        NSMutableArray<CEEvent> *eventsList = self.apiResponse.events;
        for(CEEvent* event in eventsList){
            NSString* eventName = event.name;
            NSString* date = [self getFormattedDate:event.date];
            NSMutableArray<CEEventAttribute> *attribArray = event.attributes;
            [eventDetails appendString:@"\n"];
            [eventDetails appendString:@"\n"];
            [eventDetails appendString:eventName];
            [eventDetails appendString:@"\n"];
            [eventDetails appendString:date];
            [eventDetails appendString:@"\n"];
            if(event.attributes.count>0){
                for(CEEventAttribute* eventAttribute in attribArray){
                    NSString* attributeName = eventAttribute.name;
                    NSString* attributeValue = eventAttribute.value[0];
                   [eventDetails appendString:attributeName];
                   [eventDetails appendString:@" : "];
                    [eventDetails appendString:attributeValue];
                    [eventDetails appendString:@"\n"];
                }
            }
            
        }
    }
    NSString* bodyText = [NSString stringWithFormat:@"%@ \n %@ \n\n %@\n\nURL: %@",self.apiResponse.code,self.apiResponse.product.name,eventDetails,self.tracedUrl];
    return bodyText;
}

-(NSString*)getFormattedDate:(NSString*)dateString {
    NSDateFormatter *formatterOriginal = [[NSDateFormatter alloc] init];
    [formatterOriginal setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSDate *originalDate = [formatterOriginal dateFromString: dateString];
    NSDateFormatter *formatterChanged = [[NSDateFormatter alloc] init];
    [formatterChanged setDateFormat:@"MMM d, yyyy"];
    NSString* newDate = [formatterChanged stringFromDate:originalDate];
    if(!newDate)
        newDate = @"";
    return newDate;
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
