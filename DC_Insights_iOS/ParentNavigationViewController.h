//
//  ParentNavigationViewController.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/13/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "SyncManager.h"
#import "UserNetworkActivityView.h"
#import "UserNetworkActivityViewProtocol.h"
#import "SCLAlertView.h"
#import "ImageGalleryPicker.h"

@interface ParentNavigationViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, SyncManagerDelegate, UserNetworkActivityViewProtocol>

@property (strong, nonatomic) UIImageView *arrowBackIcon;
@property (strong, nonatomic) UIImageView *launcherIcon;
@property (strong, nonatomic) UILabel *insightsLabel;
@property (strong, nonatomic) UIButton *backButton;
@property (strong, nonatomic) UIButton *refreshButton;
@property (strong, nonatomic) UIButton *uploadButton;
@property (strong, nonatomic) UIButton *addButton;
@property (nonatomic, strong) UIButton *forwardButton;
@property (nonatomic, strong) UIButton *cameraButton;
@property (nonatomic, strong) UIButton *scanButton;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UIButton *printButton;
@property (nonatomic, strong) UIButton *saveForwardButton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *finishButton;
@property (nonatomic, strong) UIButton *markButton;
@property (nonatomic, strong) UIButton *settingsButton;
@property (nonatomic, strong) UIButton *productInfoButton;
@property (nonatomic, strong) UIButton *orderDataSyncButton;
@property (nonatomic, strong) UIButton *undoImageEditButton;
@property (nonatomic, strong) UIButton *redoImageEditButton;
@property (nonatomic, strong) UIBarButtonItem *saveForInspectionStatus;
@property (nonatomic, strong) UIBarButtonItem *cancelInspectionStatus;
@property (nonatomic, strong) UIBarButtonItem *finishForInspectionStatus;
@property (nonatomic, strong) UIBarButtonItem *addStoreButton;
@property (nonatomic, strong) UIActionSheet *actionSheet;
@property (nonatomic, strong) NSString *pageTitle;
@property (nonatomic, strong) UIImagePickerController *oldImagePicker;
@property (strong, atomic) ALAssetsLibrary* library;
@property (strong, nonatomic) NSMutableArray *assetGroups;
@property (nonatomic, strong) UIBarButtonItem *logViewButton;
@property (nonatomic, strong) UIButton *listButton;
@property (nonatomic, strong) UIButton *imageGalleryButton;
@property (nonatomic, strong) UIButton *duplicateButton;
@property (nonatomic, strong) UIButton *infoButton;
@property (nonatomic, strong) UIButton *infoButtonGrey; //for product rating
@property (nonatomic, strong) UIButton *emailButton;
@property (nonatomic, strong) UIButton *discardButton;
@property (nonatomic, strong) UIButton *forwardArrow;
@property (nonatomic, strong) UIButton *backArrow;
@property (nonatomic, strong) UIButton *warningIcon;

//@property (weak, nonatomic) IBOutlet UIBarButtonItem *takePictureButton;
//@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (strong, nonatomic) IBOutlet UIView *overlayView;
//@property (nonatomic) UIImagePickerController *imagePickerController;
@property (weak, nonatomic) IBOutlet UIButton *takePictureButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *galleryButton;
@property (weak, nonatomic) IBOutlet UIButton *flashButton;
@property (weak, nonatomic) IBOutlet UILabel *flashStatus;
@property (strong, nonatomic) SyncOverlayView *syncOverlayView;


- (void) setupNavBar;
- (void) setupPhotosAlbum;
- (void) cameraButtonIconDecide;
- (void)cameraButtonTouched;
- (void) orderDataSyncButtonTouched;
- (void) goBack;
- (void) addStoreButtonPressed;
- (void) logStatusTouched;
- (void)showLoadingScreenWithText:(NSString*)message;
- (void)dismissLoadingScreen;
-(void)showSimpleAlertWithMessage:(NSString*)message withTitle:(NSString*)title;
- (void) initializeOrderDataTable;
-(void)saveCameraFlashModeInPreferences:(int)flashMode;
-(void)collaborativeConnectionErrorNotification;
-(void)updateContainerViewNavBar:(BOOL)isWatningIconNeeded;
-(void)updateProductListNavBar:(BOOL)isWarningIconNeeded;

@end
