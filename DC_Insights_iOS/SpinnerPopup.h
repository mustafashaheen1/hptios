//
//  SpinnerPopup.h
//  Insights
//
//  Created by Vineet on 10/1/18.
//  Copyright © 2018 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIPopoverListView.h"

@protocol SpinnerPopupDelegate <NSObject>
-(void)selectedValue:(NSString*)value forRatingId:(int)ratingId;
@end

@interface SpinnerPopup : UIPopoverListView<UIPopoverListViewDelegate, UIPopoverListViewDataSource>

@property(nonatomic,strong) NSString* title;
@property(nonatomic,strong) NSArray* items;
@property (nonatomic, weak) id <SpinnerPopupDelegate> spinnerDelegate;
@property (nonatomic, assign) int ratingId;

- (id)initWithFrame:(CGRect)frame withItems:(NSArray*)items withTitle:(NSString*)title withRatingId:(int)ratingId;

@end

