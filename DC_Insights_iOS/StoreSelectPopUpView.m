//
//  StoreSelectPopUp.m
//  DC Insights
//
//  Created by Shyam Ashok on 8/27/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "StoreSelectPopUpView.h"
#import "StoreAPI.h"
#import "Store.h"

@implementation StoreSelectPopUpView

@synthesize table;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

// TableView methods.

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;    //count of section
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.stores count];    //count number of row from counting array hear cataGorry is An Array
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:MyIdentifier];
    }
    Store *store = [self.stores objectAtIndex:indexPath.row];
    cell.textLabel.text = store.name;
    if (store.address) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %0.2f miles", store.address, store.distanceFromUserLocation];
    } else {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%0.2f miles", store.distanceFromUserLocation];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Store *store = [self.stores objectAtIndex:indexPath.row];
    [[self delegate] submitInformationStoreSelect:store];
}

- (void) hideTableViewAndShowAlert {
    self.table.hidden = YES;
    self.selectYourStoreLabel.hidden = YES;
    self.alertMessage.hidden = NO;
}

- (void) retrieveStores {
    self.syncOverlayView = [[SyncOverlayView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    self.syncOverlayView.activityIndicatorView.frame = CGRectMake(130, 180, 30, 30);
    self.syncOverlayView.headingTitleLabel.text = @"";
    [self.syncOverlayView showActivityView];
    [self addSubview:self.syncOverlayView];
    StoreAPI *storeApi = [[StoreAPI alloc] init];
    [storeApi storeLocationCallWithBlock:^(BOOL isSuccess, NSArray *array, NSError *error){
        if (error) {
            DebugLog(@"\n Error: %@  \n", [error localizedDescription]);
            [self.syncOverlayView dismissActivityView];
            [self.syncOverlayView removeFromSuperview];
        } else {
            NSLog(@"posts %@", array);
            if (isSuccess) {
                self.stores = array;
                [self.table reloadData];
            } else {
            }
            [self.syncOverlayView dismissActivityView];
            [self.syncOverlayView removeFromSuperview];
        }
    }];
}

@end
