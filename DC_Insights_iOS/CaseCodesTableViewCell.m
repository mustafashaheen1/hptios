//
//  CaseCodesTableViewCell.m
//  Insights
//
//  Created by Mustafa Shaheen on 6/30/20.
//  Copyright © 2020 Yottamark. All rights reserved.
//

#import "CaseCodesTableViewCell.h"

@implementation CaseCodesTableViewCell
@synthesize code;
@synthesize quantity;
@synthesize remove;
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
