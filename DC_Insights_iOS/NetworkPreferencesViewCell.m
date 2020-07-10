//
//  NetworkPreferencesViewCell.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/18/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "NetworkPreferencesViewCell.h"

@implementation NetworkPreferencesViewCell

@synthesize testConnectionButton;

- (id)init
{
	self = [super init];
	if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
	
	return self;
}

- (void) configureFonts {
    self.testConnectionButton.layer.cornerRadius = 5.0;
}

- (void)refreshState {
    [self configureFonts];
}

- (IBAction)testConnectionButtonTouched:(id)sender {
    [[self delegate] testConnectionDelegateTouched];
}


@end
