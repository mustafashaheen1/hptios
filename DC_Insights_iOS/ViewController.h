//
//  ViewController.h
//  inigmaSDKDemo
//
//  Created by 1 1 on 4/1/12.
//  Copyright (c) 2012 1. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "SWBarcodePickerManager.h"
#import "ParentNavigationViewController.h"
#import "User.h"
#import <AudioToolbox/AudioToolbox.h>
#import "Product.h"

@protocol ScannerProtocol <NSObject>

// Scan found a UPC and is checking on the server
- (void)scanCheckingForProductOnServer:(Product*)productInProgress;

// Scanning complete
- (void)scanDoneWithProduct:(Product*)theProduct;
- (void)scanDoneWithUpc:(NSString*)theUpc;
- (void)scanDoneWithError:(NSError*)theError forProduct:(Product*)theProduct;
- (void)scanCancelled;

@end

@interface ViewController : ParentNavigationViewController<ScannerProtocol, UITableViewDataSource, UITableViewDelegate>{
    IBOutlet UIButton *ScanButton;
    IBOutlet UIButton *StartStopButton;
    IBOutlet UIButton *CloseButton;
    IBOutlet UILabel *Label;
    IBOutlet UILabel *LabelDecode;
    IBOutlet UILabel *LabelNoti;
    IBOutlet UILabel *LabelType;
    IBOutlet UIButton *UpdateButton;
    IBOutlet UITableView *table;
    IBOutlet UIButton *TorchButton;
    IBOutlet UISegmentedControl *CameraSelection;
    IBOutlet UISegmentedControl *PreviewScanStyle;
    CGRect StopButtonRect;
    CGRect CloseButtonRect;
    void* m_pScanner;
    int m_bTorch;
    NSInteger m_prevCam;
    
}

@property (nonatomic, retain) id <ScannerProtocol> delegate;
@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) NSMutableArray<NSString*> *codeScannedArray;
@property (nonatomic, retain) NSMutableArray *invalidCodesScannedArray;
//@property (nonatomic, retain) NSMutableArray *multipleCodesScannedArray; //also stores the comma separated multi-code scans
@property (nonatomic, retain) NSString *globalScan;
@property (nonatomic, retain) NSString *allCodes;
@property (nonatomic, assign) BOOL multiScan;
@property (nonatomic, assign) BOOL notifyUser;
@property (nonatomic, assign) BOOL correctScan;
@property (nonatomic,retain) UILabel *countLabel;
@property (nonatomic, assign) BOOL enforceQROnlyScan;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withDelegate:delegate;
-(void) initLocal;
-(void) onError: (const char*) str;
-(void) onNotify: (const char*) str;
-(void) onDecode: (const unsigned short*) str :(const char*) strType :(const char*) strMode;
-(void) OnCameraStopOrStart:(int) on;
- (IBAction)UdateLicPressed;
- (IBAction)StartStopPressed;
- (IBAction)ClosePressed;
- (IBAction)TorchPressed;
- (IBAction)PreviewScanStyleChange;
- (void) OnForground;
- (void) OnBackground;
-(void)startScanner;
-(IBAction)cancelPressed;

@end
