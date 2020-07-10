//
//  SyncOverlayView.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/30/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "SyncOverlayView.h"

#define DEFAULT_BLUE [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]

static const CGSize progressViewSize = { 200.0f, 30.0f };

@interface SyncOverlayView ()
@property (nonatomic) CGFloat progress;
@end

@implementation SyncOverlayView

@synthesize hideButton;
@synthesize headingTitleLabel;
@synthesize progressView;
@synthesize headingString;
@synthesize percentageLabel;
@synthesize apiDownloadedLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.6];
        [self viewSetup];
        [self progressViewSetup];
        [self activityIndicatorSetup];
        self.activityIndicatorView.hidden = YES;
        self.cancelPressed = NO;
        // Initialization code
    }
    return self;
}

- (void) viewSetup {
    
    UIFont * customFont = [UIFont fontWithName:@"Helvetica" size:20]; //custom font
    
    headingTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(11, 140, 300, 30)];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.headingTitleLabel.frame = CGRectMake(245, 325, 300, 30);
    }
    if(IS_IPHONE6 || IS_IPHONE6S){
        self.headingTitleLabel.frame = CGRectMake(31, 140, 300, 30);
    }
    headingTitleLabel.font = customFont;
    headingTitleLabel.numberOfLines = 1;
    headingTitleLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines; // or UIBaselineAdjustmentAlignCenters, or UIBaselineAdjustmentNone
    headingTitleLabel.adjustsFontSizeToFitWidth = YES;
    headingTitleLabel.adjustsLetterSpacingToFitWidth = YES;
    headingTitleLabel.minimumScaleFactor = 10.0f/12.0f;
    headingTitleLabel.clipsToBounds = YES;
    headingTitleLabel.backgroundColor = [UIColor clearColor];
    headingTitleLabel.textColor = [UIColor whiteColor];
    headingTitleLabel.textAlignment = NSTextAlignmentCenter;
    headingTitleLabel.center = CGPointMake(self.bounds.size.width/2, 155);
    [self addSubview:headingTitleLabel];
    
    UIFont * customFont2 = [UIFont fontWithName:@"Helvetica" size:16]; //custom font
    percentageLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 160, 320, 50)];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.percentageLabel.frame = CGRectMake(240, 350, 320, 50);
    }
    if(IS_IPHONE6|| IS_IPHONE6S){
        self.percentageLabel.frame = CGRectMake(20, 160, 320, 50);
    }
    percentageLabel.font = customFont2;
    percentageLabel.numberOfLines = 1;
    percentageLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines; // or UIBaselineAdjustmentAlignCenters, or UIBaselineAdjustmentNone
    percentageLabel.adjustsFontSizeToFitWidth = YES;
    percentageLabel.adjustsLetterSpacingToFitWidth = YES;
    percentageLabel.minimumScaleFactor = 10.0f/12.0f;
    percentageLabel.clipsToBounds = YES;
    percentageLabel.backgroundColor = [UIColor clearColor];
    percentageLabel.textColor = [UIColor whiteColor];
    percentageLabel.textAlignment = NSTextAlignmentCenter;
    percentageLabel.center = CGPointMake(self.bounds.size.width/2, 185);
    [self addSubview:percentageLabel];
    
    UIFont * customFont3 = [UIFont fontWithName:@"Helvetica" size:16]; //custom font
    apiDownloadedLabel = [[UILabel alloc]initWithFrame:CGRectMake(11, 200, 300, 30)];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.apiDownloadedLabel.frame = CGRectMake(245, 420, 300, 30);
    }
    if(IS_IPHONE6|| IS_IPHONE6S){
        self.apiDownloadedLabel.frame = CGRectMake(31, 200, 300, 30);
    }
    
    apiDownloadedLabel.font = customFont3;
    apiDownloadedLabel.numberOfLines = 1;
    apiDownloadedLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines; // or UIBaselineAdjustmentAlignCenters, or UIBaselineAdjustmentNone
    apiDownloadedLabel.adjustsFontSizeToFitWidth = YES;
    apiDownloadedLabel.adjustsLetterSpacingToFitWidth = YES;
    apiDownloadedLabel.minimumScaleFactor = 10.0f/12.0f;
    apiDownloadedLabel.clipsToBounds = YES;
    apiDownloadedLabel.backgroundColor = [UIColor clearColor];
    apiDownloadedLabel.textColor = [UIColor whiteColor];
    apiDownloadedLabel.textAlignment = NSTextAlignmentCenter;
    apiDownloadedLabel.text = @"";
    apiDownloadedLabel.center = CGPointMake(self.bounds.size.width/2, 215);
    [self addSubview:apiDownloadedLabel];
    /*
     self.hideButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
     [self.hideButton addTarget:self action:@selector(hideButtonTouched) forControlEvents:UIControlEventTouchUpInside];
     [self.hideButton setTitle:@"Hide" forState:UIControlStateNormal];
     [self.hideButton setTitleColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0] forState:UIControlStateNormal];
     self.hideButton.frame = CGRectMake(self.bounds.size.width/2-80.0, 400.0, 160.0, 40.0);
     self.hideButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [self addSubview:self.hideButton];*/
}

