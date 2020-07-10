//
//  CEScanViewController.m
//  Insights
//
//  Created by Vineet Pareek on 16/07/2015.
//  Copyright (c) 2015 Yottamark. All rights reserved.
//

#import "CEScanViewController.h"
#import "JSONHTTPClient.h"
#import "ViewController.h"
#import "CEResponse.h"
#import "LocationManager.h"
#import "CECodeDetailsViewController.h"
#import "CEHistory.h"
#import "CEHistoryList.h"
#import "CEHistoryViewController.h"

#define TRACE_ERROR_ALERT 10

@interface CEScanViewController ()

@end

@implementation CEScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.hmCodeTextBox.text = @"";
    if(PROGRAM_ZESPRI)
        [self.banner setImage:[UIImage imageNamed:@"banner.png"]];
    else
        [self.banner setImage:[UIImage imageNamed:@"driscoll_banner.png"]];
}

- (void) setupNavBar {
    [super setupNavBar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.pageTitle = @"CEScanViewController";
    [self setupNavBar];
    self.hmCodeTextBox.text = @""; // clear the box when loading screen
    self.checkCodeButton.layer.cornerRadius = BUTTON_CORNER_RADIUS;
    self.scanCodeButton.layer.cornerRadius = BUTTON_CORNER_RADIUS;
   
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}


-(NSString*) parseCEJson{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"mce" ofType:@"json"];
    NSString *myJSON = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    if (!myJSON) {
        NSLog(@"File couldn't be read!");
        return nil;
    }
    return myJSON;
}

-(CEResponse*)parseCEApiResponse:(NSString*)response{
    NSError* err = nil;
    CEResponse *apiResponse = nil;
    @try {
       apiResponse = [[CEResponse alloc] initWithString:response error:&err];
    } @catch(NSException *theException) {
        NSLog(@"An exception occurred: %@", theException.name);
        NSLog(@"Here are some details: %@", theException.reason);
        NSLog(@"Here are some details error : %@", err.localizedDescription);
    }
    //NSLog(@"response is: %@ %@", apiResponse, err.localizedDescription);
    return apiResponse;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)showTraceError:(NSString*)error withTitle:(NSString*)title{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:error
                                                   delegate:self
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:@"Report",nil];
    alert.alertViewStyle = UIAlertViewStyleDefault;
    alert.tag = TRACE_ERROR_ALERT;
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == TRACE_ERROR_ALERT) { //handle OK and cancel
        if(buttonIndex == alertView.firstOtherButtonIndex){
            //show email compose window with the error message
            [self emailButtonTouched];
        }
    }
}

