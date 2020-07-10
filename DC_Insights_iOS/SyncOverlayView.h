//
//  SyncOverlayView.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/30/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THProgressView.h"
#import "Constants.h"

@interface SyncOverlayView : UIView

@property (strong, nonatomic) IBOutlet UIButton *hideButton;
@property (strong, nonatomic) UILabel *headingTitleLabel;
@property (strong, nonatomic) UILabel *percentageLabel;
@property (strong, nonatomic) UILabel *apiDownloadedLabel;
@property (strong, nonatomic) THProgressView *progressView;
@property (strong, nonatomic) NSString *headingString;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;
@property (assign, nonatomic) float pageNo;
@property BOOL cancelPressed;

- (void) updateProgress;
- (void) removeProgressView;
- (void) showActivityView;
- (void) dismissActivityView;
- (void) showOnlyTheView;
- (void) updateProgressWithPageNo;
- (void) showHideButton;
-(void)updateHeadingText:(NSString*)message;
-(void)showOnlyHeaderMessage:(NSString*)message;
- (void) showTractorLoadingAnimation;

@end
