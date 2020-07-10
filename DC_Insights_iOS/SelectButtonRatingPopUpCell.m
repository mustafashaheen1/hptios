//
//  SelectButtonRatingPopUpCell.m
//  Insights
//
//  Created by Vineet Pareek on 22/10/2015.
//  Copyright © 2015 Yottamark. All rights reserved.
//

#import "SelectButtonRatingPopUpCell.h"

@implementation SelectButtonRatingPopUpCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)flagTouched:(id)sender {
    
    UIAlertView* dialog = [[UIAlertView alloc] initWithTitle:self.messageTitle message:self.message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [dialog setAlertViewStyle:UIAlertViewStyleDefault];
    [dialog show];
}

@end
