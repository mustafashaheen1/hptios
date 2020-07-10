//
//  ComboBoxOptionView.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/16/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol ComboBoxOptionProtocol <NSObject>

- (void)comboBoxOptionTouched:(NSInteger)optionNumber;

@end


@interface ComboBoxOptionView : UIView
{
}

@property (assign, nonatomic) NSInteger optionNumber;
@property (retain, nonatomic) id <ComboBoxOptionProtocol> delegate;

@property (retain, nonatomic) IBOutlet UIImageView *optionImage;
@property (retain, nonatomic) IBOutlet UILabel *optionLabel;

- (void)configureFonts;

- (IBAction)optionTouched:(id)sender;

@end