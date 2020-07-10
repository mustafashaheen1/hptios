//
//  ViewController.m
//  inigmaSDKDemo
//
//  Created by 1 1 on 4/1/12.
//  Copyright (c) 2012 1. All rights reserved.
//

#import "ViewController.h"
#import "Scanner.h"


void WrapError(void* pThis,const char* str)
{
	ViewController* p = (__bridge ViewController*)pThis;
	[p onError:str];
}
void WrapNotify(void* pThis,const char* str)
{
	ViewController* p = (__bridge ViewController*)pThis;
	[p onNotify:str];
}
void WrapDecode(void* pThis,const unsigned short* str,const char* SymbolType,const char* SymbolMode)
{
	ViewController* p = (__bridge ViewController*)pThis;
	[p onDecode:str:SymbolType:SymbolMode];
}
void WrapCameraStopOrStart(int on,void* pThis)
{
	ViewController* p = (__bridge ViewController*)pThis;
	[p OnCameraStopOrStart:on];	
    if (on)
    {
        [p onError:""];
        [p onNotify:""];
    }
}


@interface ViewController ()

@end

@implementation ViewController
@synthesize delegate;

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
    [super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated {
    self.pageTitle = @"ScannerView";
    self.codeScannedArray = [NSMutableArray array];
    NSArray *codesArray = [self.allCodes componentsSeparatedByString:@","];
    if ([codesArray count] > 0) {
        self.codeScannedArray = [codesArray mutableCopy];
    }
    [self setupNavBar];
    [self tableViewSetup];
    [super viewWillAppear:animated];
}

- (void)viewDidload {
    [super viewDidLoad];
}

- (void) markButtonTouched {
    NSString *strLocal = @"";
    for (NSString *stringToken in self.codeScannedArray) {
        strLocal = [strLocal stringByAppendingString:stringToken];
        strLocal = [strLocal stringByAppendingString:@","];
    }
    [self.delegate scanDoneWithUpc:strLocal];
    [self.navigationController popViewControllerAnimated:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withDelegate:(id <SWBarcodePickerManagerProtocol>)scannerDelegate{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.delegate = scannerDelegate;
    if (self) {
        [self initLocal];
    }
    [self ScanPressed]; //fire scanner
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    [self initLocal];
	return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
   
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
{
    if (m_pScanner){
        ((CScanner*)m_pScanner)->SetOrientation(toInterfaceOrientation);
    }
    if (toInterfaceOrientation == UIDeviceOrientationLandscapeRight ||
        toInterfaceOrientation == UIDeviceOrientationLandscapeLeft){
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
                StopButtonRect = CGRectMake(200,600,160,70);
                CloseButtonRect = CGRectMake(460,600,160,70);
        }else{
                StopButtonRect = CGRectMake(30,240,115,50);
                CloseButtonRect = CGRectMake(190,240,115,50);
        }
    }else{
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
                StopButtonRect = CGRectMake(200,860,160,70);
                CloseButtonRect = CGRectMake(460,860,160,70);
        }else{
                StopButtonRect = CGRectMake(30,340,115,50);
                CloseButtonRect = CGRectMake(175,340,115,50);
        }
        
    }
    if (StartStopButton){
        StartStopButton.frame = StopButtonRect;
        CloseButton.frame = CloseButtonRect;
    }
}

/*
 If you were to create the view programmatically, you would use initWithFrame:.
 You want to make sure the placard view is set up in this case as well (as in initWithCoder:).
 */
-(void) initLocal
{
    m_pScanner = new CScanner((__bridge void*)self);
	StartStopButton = NULL;
	CloseButton = NULL;
    m_bTorch = 0;
    m_prevCam = -1;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
        StopButtonRect = CGRectMake(200,860,160,70);
        CloseButtonRect = CGRectMake(460,860,160,70);
    }else{
        StopButtonRect = CGRectMake(30,340,115,50);
        CloseButtonRect = CGRectMake(175,340,115,50);
    }
      

}
- (void)dealloc {
    if (m_pScanner){
        delete ((CScanner*)m_pScanner);
    }
    
	//[super dealloc];
	
}

- (IBAction)ScanPressed {
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
        ((CScanner*)m_pScanner)->Scan((__bridge void*)self.view,30,30,720,920,30,30,920,720,
                                      CameraSelection.selectedSegmentIndex != 0,
                                      PreviewScanStyle.selectedSegmentIndex != 0);
    }else{
        ((CScanner*)m_pScanner)->Scan((__bridge void*)self.view,5,5,310,400,5,0,470,340,
                                      CameraSelection.selectedSegmentIndex != 0,
                                      PreviewScanStyle.selectedSegmentIndex != 0, 300);
    }
    if (StartStopButton) {
        if (PreviewScanStyle.selectedSegmentIndex == 0)
            [StartStopButton setTitle:@"Stop" forState:UIControlStateNormal];
        else
            [StartStopButton setTitle:@"Start" forState:UIControlStateNormal];
    }
}

