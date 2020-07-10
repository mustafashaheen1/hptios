//
//  DivideEntryView.m
//  Insights-Trimble-Enterprise
//
//  Created by Mustafa Shaheen on 11/7/19.
//  Copyright © 2019 Yottamark. All rights reserved.
//

#import "DivideEntryView.h"

@implementation DivideEntryView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.percentageLabel.text=@"";
        [self.leftDivideTextField addTarget:self
                      action:@selector(calculatePercentage)
            forControlEvents:UIControlEventEditingChanged];
        [self.rightDivideTextField addTarget:self
                                     action:@selector(calculatePercentage)
                           forControlEvents:UIControlEventEditingChanged];
    }
    return self;
}
 - (void)loadView {
     self.percentageLabel.text=@"";
     [self.leftDivideTextField addTarget:self
                   action:@selector(calculatePercentage)
         forControlEvents:UIControlEventEditingChanged];
     [self.rightDivideTextField addTarget:self
                                  action:@selector(calculatePercentage)
                        forControlEvents:UIControlEventEditingChanged];
 }
- (float) calculatePercentage {
    self.percentageLabel.text = @"";
    float small = [self.leftDivideTextField.text floatValue];
    float large = [self.rightDivideTextField.text floatValue];
    float percentage = small/large;
    percentage = (100*percentage)/100;
    float percentageInteger = percentage * 100;
    NSString *percent = @"";
    if(!isinf(percentageInteger) && percentageInteger!=NAN && percentageInteger>=0)
        percent =[NSString stringWithFormat:@"Around %.2f %% of sample",percentageInteger];
    else if(percentageInteger>100)
        percent = @"Exceeds 100%";
    self.percentageLabel.text = percent;
    if (percentageInteger > 0) {
        return percentageInteger;
    } else {
        return 0;
    }
  
}
- (IBAction)clearPressed:(UIButton *)sender {
    self.leftDivideTextField.text = @"";
    self.rightDivideTextField.text = @"";
    self.percentageLabel.text = @"";
}


@end
