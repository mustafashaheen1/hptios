//
//  ComboBoxRatingViewCell.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/15/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewCell.h"
#import "ComboBoxOptionView.h"

#define kComboBoxRatingViewCellReuseID @"ComboBoxRatingViewCell"
#define kComboBoxRatingViewCellNIBFile @"ComboBoxRatingViewCell"

@interface ComboBoxRatingViewCell : BaseTableViewCell <ComboBoxOptionProtocol> {
    BOOL optionsViewInitialized;
}

@property (strong, nonatomic) NSMutableArray *optionSelectedState;
@property (strong, nonatomic) IBOutlet UIView *optionsView;
@property (strong, nonatomic) IBOutlet ComboBoxOptionView *anOptionView;

@end