- (IBAction)UdateLicPressed
{
	((CScanner*)m_pScanner)->UpdateLicense();
}

- (IBAction)StartStopPressed
{
	if ([StartStopButton.titleLabel.text isEqualToString:@"Stop"])
        ((CScanner*)m_pScanner)->Abort();
    else {
        [StartStopButton setTitle:@"Stop" forState:UIControlStateNormal];
        ((CScanner*)m_pScanner)->StartDecoding();
    }
}

- (IBAction)ClosePressed
{
	((CScanner*)m_pScanner)->CloseCamera();
 	StartStopButton = NULL;
}

- (IBAction)TorchPressed
{
	if (m_bTorch == 0){
        m_bTorch = 1;
        ((CScanner*)m_pScanner)->TurnTorch(1);
    }else{
        m_bTorch = 0;
        ((CScanner*)m_pScanner)->TurnTorch(0);
        
    }
}
- (IBAction)PreviewScanStyleChange
{
    if (PreviewScanStyle.selectedSegmentIndex == 0){
        [ScanButton setTitle:@"Scan" forState:UIControlStateNormal];
    }else{
        [ScanButton setTitle:@"Preview" forState:UIControlStateNormal];
    }
}

-(void) onError: (const char*) str
{
	NSString *strLocal;
	strLocal = [NSString stringWithFormat:@"%s" , str];
	[Label setText:strLocal];
	[Label layoutIfNeeded];
}

-(void) onNotify: (const char*) str
{
	NSString *strLocal;
	strLocal = [NSString stringWithFormat:@"%s" , str];
	[LabelNoti setText:strLocal];
	[LabelNoti layoutIfNeeded];
}

-(void) onDecode: (const unsigned short*) str : (const char*) strType : (const char*) strMode