- (void) progressViewSetup {
    
    self.progressView = [[THProgressView alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.frame) - progressViewSize.width / 2.0f,
                                                                         CGRectGetMidY(self.frame) - (progressViewSize.height/*+(self.bounds.size.height/5)*/) / 2.0f - 20,
                                                                         progressViewSize.width,
                                                                         progressViewSize.height)];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.progressView.frame = CGRectMake(290, 400, progressViewSize.width, progressViewSize.height);
    }
    progressView.borderTintColor = [UIColor whiteColor];
    progressView.progressTintColor = [UIColor whiteColor];
    [self addSubview:progressView];
}

- (void) hideButtonTouched {
    self.cancelPressed = YES;
    [self removeFromSuperview];
}

- (void)updateProgress
{
    
    self.progress += 0.10f;
    [self progressAdd];
}

- (void) updateProgressWithPageNo {
    //NSLog(@"SyncOverlayView.m - self.progress before %f for pageNo %f",self.progress,self.pageNo);
    self.progress += self.pageNo;
    [self progressAdd];
}

- (void) progressAdd {
    if (self.progress > 1.0f) {
        self.progress = 1.0;
    }
    float percentage = self.progress * 100;
    self.percentageLabel.text = [NSString stringWithFormat:@"%.0f%%", percentage];
    //NSLog(@"SyncOverlayView.m - self.progress after %f, percentage: %@",self.progress,[NSString stringWithFormat:@"%.0f%%", percentage]);
    [progressView setProgress:self.progress animated:YES];
}

-(void)updateHeadingText:(NSString*)message{
     self.headingTitleLabel.text = message;
     [progressView setProgress:self.progress animated:YES];
    [self setNeedsDisplay];
}

-(void)showOnlyHeaderMessage:(NSString*)message{
    self.headingTitleLabel.text = message;
    self.apiDownloadedLabel.text=@"";
    self.percentageLabel.text = @"";
    [self setNeedsDisplay];
    //[progressView setProgress:self.progress animated:YES];
}


- (void) removeProgressView {
    self.progress = 0;
}

- (void) activityIndicatorSetup {
    //UIWindow *win = [[UIApplication sharedApplication] keyWindow];
    //CGRect newFrame = CGRectMake(0, 0, win.frame.size.width, win.frame.size.height); //backgroundView.frame;
    
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(150, 200, 30, 30)];
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        self.activityIndicatorView.frame = CGRectMake(380, 400, 30, 30);
    }
    if(IS_IPHONE6|| IS_IPHONE6S){
        self.activityIndicatorView.frame = CGRectMake(180, 200, 30, 30);
    }
    [self.activityIndicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.activityIndicatorView setColor:[UIColor whiteColor]];
    [self addSubview:self.activityIndicatorView];
}

- (void) showOnlyTheView {
    [self.progressView removeFromSuperview];
    self.hideButton.hidden = YES;
    self.activityIndicatorView.hidden = YES;
}

- (void) showActivityView {
    [self.progressView removeFromSuperview];
    self.hideButton.hidden = YES;
    self.activityIndicatorView.hidden = NO;
    [self.activityIndicatorView startAnimating];
}

- (void) dismissActivityView {
    self.hideButton.hidden = NO;
    self.activityIndicatorView.hidden = YES;
    [self.activityIndicatorView stopAnimating];
}
//for CodeExplorer - the animation replaces the existing indicator view
-(void)showTractorLoadingAnimation{
    self.backgroundColor = [UIColor whiteColor];
    self.headingTitleLabel.textColor = [UIColor blackColor];
    self.apiDownloadedLabel.textColor = [UIColor blackColor];
    self.activityIndicatorView.hidden = YES;
    [self.activityIndicatorView stopAnimating];
    NSArray *animationArray = [NSArray arrayWithObjects:
                               [UIImage imageNamed:@"1.png"],
                               [UIImage imageNamed:@"2.png"],
                               [UIImage imageNamed:@"3.png"],
                               [UIImage imageNamed:@"4.png"],
                               [UIImage imageNamed:@"5.png"],
                               [UIImage imageNamed:@"6.png"],
                               [UIImage imageNamed:@"7.png"],
                               [UIImage imageNamed:@"8.png"],
                               [UIImage imageNamed:@"9.png"],
                               [UIImage imageNamed:@"10.png"],
                               [UIImage imageNamed:@"11.png"],
                               [UIImage imageNamed:@"12.png"],
                               [UIImage imageNamed:@"13.png"],
                               [UIImage imageNamed:@"14.png"],
                               [UIImage imageNamed:@"15.png"],
                               nil];
    UIImageView *animationView = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMidX(self.frame)-(179/2), CGRectGetMidY(self.frame)-(121/2),179, 121)];
    animationView.backgroundColor      = [UIColor whiteColor];
    animationView.animationImages      = animationArray;
    animationView.animationDuration    = 2.5;
    animationView.animationRepeatCount = 0;
    [animationView startAnimating];
    [self addSubview:animationView];
}

-(void) showHideButton {
    self.hideButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.hideButton addTarget:self action:@selector(hideButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    [self.hideButton setBackgroundColor:[UIColor colorWithRed:76.0/255.0 green:76.0/255.0 blue:76.0/255.0 alpha:1.0]];
    [self.hideButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.hideButton setTitleColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    self.hideButton.frame = CGRectMake(self.bounds.size.width/2-80.0, self.bounds.size.height - self.bounds.size.height/3, 160.0, 40.0);
    self.hideButton.titleLabel.font = [UIFont systemFontOfSize:18.0];
    self.hideButton.hidden = NO;
    [self addSubview:self.hideButton];
}

@end
