//
//  ScanCodeViewController.m
//  Insights
//
//  Created by Mustafa Shaheen on 7/6/20.
//  Copyright © 2020 Yottamark. All rights reserved.
//

#import "ScanCodeViewController.h"
@import ScanditBarcodeCapture;
#import "HPTCaseCodeViewController.h"
static NSString *const _Nonnull licenseKey = @"ASHe0hMBDE75BbkR4xWae94Ezm55DtkCCExXCaBtDrpOc/cu+UFDmkAugfP5NM8t+lqPgSxtpeI3Vs5nZV+mkIVgyqhqIw0HNQB9S1FwagrPUwRKZ25QIBF9L2iMecIt43Kffv4AbrwlGIUOwTNQG/0DTS7VbJyhD2ZOJcYZL/hnSmugZ7j5kx0t/0GGnioTI/9rNvhV68han23lxghx/0yXEgsTrTgFP155ZMiZc3gZNyJlyO68IrJsDZmWL1DKpgQUgV4VYCsGfZpexJfwoDCC6EcLNDCEsTD+R2MT7IWYF7NsiQcPvq04s5daKfC52dWq6KmivLGFFUSgNq2pKjU+N/5FXyvRq7pIDfCHsvgIb0cPBbs3E3IEnf2zOB8N7GOsx/m6TOViNM7H7WNQeyyWPSWLCZM+1eUiJq6aYsXCIxrQtqIWk0MPi73AcAoaN+9f+f6/2v0BA5wc6F2qOkjBr9ven07pEOrqzXZMpfAGuFx+5NhbqUukzH1Klyt3gR3lSdujF1uoIK5kIEMUtC4VaJ1Pf1gWnYnqLNyrkcopd2a8UTRbz4kHpOYEwIWYqHtNqCERSKq51ypW8mXdXPoob01dQreuG77R/7iDcWQsjojivejA5S49L+5Q7yhiTqGoXntjgjZJ72q+652MTpvMqRLy/j5bRcabg+rkclQBn+s3rdumhD91tXBzVt50vG8AuumSs2nXzCE2pSZP8TSjwNoArWmR8yRV/VLzSKsBu4xng3pOSCWWw2SCSleb+bRzwznXSaiu8/pteM0C4Sn+gE6kKG69GrhNBcNOmq5+wHfDUObH74IyJKu4Q9xkRFiE";

@implementation SDCDataCaptureContext (Licensed)

// Get a licensed DataCaptureContext.
+ (SDCDataCaptureContext *)licensedDataCaptureContext {
    return [self contextForLicenseKey:licenseKey];
}

@end
@interface ScanCodeViewController () <SDCBarcodeCaptureListener>

@property (strong, nonatomic) SDCDataCaptureContext *context;
@property (strong, nonatomic, nullable) SDCCamera *camera;
@property (strong, nonatomic) SDCBarcodeCapture *barcodeCapture;
@property (strong, nonatomic) SDCDataCaptureView *captureView;
@property (strong, nonatomic) SDCBarcodeCaptureOverlay *overlay;

@end

@implementation ScanCodeViewController
@synthesize caseCodes;
@synthesize quantities;
@synthesize sscc;
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupRecognition];
    self.caseCodes = [[NSMutableArray alloc] init];
    self.quantities = [[NSMutableArray alloc] init];
    self.sscc = @"";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.pageTitle = @"PalletShippingScanCodeViewController";
    [self setupNavBar];
    // Switch camera on to start streaming frames. The camera is started asynchronously and will
    // take some time to completely turn on.
    self.barcodeCapture.enabled = YES;
    [self.camera switchToDesiredState:SDCFrameSourceStateOn];
}


