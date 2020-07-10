//
//  BooleanRatingOptionView.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/17/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BooleanRatingOptionProtocol <NSObject>

- (void)booleanRatingOptionTouched:(NSInteger)optionNumber;

@end


@interface BooleanRatingOptionView : UIView

@property (assign, nonatomic) NSInteger optionNumber;
@property (retain, nonatomic) id <BooleanRatingOptionProtocol> delegate;

@property (retain, nonatomic) IBOutlet UIImageView *optionImage;
@property (retain, nonatomic) IBOutlet UILabel *optionLabel;

- (void)configureFonts;

- (IBAction)optionTouched:(id)sender;


@end
