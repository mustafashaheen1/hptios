//
//  FailedValidationView.h
//  shopwell
//
//  Created by Scott Golubock on 07/09/12.
//  Copyright (c) 2011 ShopWell Solutions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FailedValidationViewProtocol <NSObject>

- (void)failedValidationClosed;

@end

@interface FailedValidationView : UIView 
{
}

@property (nonatomic, weak) id <FailedValidationViewProtocol> delegate;

@property (retain, nonatomic) IBOutlet UIView *mainView;
@property (retain, nonatomic) IBOutlet UIView *contentView;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (retain, nonatomic) IBOutlet UIView *bottomHalfView;
@property (retain, nonatomic) IBOutlet UILabel *bottomLabel;

- (void)openView;

- (IBAction)closeTouched:(id)sender;

@end
