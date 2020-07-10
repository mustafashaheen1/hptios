//
//  CellInspectionType.m
//  DC_Insights_iOS
//
//  Created by John Gifford on 11/6/13.
//  Copyright (c) 2013 Yottamark. All rights reserved.
//

#import "InspectionTypeViewCell.h"
//#import "InspectionInfoTableViewController.h"
@implementation InspectionTypeViewCell
@synthesize selectInspectionButton;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)cameraButtonClick:(id)sender {
    //Should open iOS camera to take picture
}
- (IBAction)selectInspectType:(id)sender {
    if (self.tapHandler) {
        self.tapHandler(10);
    }
}

@end
