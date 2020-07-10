//
//  CellSelect.m
//  DC_Insights_iOS
//
//  Created by John Gifford on 11/6/13.
//  Copyright (c) 2013 Yottamark. All rights reserved.
//

#import "SelectViewCell.h"

@implementation SelectViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
