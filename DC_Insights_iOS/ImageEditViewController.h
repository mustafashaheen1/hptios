//
//  ImageEditViewController.h
//  Insights
//
//  Created by Shyam Ashok on 10/21/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParentNavigationViewController.h"
#import "Image.h"

typedef void (^SDSenderBlock)(id sender);

@class ImageEditViewController;

@protocol SDDrawingViewControllerDelegate <NSObject>

- (void)viewControllerDidSaveDrawing:(ImageEditViewController*)viewController;
- (void)viewControllerDidCancelDrawing:(ImageEditViewController*)viewController;
- (void)viewControllerDidDeleteDrawing:(ImageEditViewController*)viewController;

@end

@interface ImageEditViewController : ParentNavigationViewController

@property (weak, nonatomic) IBOutlet UIButton *titleButton;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UIToolbar *topToolbar;
@property (weak, nonatomic) IBOutlet UIToolbar *bottomToolbar;

@property (nonatomic, strong) IBOutlet UIImageView *imageViewEdit;
@property (nonatomic, strong) UIImage *imageForEdit;
@property (nonatomic, strong) NSString *parentView;
@property (nonatomic, strong) Image *imageObjectForEdit;
@property (copy) NSString *drawingID;

@property (weak) id<SDDrawingViewControllerDelegate> delegate;

@property (copy) SDSenderBlock customization;

@property (copy) SDSenderBlock toolListCustomization;

@end
