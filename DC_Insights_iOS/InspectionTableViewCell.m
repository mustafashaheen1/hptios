//
//  InspectionTableViewCell.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/13/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "InspectionTableViewCell.h"

@implementation InspectionTableViewCell

@synthesize numberOfInspectionsLabel;
@synthesize modifiedLabel;
@synthesize inspectionNumberLabel;
@synthesize roundedCornersView;

- (id)init
{
	self = [super init];
	if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
	
	return self;
}

- (void) configureFontsAndColors {
    self.inspectionNumberLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0];
    self.numberOfInspectionsLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0];
    self.modifiedLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0];
}

+ (CGFloat) myCellHeight {
    return 59;
}

#pragma mark - Configuration


- (void) setInspectionNumberLabel:(UILabel *)newInspectionNumberLabel
{
	if (newInspectionNumberLabel != inspectionNumberLabel) {
		if (newInspectionNumberLabel != nil) {
			inspectionNumberLabel = newInspectionNumberLabel;
			[self refreshState];
		} else {
			inspectionNumberLabel = nil;
		}
	}
}

- (void) setupRoundedCornersView {
   // self.roundedCornersView.layer.cornerRadius = 10.0;
   // self.roundedCornersView.layer.borderWidth = 0;
   // self.roundedCornersView.layer.borderColor = [[UIColor blackColor] CGColor];
}

- (void) refreshState {
    [self setupRoundedCornersView];
    self.backgroundColor = [UIColor clearColor];
    [self configureFontsAndColors];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.layer.cornerRadius = 10.0;
}

@end
