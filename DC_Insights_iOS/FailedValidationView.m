//
//  FailedValidationView.m
//  shopwell
//
//  Created by Scott Golubock on 07/09/12.
//  Copyright (c) 2011 ShopWell Solutions, Inc. All rights reserved.
//

#import "FailedValidationView.h"

#import "UIFont+UIFont_DCInsights.h"
#import "UIColor+UIColor_DCInsights.h"

@implementation FailedValidationView

@synthesize mainView;
@synthesize contentView;
@synthesize titleLabel;
@synthesize subtitleLabel;
@synthesize bottomHalfView;
@synthesize bottomLabel;
@synthesize delegate;

#pragma mark - Initialization


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		[[NSBundle mainBundle] loadNibNamed:@"FailedValidationView" owner:self options:nil];
                
        titleLabel.textColor = [UIColor colorWithHex:0x4b473f];
        titleLabel.font = [UIFont fontWithName:kSWFontNameUnivers59 size:22.0];
        
        subtitleLabel.textColor = [UIColor colorWithHex:0x4b473f];
        subtitleLabel.font = [UIFont fiftyNineAt28];
                
        bottomLabel.textColor = [UIColor colorWithHex:0x5f5b54];
        bottomLabel.font = [UIFont fontWithName:KSWFontNameUnivers47 size:12.0];
        
        bottomHalfView.backgroundColor = [UIColor colorWithHex:0xeae7e4];
        
        // Adjust for 4-inch screens
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        if (screenHeight > 480.0) {
            CGRect originalContentViewFrame = self.contentView.frame;
            self.mainView.frame = CGRectMake(0, 0, 320.0, screenHeight);
            self.contentView.frame = originalContentViewFrame;
        }
    }
    
    return self;
}


#pragma mark - Refresh state Method


/*------------------------------------------------------------------------------
 METHOD: refreshState
 
 PURPOSE:
 Configure the UX elements of the cell
 -----------------------------------------------------------------------------*/
- (void)refreshState
{
    titleLabel.text = @"OOPS!";
    
    subtitleLabel.text = @"YOU HAVEN'T FINISHED THE QUESTIONS";
    
    bottomLabel.text = @"You must complete all the required fields in order to advance to the next step.";
}


#pragma mark - Memory Management


- (void)dealloc
{
    self.delegate = nil;
}


#pragma mark - Public Methods


- (void)openView
{
    UIWindow *win = [[UIApplication sharedApplication] keyWindow];
    self.mainView.center = win.center;
    [win addSubview:self.mainView];
    [self zoomViewOpen:YES];
}


#pragma mark - UX Actions


- (IBAction)closeTouched:(id)sender
{
    [self zoomViewOpen:NO];
    
    if (delegate) {
        [delegate failedValidationClosed];
    }
}


-(void)zoomViewOpen:(BOOL)toOpen
{
	CGAffineTransform from = CGAffineTransformMakeScale(0.1, 0.1);
	CGAffineTransform to = CGAffineTransformIdentity;
	
	if (!toOpen) {
		from = CGAffineTransformIdentity;
		to = CGAffineTransformMakeScale(0.1, 0.1);
	}
	
	self.mainView.transform = from;
    
	// run the animation
	[UIView animateWithDuration:0.2
             animations:^{
                 self.mainView.transform = to;
             }
             completion:^(BOOL finished) {
                 if (!toOpen) {
                     [self.mainView removeFromSuperview];
                 }
             }
	 ];
}



@end
