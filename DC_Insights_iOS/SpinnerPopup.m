//
//  SpinnerPopup.m
//  Insights
//
//  Created by Vineet on 10/1/18.
//  Copyright © 2018 Yottamark. All rights reserved.
//

#import "SpinnerPopup.h"
#import "Constants.h"

@implementation SpinnerPopup

- (id)initWithFrame:(CGRect)frame withItems:(NSArray*)items withTitle:(NSString*)title withRatingId:(int)ratingId
{
    self = [super initWithFrame:frame];
    if (self) {
        self.items = items;
        self.delegate = self;
        self.datasource = self;
        self.listView.scrollEnabled = TRUE;
        self.textFieldNeeded = NO;
        self.ratingId = ratingId;
        [self setTitle:title];
        [self show];
    }
    return self;
}

#pragma mark - UIPopoverListViewDataSource

//
//- (UITableViewCell *)popoverListView:(UIPopoverListView *)popoverListView cellForIndexPath:(NSIndexPath *)indexPath {
//    static NSString *identifier = @"PopUpCell";
//    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
//    NSString *item =[self.items objectAtIndex:indexPath.row];
//    cell.textLabel.text = item;
//    return cell;
//}


- (NSInteger)popoverListView:(UIPopoverListView *)popoverListView numberOfRowsInSection:(NSInteger)section {
    return [self.items count];
}

- (CGFloat)popoverListView:(UIPopoverListView *)popoverListView
   heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}


- (void)popoverListView:(nonnull UITableView *)popoverListView
     didSelectIndexPath:(NSIndexPath *)indexPath
{
    NSString* item = [self.items objectAtIndex:indexPath.row];
    [self.spinnerDelegate selectedValue:item forRatingId:self.ratingId];
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString *identifier = @"PopUpCell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    NSString *item =[self.items objectAtIndex:indexPath.row];
    cell.textLabel.text = item;
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.items count];
}

@end
