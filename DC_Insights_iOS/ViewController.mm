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
    self.invalidCodesScannedArray = [NSMutableArray array];
    //self.multipleCodesScannedArray = [NSMutableArray array];
    NSArray *codesArray = [self.allCodes componentsSeparatedByString:@","];
    if ([codesArray count] > 0) {
        self.codeScannedArray = [codesArray mutableCopy];
    }
    [self setupNavBar];
    if (self.multiScan) {
        [self tableViewSetup];
    }
    [super viewWillAppear:animated];
}

- (void)viewDidload {
    [super viewDidLoad];
}

- (void) markButtonTouched {
    NSString *strLocal = @"";
    /*for (NSString *stringToken in self.codeScannedArray) {
        strLocal = [strLocal stringByAppendingString:stringToken];
        strLocal = [strLocal stringByAppendingString:@","];
    }*/
    strLocal = [self.codeScannedArray componentsJoinedByString:@","];
    [self.delegate scanDoneWithUpc:strLocal];
    [self.navigationController popViewControllerAnimated:YES];
}

//TODO : rename the method for X button
-(void)cancelInspectionStatusTouched{
    //when X button is clicked in CodeExplorer
    [self.delegate scanDoneWithUpc:SCAN_CANCELLED];
    [self.navigationController popViewControllerAnimated:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withDelegate:(id <ScannerProtocol>)scannerDelegate{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.delegate = scannerDelegate;
    if (self) {
        [self initLocal];
    }
    //TODO: move out of this function
    //[self ScanPressed]; //fire scanner
    return self;
}

-(void)startScanner{
    [self ScanPressed];
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
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    float width = window.frame.size.width;
    float height = window.frame.size.height;

    if ([[[User sharedUser] getAuditorRole] isEqualToString:AUDITOR_ROLE_SCANOUT])
        ((CScanner*)m_pScanner)->isScanOut = true;
    
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    if([appName isEqualToString:@"CodeExplorer"]){
        ((CScanner*)m_pScanner)->isCodeExplorer = true;
    }
    
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
        ((CScanner*)m_pScanner)->Scan((__bridge void*)self.view,30,30,720,920,30,30,920,720,
                                      CameraSelection.selectedSegmentIndex != 0,
                                      PreviewScanStyle.selectedSegmentIndex != 0);
    }else{
        ((CScanner*)m_pScanner)->Scan((__bridge void*)self.view,0,-100,width,height,0,0,0,0,
                                      0,
                                      0, 300);
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
    
    if ([strLocal rangeOfString:@"C_"].location == NSNotFound) { //invalid code
        if(self.multiScan){
            if(!self.globalScan)
                self.globalScan = @"Invalid Code";
            
            if (![self.invalidCodesScannedArray containsObject:strLocal]){ //if code not scanned previously
                [self.invalidCodesScannedArray addObject:strLocal];
                self.notifyUser = true;
                self.correctScan = false;
                [self playBeep];
            } else { //if scanned previously
                self.notifyUser = true;
                self.correctScan = false;
            }
            [self.table reloadData];
            [self ScanPressed]; //fire scanner
            return;
        }
    } else {
        strLocal = [strLocal stringByReplacingOccurrencesOfString:@"C_" withString:@""];
    }
    // read codes with C_
    if (self.multiScan) {
        //self.globalScan = [NSString stringWithFormat:@"Code already scanned %@", strLocal];
        if (![self.codeScannedArray containsObject:strLocal]) {
            self.globalScan = [NSString stringWithFormat:@"Last code scanned: %@", strLocal];
            //[self.codeScannedArray addObject:strLocal];
            [self.codeScannedArray insertObject:strLocal atIndex:0];
            self.notifyUser = true;
            self.correctScan = true;
            [self playBeep];
        }
        [self.table reloadData];
        [self ScanPressed]; //fire scanner
    } else {
        [self.delegate scanDoneWithUpc:strLocal];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    if(self.countLabel)
        self.countLabel.text = [NSString stringWithFormat:@"%d",(int)[self.codeScannedArray count]];
    
}
/* //for multiple scanout code scan
-(void) onDecode: (const unsigned short*) str : (const char*) strType : (const char*) strMode

{
	NSString *strLocal;
	strLocal = [NSString stringWithFormat:@"%S" , str];
    
    if ([strLocal rangeOfString:@"C_"].location == NSNotFound) { //invalid code
        if(self.multiScan){
            if(!self.globalScan)
                self.globalScan = @"Invalid Code";
            
            if (![self.invalidCodesScannedArray containsObject:strLocal] && ![self.multipleCodesScannedArray containsObject:strLocal]){ //if code not scanned previously
                [self.invalidCodesScannedArray addObject:strLocal];
                self.notifyUser = true;
                self.correctScan = false;
                [self playBeep];
            } else { //if scanned previously
                self.notifyUser = true;
                self.correctScan = false;
            }
            [self.table reloadData];
            [self ScanPressed]; //fire scanner
            return;
        }
    } else {
        strLocal = [strLocal stringByReplacingOccurrencesOfString:@"C_" withString:@""];
    }
    // read codes with C_
    if (self.multiScan) {
        //self.globalScan = [NSString stringWithFormat:@"Code already scanned %@", strLocal];
        if (![self.codeScannedArray containsObject:strLocal] && ![self.multipleCodesScannedArray containsObject:strLocal]) {
            self.globalScan = [NSString stringWithFormat:@"Last code scanned: %@", strLocal];
            //[self.codeScannedArray addObject:strLocal];
            
             //if multiple codes scanned at once
            NSArray *splitCodes = [self splitMultipleCodes:strLocal];
            if(splitCodes && [splitCodes count]>0){
                [self.codeScannedArray replaceObjectsInRange:NSMakeRange(0,0)
                                withObjectsFromArray:splitCodes];
                [self.multipleCodesScannedArray insertObject:strLocal atIndex:0];
            }else
                [self.codeScannedArray insertObject:strLocal atIndex:0];
            
            self.notifyUser = true;
            self.correctScan = true;
            [self playBeep];
        }
        [self.table reloadData];
        [self ScanPressed]; //fire scanner
    } else {
        [self.delegate scanDoneWithUpc:strLocal];
        [self.navigationController popViewControllerAnimated:YES];
    }

}
*/
//to check if the scanned code is actually mutiple comma separated codes
-(NSArray*)splitMultipleCodes:(NSString*)scannedCode{
    if (scannedCode && [scannedCode rangeOfString:@","].location != NSNotFound){
        NSArray *codes = [scannedCode componentsSeparatedByString:@","];
        if([codes count]>0)
            return codes;
    }
    return nil;
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
    
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    
    NSLog(@"Scanner Screen Window Width %f",window.frame.size.width);
    NSLog(@"Scanner Screen Window height %f",window.frame.size.height);
    
    float tableYPosition = window.frame.size.height - (window.frame.size.height/2);
    float tableHeight =(window.frame.size.height/2);
    
    if (!self.table)
        self.table = [[UITableView alloc] initWithFrame:CGRectMake(0, tableYPosition, window.frame.size.width, tableHeight)];
//    CGFloat width  = CGRectGetWidth([[UIScreen mainScreen] bounds]);
//    CGFloat height = CGRectGetHeight([[UIScreen mainScreen] bounds]);
    
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        self.table.frame = CGRectMake(0, tableYPosition, window.frame.size.width, tableHeight);
    }
    if (IS_IPHONE5 || IS_IPHONE6) {
        self.table.frame = CGRectMake(0, tableYPosition, window.frame.size.width , tableHeight);
    }
    self.table.delegate = self;
    self.table.separatorInset = UIEdgeInsetsZero;
    self.table.dataSource = self;
    self.table.layer.borderWidth = 2.0;
    self.table.layer.borderColor = [[UIColor blackColor] CGColor];
    self.table.layer.cornerRadius = 5.0;
    self.table.allowsMultipleSelectionDuringEditing = NO;
    [self.view addSubview:self.table];
    
    self.countLabel = [[UILabel alloc] initWithFrame:CGRectMake(window.frame.size.width-50.0,25.0,40.0,40.0)];
    self.countLabel.font = [UIFont boldSystemFontOfSize:25];
    self.countLabel.textColor = [UIColor blackColor];
    self.countLabel.backgroundColor = [UIColor lightGrayColor];
    self.countLabel.text = @"0";
    self.countLabel.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:self.countLabel];
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
    if(self.notifyUser && self.correctScan){ //correct code scanned
        [UIView animateWithDuration:2.0 animations:^{
            sectionHeaderView.backgroundColor = [UIColor greenColor];
        } completion:NULL];
    }
    else if(self.notifyUser && !self.correctScan) { //invalid code scanned
        [UIView animateWithDuration:2.0 animations:^{
            sectionHeaderView.backgroundColor = [UIColor redColor];
        } completion:NULL];
    }
    else{
        sectionHeaderView.backgroundColor = [UIColor blackColor];
    }
    self.notifyUser = false;
    self.correctScan = false;

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

-(void) playBeep {
    AudioServicesPlaySystemSound (1200);
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
