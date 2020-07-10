//
//  SettingsUserDetailsView.m
//  Insights
//
//  Created by Vineet Pareek on 20/10/2016.
//  Copyright © 2016 Yottamark. All rights reserved.
//

#import "SettingsUserDetailsView.h"

@implementation SettingsUserDetailsView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //UIView* xibView = [[[NSBundle mainBundle] loadNibNamed:@"SettingUserDetailsView" owner:self options:nil] objectAtIndex:0];
        [[NSBundle mainBundle] loadNibNamed:@"SettingUserDetailsView" owner:self options:nil];


        // now add the view to ourselves...
        //[xibView setFrame:[self bounds]];
        //[self addSubview:xibView]; // we automatically retain this with -addSubview:
        self.username.text = @"";
        self.role.text = @"";
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
     //   [self initTableView];
    }
    return self;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
