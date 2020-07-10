//
//  InspectionDefectTableViewCell.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 5/11/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "InspectionDefectTableViewCell.h"

@implementation InspectionDefectTableViewCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) refreshState {
    for (Severity *severity in self.allSeveritiesList) {
        if ([[severity.name lowercaseString] isEqualToString:@"minor"]) {
            [self.minorPercentageLabel setText:[NSString stringWithFormat:@"%0.2f%%", severity.inputOrCalculatedPercentage]];
        } else if ([[severity.name lowercaseString] isEqualToString:@"medium"]) {
            [self.mediumPercentageLabel setText:[NSString stringWithFormat:@"%.2f%%", severity.inputOrCalculatedPercentage]];
        } else if ([[severity.name lowercaseString] isEqualToString:@"major"]) {
            [self.majorPercentageLabel setText:[NSString stringWithFormat:@"%.2f%%", severity.inputOrCalculatedPercentage]];
        }
    }
}

@end
