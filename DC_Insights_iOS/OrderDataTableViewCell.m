//
//  OrderDataTableViewCell.m
//  DC Insights
//
//  Created by Shyam Ashok on 8/4/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "OrderDataTableViewCell.h"
#import "Constants.h"
#import "NSUserDefaultsManager.h"

@implementation OrderDataTableViewCell

- (id)init
{
	self = [super init];
	if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
	
	return self;
}

- (void) configureFonts {
    self.daysAfterButton.layer.borderWidth = 1.0;
    self.daysAfterButton.layer.borderColor = [[UIColor blackColor] CGColor];
    self.daysAfterButton.layer.cornerRadius = 1.0;
    self.daysAfterButton.titleLabel.textColor = [UIColor whiteColor];
    self.daysBeforeButton.layer.cornerRadius = 1.0;
    self.daysBeforeButton.layer.borderWidth = 1.0;
    self.daysBeforeButton.layer.borderColor = [[UIColor blackColor] CGColor];
    self.daysBeforeButton.titleLabel.textColor = [UIColor whiteColor];
    self.downloadButton.layer.cornerRadius = 1.0;
    self.downloadButton.layer.borderWidth = 1.0;
    self.downloadButton.layer.borderColor = [[UIColor blackColor] CGColor];
    self.downloadButton.titleLabel.textColor = [UIColor whiteColor];

}

- (void)refreshState {
    self.daysBefore = NO;
    self.days = @[@"0", @"1", @"2", @"3"];
    [self configureFonts];
    if ([NSUserDefaultsManager getObjectFromUserDeafults:DAYSBEFORENUMBER]) {
        [self.daysBeforeButton setTitle:[NSUserDefaultsManager getObjectFromUserDeafults:DAYSBEFORENUMBER] forState:UIControlStateNormal];
    } else {
        [self.daysBeforeButton setTitle:OrderDataDefaultNumberOfDays forState:UIControlStateNormal];
    }
    if ([NSUserDefaultsManager getObjectFromUserDeafults:DAYSAFTERNUMBER]) {
        [self.daysAfterButton setTitle:[NSUserDefaultsManager getObjectFromUserDeafults:DAYSAFTERNUMBER] forState:UIControlStateNormal];
    } else {
        [self.daysAfterButton setTitle:OrderDataDefaultNumberOfDays forState:UIControlStateNormal];
    }
}

- (void) popOverSetup {
    CGFloat xWidth = self.frame.size.width - 20.0f;
    CGFloat yHeight = 280;
    CGFloat yOffset = (self.frame.size.height - yHeight)/2.0f;
    UIPopoverListView *poplistview = [[UIPopoverListView alloc] initWithFrame:CGRectMake(10, yOffset, xWidth, yHeight)];
    poplistview.delegate = self;
    poplistview.datasource = self;
    poplistview.listView.scrollEnabled = TRUE;
    [poplistview setTitle:@"  Select Number Of Days"];
    [poplistview show];
}

#pragma mark - UIPopoverListViewDataSource

- (UITableViewCell *)popoverListView:(UIPopoverListView *)popoverListView
                    cellForIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    if ([self.days count] >0) {
        cell.textLabel.text = [self.days objectAtIndex:indexPath.row];
    }
    return cell;
}

- (NSInteger)popoverListView:(UIPopoverListView *)popoverListView
       numberOfRowsInSection:(NSInteger)section
{
    return [self.days count];
}

#pragma mark - UIPopoverListViewDelegate
- (void)popoverListView:(UIPopoverListView *)popoverListView
     didSelectIndexPath:(NSIndexPath *)indexPath
{
    if ([self.days count] > 0) {
        if (self.daysBefore) {
            [NSUserDefaultsManager saveObjectToUserDefaults:[self.days objectAtIndex:indexPath.row] withKey:DAYSBEFORENUMBER];
            [self.daysBeforeButton setTitle:[self.days objectAtIndex:indexPath.row] forState:UIControlStateNormal];
        } else {
            [NSUserDefaultsManager saveObjectToUserDefaults:[self.days objectAtIndex:indexPath.row] withKey:DAYSAFTERNUMBER];
            [self.daysAfterButton setTitle:[self.days objectAtIndex:indexPath.row] forState:UIControlStateNormal];
        }
    }
}

- (CGFloat)popoverListView:(UIPopoverListView *)popoverListView
   heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (IBAction)daysBeforeButtonTouched:(id)sender {
    self.daysBefore = YES;
    [self popOverSetup];
}

- (IBAction)daysAfterButtonTouched:(id)sender {
    self.daysBefore = NO;
    [self popOverSetup];
}

- (void) textFieldText: (NSString *) text withTableView:(UITableView *) tableView {

}

@end
