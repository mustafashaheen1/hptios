//
//  ApplyToAllViewController.h
//  Insights-Trimble-Enterprise
//
//  Created by Mustafa Shaheen on 1/27/20.
//  Copyright © 2020 Yottamark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ApplyToAllViewModel.h"
#import "ProductRatingViewController.h"

@interface ApplyToAllViewController : ParentNavigationViewController <UIPopoverListViewDelegate, UIPopoverListViewDataSource, ProductRatingViewControllerDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) ApplyToAllViewModel *viewModel;
@property (strong, nonatomic) ProductRatingViewController *productRatingView;
@property (strong, nonatomic) NSString *parentView;
@property (strong, nonatomic) SyncOverlayView *syncOverlayView;
@end