- (void) setupNavBar {
    [super setupNavBar];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    // Switch camera off to stop streaming frames. The camera is stopped asynchronously and will
    // take some time to completely turn off. Until it is completely stopped, it is still possible
    // to receive further results, hence it's a good idea to first disable barcode capture as well.
    self.barcodeCapture.enabled = NO;
    [self.camera switchToDesiredState:SDCFrameSourceStateOff];
}
- (void)setupRecognition {
    // Create data capture context using your license key.
    self.context = [SDCDataCaptureContext licensedDataCaptureContext];

    // Use the world-facing (back) camera and set it as the frame source of the context. The camera
    // is off by default and must be turned on to start streaming frames to the data capture context
    // for recognition. See viewWillAppear and viewDidDisappear above.
    self.camera = SDCCamera.defaultCamera;

    // Use the recommended camera settings for the BarcodeCapture mode.
    SDCCameraSettings *recommendedCameraSettings = [SDCBarcodeCapture recommendedCameraSettings];
    [self.camera applySettings:recommendedCameraSettings completionHandler:nil];

    [self.context setFrameSource:self.camera completionHandler:nil];

    // The barcode capturing process is configured through barcode capture settings that first need
    // to be configured and are then applied to the barcode capture instance that manages barcode
    // recognition.
    SDCBarcodeCaptureSettings *settings = [SDCBarcodeCaptureSettings settings];

    // The settings instance initially has all types of barcodes (symbologies) disabled. For the
    // purpose of this sample we enable a very generous set of symbologies. In your own app ensure
    // that you only enable the symbologies that your app requires as every additional symbology
    // enabled has an impact on processing times.
    [settings setSymbology:SDCSymbologyCode128 enabled:YES];

    // Some linear/1d barcode symbologies allow you to encode variable-length data. By default, the
    // Scandit Data Capture SDK only scans barcodes in a certain length range. If your application
    // requires scanning of one of these symbologies, and the length is falling outside the default
    // range, you may need to adjust the "active symbol counts" for this symbology. This is shown in
    // the following few lines of code for one of the variable-length symbologies.
    SDCSymbologySettings *symbologySettings = [settings settingsForSymbology:SDCSymbologyCode39];
    symbologySettings.activeSymbolCounts = [NSSet
    setWithObjects:@7, @8, @9, @10, @11, @12, @13, @14, @15, @16, @17, @18, @19, @20, nil];

    // Create new barcode capture mode with the settings from above.
    self.barcodeCapture = [SDCBarcodeCapture barcodeCaptureWithContext:self.context
    settings:settings];

    // Register self as a listener to get informed whenever a new barcode got recognized.
    [self.barcodeCapture addListener:self];

    // To visualize the on-going barcode capturing process on screen, setup a data capture view that
    // renders the camera preview. The view must be connected to the data capture context.
    self.captureView = [[SDCDataCaptureView alloc] initWithFrame:self.view.bounds];
    self.captureView.context = self.context;
    self.captureView.autoresizingMask = UIViewAutoresizingFlexibleHeight |
                                        UIViewAutoresizingFlexibleWidth;
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(5.0,35.0,25.0,25.0)];
    closeButton.titleLabel.text = @"Close";
    [closeButton addTarget:self
               action:@selector(closeButtonTouched)
     forControlEvents:UIControlEventTouchUpInside];
    UIButton *resetButton = [[UIButton alloc] initWithFrame:CGRectMake(40.0,35.0,25.0,25.0)];
    resetButton.titleLabel.text = @"Reset";
    [resetButton addTarget:self
               action:@selector(resetButtonTouched)
     forControlEvents:UIControlEventTouchUpInside];
    [self.captureView addSubview:closeButton];
    [self.captureView addSubview:resetButton];
    [self.view addSubview:self.captureView];

    // Add a barcode capture overlay to the data capture view to render the location of captured
    // barcodes on top of the video preview. This is optional, but recommended for better visual
    // feedback.
    self.overlay = [SDCBarcodeCaptureOverlay overlayWithBarcodeCapture:self.barcodeCapture];
    self.overlay.viewfinder = [SDCRectangularViewfinder viewfinder];
    [self.captureView addOverlay:self.overlay];
}
- (void)showResult:(nonnull NSString *)result completion:(nonnull void (^)(void))completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController
            alertControllerWithTitle:result
                             message:nil
                      preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *_Nonnull action) {
                                                    completion();
                                                }]];
        [self presentViewController:alert animated:YES completion:nil];
    });
}
- (void)barcodeCapture:(SDCBarcodeCapture *)barcodeCapture
      didScanInSession:(SDCBarcodeCaptureSession *)session
             frameData:(id<SDCFrameData>)frameData {
    SDCBarcode *barcode = [session.newlyRecognizedBarcodes firstObject];
    if (barcode == nil || barcode.data == nil) {
        return;
    }

    // Stop recognizing barcodes for as long as we are displaying the result. There won't be any new
    // results until the capture mode is enabled again. Note that disabling the capture mode does
    // not stop the camera, the camera continues to stream frames until it is turned off.
    self.barcodeCapture.enabled = NO;

    // If you are not disabling barcode capture here and want to continue scanning, consider
    // setting the codeDuplicateFilter when creating the barcode capture settings to around 500
    // or even -1 if you do not want codes to be scanned more than once.

    // Get the human readable name of the symbology and assemble the result to be shown.
    NSString *symbology =
        [[SDCSymbologyDescription alloc] initWithSymbology:barcode.symbology].readableName;
    NSString *result = [NSString stringWithFormat:@"Scanned %@ (%@)", barcode.data, symbology];

    NSString *finalString = barcode.data;
    if(finalString.length != 20){
        [self.caseCodes addObject:finalString];
        [self.quantities addObject:[NSNumber numberWithInt:1]];
    }else{
        self.sscc = finalString;
    }
    __weak ScanCodeViewController *weakSelf = self;
    [self showResult:result
          completion:^{
              // Enable recognizing barcodes when the result is not shown anymore.
              weakSelf.barcodeCapture.enabled = YES;
          }];
}
-(void) goBack{
    [self navigateToCaseCodeController];
}
-(void) navigateToCaseCodeController{
    HPTCaseCodeViewController *caseCodeViewController = [[HPTCaseCodeViewController alloc] initWithNibName:kCaseCodeViewNIBName bundle:nil];
    NSString *code = @"01199887766551319111810181119A1";
    [self.caseCodes addObject:code];
    [self.quantities addObject:[NSNumber numberWithInt:1]];
    caseCodeViewController.caseCodeList = self.caseCodes;
    caseCodeViewController.descriptionRatingViewCell.caseCodes = self.caseCodes;
    caseCodeViewController.descriptionRatingViewCell.quantities = self.quantities;
    caseCodeViewController.sscc = self.sscc;
    [self.navigationController pushViewController:caseCodeViewController animated:YES];
}
@end
