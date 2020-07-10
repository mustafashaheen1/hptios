//
//  UserPreferencesViewCell.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/20/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "UserPreferencesViewCell.h"

@implementation UserPreferencesViewCell

@synthesize clearLoginInfoButton;

- (id)init
{
	self = [super init];
	if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
	
	return self;
}

- (void) configureFonts {
    self.clearLoginInfoButton.layer.cornerRadius = 5.0;
}

- (void)refreshState {
    [self configureFonts];
}


@end
