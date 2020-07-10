//
//  BooleanRatingViewCell.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/15/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewCell.h"
#import "BooleanRatingOptionView.h"

#define kBooleanRatingViewCellReuseID @"BooleanRatingViewCell"
#define kBooleanRatingViewCellNIBFile @"BooleanRatingViewCell"

@interface BooleanRatingViewCell : BaseTableViewCell <BooleanRatingOptionProtocol> {
    BOOL optionsViewInitialized;
}

@property (strong, nonatomic) NSMutableArray *optionSelectedState;
@property (strong, nonatomic) IBOutlet UIView *optionsView;
@property (strong, nonatomic) IBOutlet UISwitch *switchONOrOff;
@property (strong, nonatomic) IBOutlet BooleanRatingOptionView *anOptionView;

@end
