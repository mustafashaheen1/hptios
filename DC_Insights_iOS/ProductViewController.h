//
//  ProductViewController.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/18/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "ParentNavigationViewController.h"
#import "UIPopoverListView.h"
#import "ContainerAPI.h"
#import "ProductRatingViewController.h"
#import "Product.h"
#import "CurrentAudit.h"
#import "SavedAudit.h"
#import "VerticalGalleryViewController.h"
#import "GalleryViewController.h"
#import "SyncOverlayView.h"
#import "DuplicateOverlayView.h"
#import "OrderData.h"
#import "ProductViewModel.h"

@interface ProductViewController : ParentNavigationViewController <UIPopoverListViewDelegate, UIPopoverListViewDataSource, ProductRatingViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *watchedFlag;
@property (strong, nonatomic) ContainerAPI *container;
@property (strong, nonatomic) ProductRatingViewController *productRatingView;
@property (strong, nonatomic) IBOutlet UIButton *labelHolderButton;
@property (strong, nonatomic) Product *product;
@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *nextProductButton;
@property (weak, nonatomic) IBOutlet UIButton *previousProductButton;
@property (weak, nonatomic) IBOutlet UILabel *numberOfProductsInspected;
@property (weak, nonatomic) IBOutlet UILabel *inspectionLabel;
@property (weak, nonatomic) IBOutlet UILabel *samplesLabel;
@property (strong, nonatomic) NSMutableArray *productRatingsArray;
@property (strong, nonatomic) CurrentAudit *currentAudit;
@property (assign, nonatomic) int inspectionCount;
@property (strong, nonatomic) SavedAudit *savedAudit;
@property (assign, nonatomic) BOOL saved;
@property (assign, nonatomic) BOOL nextPressed;
@property (strong, nonatomic) VerticalGalleryViewController *galleryView;
@property (strong, nonatomic) GalleryViewController *galleryView2;
@property (assign, nonatomic) BOOL duplicateButtonTouchedButton;
@property (strong, nonatomic) NSArray *ratingResponsesGlobal;
@property (strong, nonatomic) SyncOverlayView *syncOverlayView;
@property (strong, nonatomic) DuplicateOverlayView *duplicateOverlayView;
@property (strong, nonatomic) IBOutlet UIView *duplicateCountsView;
@property (weak, nonatomic) IBOutlet UIButton *cancelDuplicateCountsViewButton;
@property (weak, nonatomic) IBOutlet UIButton *okDuplicateCountsViewButton;
@property (weak, nonatomic) IBOutlet UITextField *duplicateTextField;
@property (assign, nonatomic) int countOfCasesEnteredByTheUser;
@property (assign, nonatomic) int inspectionCountOfCasesEnteredByTheUser;
@property (strong, nonatomic) OrderData *orderDataGlobal;
@property (strong, nonatomic) NSString *userEnteredInspectionSamples;
@property (strong, nonatomic) NSString *parentView;
@property (strong, nonatomic) NSString *countOfCasesFromRatingValue;
@property (weak, nonatomic) IBOutlet UIButton *deleteAudit;
@property (strong, nonatomic) NSArray *productsArrayForNavigation;
@property (assign, nonatomic) int indexOfProductsArray;
@property (strong, nonatomic) ProductViewModel  *viewModel;

- (IBAction)containerOptionButtonSelected:(id)sender;
- (IBAction)nextProductButtonTouched:(id)sender;
- (IBAction)previousProductButtonTouched:(id)sender;
- (IBAction)cancelDuplicateCountsViewButtonTouched:(id)sender;
- (IBAction)okDuplicateCountsViewButtonTouched:(id)sender;
- (IBAction)numberOfInspectionSamplesButtonTouched:(id)sender;
- (void)deleteAuditTouched;

- (void) refreshState;

@end
