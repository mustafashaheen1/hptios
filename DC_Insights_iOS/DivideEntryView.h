//
//  DivideEntryView.h
//  Insights-Trimble-Enterprise
//
//  Created by Mustafa Shaheen on 11/7/19.
//  Copyright © 2019 Yottamark. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DivideEntryView : UIView <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *clearButton;
@property (weak, nonatomic) IBOutlet UILabel *severityNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *leftDivideTextField;
@property (weak, nonatomic) IBOutlet UITextField *rightDivideTextField;
@property (weak, nonatomic) IBOutlet UILabel *percentageLabel;
- (float) calculatePercentage;
- (void) loadView;
@end

NS_ASSUME_NONNULL_END
