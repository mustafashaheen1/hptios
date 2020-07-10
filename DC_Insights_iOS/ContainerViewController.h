//
//  ContainerViewController.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/18/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "ParentNavigationViewController.h"
#import "UIPopoverListView.h"
#import "ProductRatingViewController.h"
#import "Container.h"
#import "VerticalGalleryViewController.h"
#import "SyncOverlayView.h"
#import "SavedInspection.h"

#define kContainerViewNIBName @"ContainerViewController"

@interface ContainerViewController : ParentNavigationViewController <UIPopoverListViewDelegate, UIPopoverListViewDataSource, ProductRatingViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIButton *containerOptionButton;
@property (strong, nonatomic) NSArray *containers;
@property (strong, nonatomic) NSArray *containerRatings;
@property (strong, nonatomic) NSArray *orderDataArray;
@property (strong, nonatomic) Container *container;
@property (strong, nonatomic) NSString *masterID;
@property (strong, nonatomic) ProductRatingViewController *productRatingView;
@property (strong, nonatomic) VerticalGalleryViewController *galleryView;
@property (strong, nonatomic) SyncOverlayView *syncOverlayView;

- (IBAction)containerOptionButtonSelected:(id)sender;
- (void) containerOptionSelectedToProceed: (Container *) container;

@end