- (IBAction)checkCodeButtonTapper:(id)sender {
   NSString* hmCode = self.hmCodeTextBox.text;
    if(!hmCode || [hmCode isEqualToString:@""] || ![self isValidCode:hmCode]){
        [[[UIAlertView alloc] initWithTitle:@"Invalid Code" message:@"Please scan a valid code" delegate: self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return;
    }
    NSString* codeToTrace = [self parseCodeToTrace:hmCode];
    [self traceCode:codeToTrace withTraceMethod:CE_TRACE_METHOD_TYPED];
    
    //[self traceCode:@"048733612735DS29" withTraceMethod:CE_TRACE_METHOD_TYPED];
}

- (IBAction)scanCodeButtonTapper:(id)sender {
    ViewController *scannerViewController = [[ViewController alloc] initWithNibName:@"ViewController_iPhone" bundle:nil withDelegate:self];
    //side effect of fix DI-1708 - need to fire scanner here
    [scannerViewController startScanner];
    [self.navigationController pushViewController:scannerViewController animated:YES];
}

#pragma mark - SWBarcodePickerManagerProtocol
- (void)scanDoneWithUpc:(NSString*)hmCode {
    if([hmCode isEqualToString:SCAN_CANCELLED]){
        return;
    }
    //self.hmCodeTextBox.text = theUpc;
    if([self isValidCode:hmCode]){
        NSString* codeToTrace = [self parseCodeToTrace:hmCode];
        [self traceCode:codeToTrace withTraceMethod:CE_TRACE_METHOD_SCANNED];
    }else{
        NSString* message = [NSString stringWithFormat:@"Scanned Code: \n%@\n Please scan a valid code",hmCode];
        [[[UIAlertView alloc] initWithTitle:@"Invalid Code" message:message delegate: self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }
}

- (void)scanCheckingForProductOnServer:(Product*)productInProgress {
}

- (void)scanDoneWithProduct:(Product*)theProduct {
}

- (void)scanDoneWithError:(NSError*)theError forProduct:(Product*)theProduct {
}

- (void)scanCancelled {
}

-(BOOL)isValidCode:(NSString*)hmCode{
    
    //check if 16 chars
    if(!hmCode || [hmCode isEqualToString:@""])
        return NO;
    
     //if less - return error
    int length = hmCode.length;
    if(length<16)
        return NO;
    
    //if exactly 16 -then validate
    else if(length==16){
        if(![self isMatchDriscollsCodeRegex:hmCode])
            return NO;
        
        //if more than 16 - then try to parse and validate
    }else if(length > 16){
        NSString* last16Chars = [hmCode substringFromIndex:length - 16];
        if(![self isMatchDriscollsCodeRegex:last16Chars])
            return NO;
    }
    return YES;
}

-(NSString*)parseCodeToTrace:(NSString*)scannedOrTypedCode{
    int length = scannedOrTypedCode.length;
    NSString* last16Chars = [scannedOrTypedCode substringFromIndex:length - 16];
    return last16Chars;
}

-(BOOL) isADriscollCode:(NSString*)code{
    if ([code rangeOfString:@"http://dscl.us/" options:NSCaseInsensitiveSearch].location == NSNotFound && [code rangeOfString:@"https://dscl.us/" options:NSCaseInsensitiveSearch].location == NSNotFound)
        return NO;
    else
        return YES;
}

-(NSString*) parseDriscollsCode:(NSString*)code{
    NSArray *splitStringArray = [code componentsSeparatedByString:@"/"];
    // this would display the characters before the character ")"
    NSLog(@"%@", [splitStringArray objectAtIndex:3]);
    NSString* parsedCode = [splitStringArray objectAtIndex:3];
    return parsedCode;
}

-(BOOL) isMatchDriscollsCodeRegex:(NSString*)code{
    NSString *searchedString = code;
   // NSRange   searchedRange = NSMakeRange(0, [searchedString length]);
    //NSString *pattern = @"^([a-zA-Z0-9]{12}DS[0-9a-zA-Z][0-9a-zA-Z])$";
    NSString *pattern = @"^([0-9]{12}[a-zA-Z0-9]{4})$";
    NSError  *error = nil;
    
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern: pattern options:0 error:&error];
    NSTextCheckingResult *match = [regex firstMatchInString:searchedString options:0 range:NSMakeRange(0, [searchedString length])];
    BOOL isMatch = match != nil;
    return isMatch;
}


#pragma mark - Networking
//Using AFNetworking
/*
-(void) traceCodeWithAFNetworking:(NSString*)hmCode withTraceMethod:(NSString*)traceMethod {
    
    [self.hmCodeTextBox resignFirstResponder];
    self.errorReport = [[ErrorReport alloc]init];
    
    //if network not available - return
    BOOL connectionAvailable = [DeviceManager isConnectedToInternet];
    if(!connectionAvailable){
        self.errorReport.error = @"No signal - Please check the connection";
        self.errorReport.statusCode = 0;
        [self showTraceError:@"No signal - Please check the connection" withTitle:@"Error"];
        return;
    }
    
    SyncOverlayView* overlayView = [self showLoadingScreen:hmCode];

    AFAppDotNetAPIClient *networkClient = [AFAppDotNetAPIClient sharedClient];
    [networkClient setDefaultHeader:@"Content-Type" value:@"application/json"];
    [networkClient setDefaultHeader:@"Lat" value:[self getLatitude]];
    [networkClient setDefaultHeader:@"Lon" value:[self getLongitude]];
    [networkClient setDefaultHeader:@"App-Version" value:[DeviceManager getCurrentVersionOfTheApp]];
    [networkClient setDefaultHeader:@"Time-Zone" value:[DeviceManager getTimeZone]];
    [networkClient setDefaultHeader:@"Trace-Method" value:traceMethod];

    
    NSString* url = [self getUrlForCodeExplorer:hmCode];
    
    [networkClient
     getPath:url
     parameters:nil
     success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSLog(@"Request %@", JSON);
        NSString* responseJSON = [NSString stringWithFormat:@"%@",JSON];
         //if user cancelled the operation
         if(overlayView.cancelPressed){
             NSLog(@"Cancelling and returning");
             return;
         }
         
         //dismiss loading
         //[self removeLoadingScreen];
         [overlayView dismissActivityView];
         [overlayView removeFromSuperview];
         
         //populate error report
         self.errorReport.hmCode = hmCode;
         self.errorReport.url = url;
         self.errorReport.headers =
         self.errorReport.time = [DeviceManager getCurrentDateTimeWithTimeZone];
         self.errorReport.username = [[User sharedUser] email];
         self.errorReport.roles = [NSUserDefaultsManager getObjectFromUserDeafults:AUDITOR_ROLE];

  
    
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

    }];
}
*/

//Using JSONModel Networking because of issues with AFNetworking timeouts
//TODO: upgrade AFNetworking library and use that instead

-(NSString*)getUrlForCodeExplorer:(NSString*)hmCode{
    //URL:
    //https://<Endpoint>/api/ce/v1/trace/<HMCode>?auth_token=<AUTH_TOKEN>&device_id=<DEVICE_ID>&mobile=true
    
    NSString *endPoint =[SyncManager getPortalEndpoint];
    NSString* url = [NSString stringWithFormat:@"%@api/ce/v1/trace/%@?auth_token=%@&device_id=%@&mobile=true",
                     endPoint,
                     hmCode,
                     [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"],
                     [DeviceManager getDeviceID]];
    return url;
}

-(void) traceCode:(NSString*)hmCode withTraceMethod:(NSString*)traceMethod {

    [self.hmCodeTextBox resignFirstResponder];
    
    
    //timeout
    [JSONHTTPClient setTimeoutInSeconds:30];
    
    //headers
    [[JSONHTTPClient requestHeaders] setValue:@"application/json" forKey:@"Content-Type"];
    [[JSONHTTPClient requestHeaders] setValue:[self getLatitude] forKey:@"Lat"];
    [[JSONHTTPClient requestHeaders] setValue:[self getLongitude] forKey:@"Lon"];
    [[JSONHTTPClient requestHeaders] setValue:[DeviceManager getCurrentVersionOfTheApp] forKey:@"App-Version"];
    [[JSONHTTPClient requestHeaders] setValue:[DeviceManager getTimeZone] forKey:@"Time-Zone"];
    [[JSONHTTPClient requestHeaders] setValue:traceMethod forKey:@"Trace-Method"];
    //DI-2476 - override useragent
    [[JSONHTTPClient requestHeaders] setValue:@"iPhone" forKey:@"User-Agent"];
    
    //url
    NSString* url = [self getUrlForCodeExplorer:hmCode];
    
    //populate error report
    self.errorReport = [[ErrorReport alloc]init];
    self.errorReport.hmCode = hmCode;
    self.errorReport.url = url;
    self.errorReport.headers =[JSONHTTPClient requestHeaders];
    self.errorReport.time = [DeviceManager getCurrentDateTimeWithTimeZone];
    self.errorReport.username = [[User sharedUser] email];
    self.errorReport.roles = [[User sharedUser] getAllRoles];
    
    //if network not available - return
    BOOL connectionAvailable = [DeviceManager isConnectedToInternet];
    if(!connectionAvailable){
        self.errorReport.error = @"No signal - Please check the connection";
        self.errorReport.statusCode = @"";
        [self showTraceError:@"No signal - Please check the connection" withTitle:@"Error"];
        return;
    }
    
    //show loading screen
    SyncOverlayView* overlayView = [self showLoadingScreen:hmCode];
    long startTime = [self getCurrentTime];
    NSMutableDictionary* heaers = [JSONHTTPClient requestHeaders];
    
    [JSONHTTPClient getJSONFromURLWithString:url params:nil completion:^(id json, JSONModelError *err) {
        
        //calculate time taken
        long endTime = [self getCurrentTime];
        long totalTime = (endTime - startTime); //secs
        self.errorReport.timeForTrace = [NSString stringWithFormat:@"%ld seconds",totalTime];
        
        //if user cancelled the operation
        if(overlayView.cancelPressed){
            NSLog(@"Cancelling and returning");
            return;
        }
        
        //dismiss loading
        [overlayView dismissActivityView];
        [overlayView removeFromSuperview];
        
        if(err) { //err response from the network call itself
            NSString* errorMessage = @"Server Timeout Error";
            long errorCode =(long)err.httpResponse.statusCode;
            if(errorCode == 500)
                errorMessage = [NSString stringWithFormat:@"Server Error"];//500

            [self showTraceError:errorMessage withTitle:@"Error"];
            
            self.errorReport.error = [NSString stringWithFormat:@"%@ : %@",errorMessage,err.localizedDescription];
            self.errorReport.statusCode = [NSString stringWithFormat:@"%ld",(long)err.httpResponse.statusCode];
            
            //add to history without product name
            [self addCodeToHistory:hmCode forProduct:@""];
            return;
        }else{
            //NSLog(@"JSONLocal %@", json);
            NSError* jsonParsingError = nil;
            CEResponse *responseObject = nil;
            @try {
                /*
                 NSString* response = [self parseCEJson];//local parsing
                responseObject = [[CEResponse alloc] initWithString:response error:&jsonParsingError]; //local parsing
                */
                
                responseObject = [[CEResponse alloc] initWithDictionary:json error:&jsonParsingError];
            } @catch(NSException *exception) { //parsing exception
                NSString* error = [NSString stringWithFormat:@"Exception:\n %@,%@,%@",exception.name,exception.reason,jsonParsingError.localizedDescription];
                NSLog(@"An exception occurred: %@", error);
                self.errorReport.error = [NSString stringWithFormat:@"An exception occurred: %@", error];
                self.errorReport.statusCode = @"200";
                //alert user
                NSString* errorMessage = [NSString stringWithFormat:@"Exception Parsing Response"];
                [self showTraceError:errorMessage withTitle:@"Error"];
                
                //add to history without product name
                [self addCodeToHistory:hmCode forProduct:@""];
                return;
            }
            
            //if error handling response object
            if(!responseObject){ //if parsing succesfull but object nill
                NSString* errorString = @"";
                if(err)
                errorString = [NSString stringWithFormat:@"%@",err];
                else
                errorString = [NSString stringWithFormat:@"Unknown error parsing response - parsed object null \n%@",jsonParsingError.localizedDescription];
                self.errorReport.error = errorString;
                self.errorReport.statusCode = @"200";
                //alert user
                NSString* errorMessage = [NSString stringWithFormat:@"Error Parsing Response"];
                [self showTraceError:errorMessage withTitle:@"Error"];
                
                //add to history without product name
                [self addCodeToHistory:hmCode forProduct:@""];
                return;
            }
            //check if response itself is valid
            if(!responseObject.response_status.success ){ //RoR portal failure
                NSString* errorString = responseObject.response_status.message;
                NSString* errorMessage = [NSString stringWithFormat:@"Response failed: %@, \nClws_Status: %@",errorString,responseObject.response_status.clws_status];
                self.errorReport.error = errorMessage;
                self.errorReport.statusCode = @"200";
                [self showTraceError:errorMessage withTitle:@"Error"];
                
                //add to history without product name
                [self addCodeToHistory:hmCode forProduct:@""];
                return;
            }
            
            if(!responseObject.response_status.valid ){ //.NET CLWS failure (or) code invalid
                NSString* errorString = responseObject.response_status.message;
                self.errorReport.error = [NSString stringWithFormat:@"Code not valid: %@, \nClws_Status: %@",errorString,responseObject.response_status.clws_status];
                self.errorReport.statusCode = @"200";
                
                [self showTraceError:@"No data associated to this code" withTitle:@"Error"];
                
                //add to history without product name
                [self addCodeToHistory:hmCode forProduct:@""];
                return;
            }
            
            //add to history without product name
            NSString* productName = [self getProductNameFromResponse:responseObject];
            [self addCodeToHistory:hmCode forProduct:productName];
            //[self addToHistory:responseObject];
            
            //Remove HarvestData for Zespri
            if(PROGRAM_ZESPRI){
                BOOL responseContainsHarvestData = [self isContainHarvestDataEvent:responseObject];
                if(responseContainsHarvestData) {
                    NSArray<CEEvent> *eventsWithoutHarvestData = [self removeHarvestDataEvent:responseObject];
                    if (eventsWithoutHarvestData != nil && [eventsWithoutHarvestData count] > 0)
                        responseObject.events = [eventsWithoutHarvestData mutableCopy];
                }
            }
            [self removeLoadingScreen];
            CECodeDetailsViewController* detailsViewController = [[CECodeDetailsViewController alloc]initWithNibName:@"CECodeDetailsViewController" bundle:nil];
            detailsViewController.apiResponse = responseObject;
            detailsViewController.tracedUrl = url;
            [self.navigationController pushViewController:detailsViewController animated:NO];
        }
    }];
}

-(BOOL) isContainHarvestDataEvent:(CEResponse*) response{
    if (response!=nil && response.events!=nil && [response.events count]> 0) {
        int length = [response.events count];
        for(int i=0; i<length; i++){
            CEEvent* event =[response.events objectAtIndex:i];
            NSString* eventName = event.name;
            if ([eventName isEqualToString:@"Harvest Data"]) {
                return YES;
            }
        }
    }
    return NO;
}

//TODO: need to trigger this based on an API response
-(NSArray<CEEvent>*)removeHarvestDataEvent:(CEResponse*)response{
    @try {
        if (response != nil && response.events != nil && [response.events count] > 0) {
            int length = [response.events count];
            NSMutableArray* newEventArray = [[NSMutableArray alloc]init];// Trace.Response.Event[length-1];
            for(int i=0; i<length; i++){
                CEEvent* event =[response.events objectAtIndex:i];
                NSString* eventName = event.name;
                if (![eventName isEqualToString:@"Harvest Data"]) {
                    [newEventArray addObject:event];
                }
            }
            return [newEventArray copy];
        }
    }@catch (NSException *e){
        return nil;
    }
    return nil;
}

-(NSString*)getProductNameFromResponse:(CEResponse*)response{
    NSString* productName = @"";
    @try {
        productName = response.product.name;
    } @catch(NSException *exception) {
        productName = @"";
    }
    if(!productName)
        productName = @"";
    
    return productName;
}

-(long)getCurrentTime{
    long time = 0;
    @try {
        time = (long)(NSTimeInterval)([[NSDate date] timeIntervalSince1970]);
    } @catch(NSException *exception) {
        time = 0;
    }
    return time;
}

/*
-(void)processApiResponse:(NSString*)response{
    //CEResponse* responseObject = [self parseCEApiResponse:response];
    
    NSError* err = nil;
    CEResponse *responseObject = nil;
    @try {
        responseObject = [[CEResponse alloc] initWithString:response error:&err];
    } @catch(NSException *exception) {
        NSString* error = [NSString stringWithFormat:@"Exception:\n %@,%@,%@",exception.name,exception.reason,err.localizedDescription];
        NSLog(@"An exception occurred: %@", error);
        [self removeLoadingScreen];
        [self showTraceError:error withTitle:@"Error"];
        return;
    }
    
    //if error handling response object
    if(!responseObject){
        NSString* errorString = @"";
        if(err)
            errorString = [NSString stringWithFormat:@"%@",err];
        else
            errorString = [NSString stringWithFormat:@"Unknown error parsing response - object null"];
        [self removeLoadingScreen];
        [self showTraceError:errorString withTitle:@"Error"];
        return;
    }
    
    [self addToHistory:responseObject];
    [self removeLoadingScreen];
    CECodeDetailsViewController* detailsViewController = [[CECodeDetailsViewController alloc]initWithNibName:@"CECodeDetailsViewController" bundle:nil];
    detailsViewController.apiResponse = responseObject;
    [self.navigationController pushViewController:detailsViewController animated:NO];
}
*/
-(SyncOverlayView*)showLoadingScreen:(NSString*)hmCode{
    NSString* message = [NSString stringWithFormat:@"%@",hmCode];

    UIWindow *win = [[UIApplication sharedApplication] keyWindow];
    SyncOverlayView* syncOverlayView = [[SyncOverlayView alloc] initWithFrame:CGRectMake(0, 20, win.bounds.size.width, win.bounds.size.height)];
    syncOverlayView.headingTitleLabel.text = message;
    syncOverlayView.apiDownloadedLabel.text = @"";
    [syncOverlayView showActivityView];
    [syncOverlayView showHideButton];
    [syncOverlayView showTractorLoadingAnimation];
    syncOverlayView.cancelPressed = NO;
    [win addSubview:syncOverlayView];
    return syncOverlayView;
}

-(void)removeLoadingScreen{
    [self.syncOverlayView dismissActivityView];
    [self.syncOverlayView removeFromSuperview];
}

-(void)addToHistory:(CEResponse*)apiResponse{
    CEHistory* history = [[CEHistory alloc]init];
    history.date = [self getTodaysDate];
    history.productName = apiResponse.product.name;
    history.hmCode = apiResponse.code;
    CEHistoryList* list = [[CEHistoryList alloc]init];
    [list saveToPrefs:history];
}

-(void)addCodeToHistory:(NSString*)hmCode forProduct:(NSString*)productName{
    CEHistory* history = [[CEHistory alloc]init];
    history.date = [self getTodaysDate];
    history.productName = productName;
    history.hmCode = hmCode;
    CEHistoryList* list = [[CEHistoryList alloc]init];
    [list saveToPrefs:history];
}

-(NSString*)getLatitude{
    CLLocation *location =  [[LocationManager sharedLocationManager] currentLocation];
    if (location) {
        return [NSString stringWithFormat:@"%f", location.coordinate.latitude];
    }
    
    return @"0";
}

-(NSString*)getLongitude{
    CLLocation *location =  [[LocationManager sharedLocationManager] currentLocation];
    if (location) {
        return [NSString stringWithFormat:@"%f", location.coordinate.longitude];
    }
    
    return @"0";
}

-(NSString*)getAppVersion{
    if ([DeviceManager getCurrentVersionOfTheApp]) {
        return [DeviceManager getCurrentVersionOfTheApp];
    }
    return @"0";
}

-(NSString*)getTodaysDate{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MM/dd/yyyy"];
    NSDate *now = [NSDate date];
    NSString *nsstr = [format stringFromDate:now];
    return nsstr;
}

-(void) listButtonTouched {
    CEHistoryViewController* historyViewController = [[CEHistoryViewController alloc]initWithNibName:@"CEHistoryViewController" bundle:nil];
    [self.navigationController pushViewController:historyViewController animated:NO]; //push or modal??
}

-(void)emailButtonTouched {
    if(!self.errorReport)
        self.errorReport = [[ErrorReport alloc]init]; //if null then create blank
    
    NSString *emailText = [self.errorReport getEmailBody]; //need to show the exact email format
    if([[DeviceManager getDeviceID] isEqualToString:@"iOS_Simulator"]){
        NSLog(@"CodeExplorer Email: \n %@",emailText);
        return;
    }
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setSubject:[self.errorReport getEmailSubject]];
    [controller setToRecipients:[NSArray arrayWithObjects:@"driscoll-support@harvestmark.com", nil]];
    [controller setMessageBody:emailText isHTML:NO];
    NSLog(@"Debug Log Email: \n %@",emailText);
    if (controller) {
        [self presentModalViewController:controller animated:YES];
    }
}

#pragma mark - Mail delegate

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    [self dismissModalViewControllerAnimated:YES];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
