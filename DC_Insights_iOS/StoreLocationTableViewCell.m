//
//  StoreLocationTableViewCell.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/7/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "StoreLocationTableViewCell.h"

@implementation StoreLocationTableViewCell

@synthesize storeName;
@synthesize storeAddress;
@synthesize roundedCornersView;

#pragma mark - Initialization

- (id)init
{
	self = [super init];
	if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
	
	return self;
}

- (void) configureFontsAndColors {
    self.storeName.font = [UIFont fontWithName:@"Helvetica-Bold" size:18.0];
    self.storeAddress.font = [UIFont fontWithName:@"Helvetica" size:12.0];
    self.distance.font = [UIFont fontWithName:@"Helvetica" size:12.0];
}

- (void) cellSetup {
    self.backgroundColor = [UIColor grayColor];
}

+ (CGFloat) myCellHeight {
    return 75;
}

#pragma mark - Configuration


- (void) setStoreName:(UILabel *)newStoreName
{
	if (newStoreName != storeName) {
		if (newStoreName != nil) {
			storeName = newStoreName;
			[self refreshState];
		} else {
			storeName = nil;
		}
	}
}

- (void) setupRoundedCornersView {
    self.roundedCornersView.layer.cornerRadius = 10.0;
    self.roundedCornersView.layer.borderWidth = 2;
    self.roundedCornersView.layer.borderColor = [[UIColor blackColor] CGColor];

}

- (void) refreshState {
    [self setupRoundedCornersView];
    self.backgroundColor = [UIColor clearColor];
    [self configureFontsAndColors];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.layer.cornerRadius = 10.0;
}

@end