{
	NSString *strLocal;
	strLocal = [NSString stringWithFormat:@"%S" , str];
	[LabelDecode setText:strLocal];
	[LabelDecode layoutIfNeeded];
    
    NSString *strLocalT;
    if (strMode==0)
        strLocalT = [NSString stringWithFormat:@"%s" , strType];
    else
        strLocalT = [NSString stringWithFormat:@"%s (%s)" , strType, strMode];
	[LabelType setText:strLocalT];
	[LabelType layoutIfNeeded];
    
    self.globalScan = [NSString stringWithFormat:@"Code already scanned %@", strLocal];
    if (![self.codeScannedArray containsObject:strLocal]) {
        self.globalScan = [NSString stringWithFormat:@"Last code scanned %@", strLocal];
        [self.codeScannedArray addObject:strLocal];
    }
    [self.table reloadData];
    [self ScanPressed]; //fire scanner
}
-(void) OnCameraStopOrStart:(int) on
{

    if (on == 1){
        if (((CScanner*)m_pScanner)->IsTorchAvailable()){
            TorchButton.hidden = NO;
            [TorchButton setNeedsDisplay];
        }
		if (StartStopButton && m_prevCam == CameraSelection.selectedSegmentIndex)
		{
			StartStopButton.hidden = NO;
			[StartStopButton setNeedsLayout];
			CloseButton.hidden = NO;
			[CloseButton setNeedsLayout];
        }else{
			StartStopButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
			[StartStopButton addTarget:self action:@selector(StartStopPressed) forControlEvents:UIControlEventTouchUpInside];
            if (PreviewScanStyle.selectedSegmentIndex == 0)
                [StartStopButton setTitle:@"Stop" forState:UIControlStateNormal];
            else
                [StartStopButton setTitle:@"Start" forState:UIControlStateNormal];
            StartStopButton.frame = StopButtonRect;
			//[self.view addSubview:StartStopButton];
			CloseButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
			[CloseButton addTarget:self action:@selector(ClosePressed) forControlEvents:UIControlEventTouchUpInside];
			[CloseButton setTitle:@"CloseCam" forState:UIControlStateNormal];
            CloseButton.frame = CloseButtonRect;
			//[self.view addSubview:CloseButton];
            //[self.delegate scanDoneWithUpc:@"sdsds"];
		}
        m_prevCam = CameraSelection.selectedSegmentIndex;
    }
	if (on == 0){
		StartStopButton.hidden=YES;
		[StartStopButton setNeedsLayout];
		CloseButton.hidden=YES;
		[CloseButton setNeedsLayout];
        TorchButton.hidden = YES;
        [TorchButton setNeedsDisplay];
	}
}

#define xPosition 10
#define yPosition 290
#define xPositionEnding 20
#define heightTable 200

- (void) tableViewSetup {
    if (!self.table)
        self.table = [[UITableView alloc] initWithFrame:CGRectMake(xPosition, yPosition, self.view.frame.size.width - xPositionEnding, heightTable)];
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        self.table.frame = CGRectMake(0, yPosition, self.view.frame.size.width, self.view.frame.size.height);
    }
    if (IS_IPHONE5) {
        self.table.frame = CGRectMake(xPosition, yPosition, self.view.frame.size.width - xPositionEnding, heightTable);
    }
    self.table.delegate = self;
    self.table.separatorInset = UIEdgeInsetsZero;
    self.table.dataSource = self;
    self.table.layer.borderWidth = 2.0;
    self.table.layer.borderColor = [[UIColor blackColor] CGColor];
    self.table.layer.cornerRadius = 5.0;
    self.table.allowsMultipleSelectionDuringEditing = NO;
    [self.view addSubview:self.table];
}

#pragma mark - UITableViewDataSource

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (self.globalScan)
        return 50;
    else
        return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    sectionHeaderView.backgroundColor = [UIColor darkGrayColor];

    UILabel *nameOftheGroup = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, self.view.frame.size.width, 50)];
    if (self.globalScan) {
        nameOftheGroup.text = [NSString stringWithFormat:@"%@", self.globalScan];
    }
    nameOftheGroup.textColor = [UIColor whiteColor];
    nameOftheGroup.backgroundColor = [UIColor clearColor];
    nameOftheGroup.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    [sectionHeaderView addSubview:nameOftheGroup];
    
    return sectionHeaderView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.codeScannedArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SKSTableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    cell.textLabel.text = [self.codeScannedArray objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

// Override to support conditional editing of the table view.
// This only needs to be implemented if you are going to be returning NO
// for some items. By default, all items are editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [self.codeScannedArray removeObject:cell.textLabel.text];
        [self.table reloadData];
    }
}

- (void)OnBackground {
    ((CScanner*)m_pScanner)->OnBackground();
}

- (void)OnForground {
    ((CScanner*)m_pScanner)->OnForground();
}

- (IBAction)cancelPressed {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
