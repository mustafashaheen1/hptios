//
//  FlaggedMessage.m
//  Insights
//
//  Created by Vineet on 10/23/17.
//  Copyright © 2017 Yottamark. All rights reserved.
//

#import "FlaggedMessage.h"
#import "WatchedProductMessage.h"

#define DEFAULT_ROW_HEIGHT 20
#define HEIGHT_WEBVIEW 200

#define MESSAGE_TYPE_TEXT @"text"
#define MESSAGE_TYPE_HTML @"html"

@implementation FlaggedMessage

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initView];
    }
    return self;
}

-(void) initView {
    [[NSBundle mainBundle] loadNibNamed:@"FlaggedMessage" owner:self options:nil];
    
    [self addSubview:self.mainview];
    self.mainview.frame = self.bounds;
    self.label.textAlignment= NSTextAlignmentCenter;
    self.flaggedMessageTableView.allowsSelection = NO;
    self.flaggedMessageTableView.delegate = self;
    self.flaggedMessageTableView.dataSource = self;
    
}

-(void)showAgain
{
    [self.flaggedMessageTableView flashScrollIndicators];
}
-(void)parseRawMessages {
    self.messageObjectArray = [[NSMutableArray alloc]init];
    for(NSString* message in self.flaggedMessages){
        NSError *error;
        WatchedProductMessage *watchedMessage = [[WatchedProductMessage alloc] initWithDictionary:message error:&error];
        [self.messageObjectArray addObject:watchedMessage];
    }
}

-(int)getHeightForContent {
    int height = DEFAULT_ROW_HEIGHT;
    for(WatchedProductMessage *message in self.messageObjectArray){
        if([message.type isEqualToString:MESSAGE_TYPE_TEXT])
            height+=DEFAULT_ROW_HEIGHT;
        else if([message.type isEqualToString:MESSAGE_TYPE_HTML])
            height+=HEIGHT_WEBVIEW;
    }
    return height;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //the message could be in different formats (linear, tabular with tabs, very long)
    WatchedProductMessage *message = [self.messageObjectArray objectAtIndex:indexPath.row];
    if([message.type isEqualToString:MESSAGE_TYPE_TEXT]){
        int lines = [self getNumberOfLinesforMessage:message.value];
        return DEFAULT_ROW_HEIGHT*lines;
    }else if([message.type isEqualToString:MESSAGE_TYPE_HTML]){
        return HEIGHT_WEBVIEW;
    }
    return DEFAULT_ROW_HEIGHT;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.messageObjectArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(showAgain) userInfo:nil repeats:YES];
    static NSString *CellIdentifier = @"SKSTableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    //if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    //}
   /* NSString *message = [self.flaggedMessages objectAtIndex:indexPath.row];
    cell.textLabel.text = message;
 //   cell.textLabel.numberOfLines = 2;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0];
    */
    cell = [self getMessageForCell:cell withRow:indexPath.row];
    return cell;
}

-(int) getNumberOfLinesforMessage:(NSString*)text {
    NSRange isRange = [text rangeOfString:@"\t" options:NSCaseInsensitiveSearch];
    BOOL isContainTabs = NO;
    if(isRange.location != NSNotFound) {
        isContainTabs = YES;
    }
    if(isContainTabs){
        //DI-2922 - assuming that if the message contains tabs, its in a tabular format
        text = [text stringByReplacingOccurrencesOfString:@"\t" withString:@""];
        text = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    int lines = (int)[self numberOfLinesForQuestion:text];
    return lines;
}

- (NSInteger)numberOfLinesForQuestion:(NSString*)text {
    NSString *theQuestionText = text;
    
    CGSize baselineSize;
    baselineSize = [@"DCInsights" sizeWithFont:[UIFont fontWithName:@"Helvetica" size:14.0] constrainedToSize:CGSizeMake(250.0, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    
    CGSize theQuestionSize;
    theQuestionSize = [theQuestionText sizeWithFont:[UIFont fontWithName:@"Helvetica" size:14.0] constrainedToSize:CGSizeMake(250.0, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    
    NSInteger numberOfLines = (theQuestionSize.height / baselineSize.height);
    return numberOfLines;
}

- (IBAction)okButton:(id)sender {
    [self removeFromSuperview];
}

-(UITableViewCell*) getMessageForCell:(UITableViewCell*)cell withRow:(int)row {
    
    WatchedProductMessage *watchedMessage =[self.messageObjectArray objectAtIndex:row];
    if([watchedMessage.type isEqualToString:MESSAGE_TYPE_HTML]){
        NSString* url = watchedMessage.value;
        UIWebView* webview = [self getWebViewForUrl:(NSString*)url];
        [cell addSubview:webview];
    }else if([watchedMessage.type isEqualToString:MESSAGE_TYPE_TEXT]){
        cell.textLabel.text = watchedMessage.value;
        //   cell.textLabel.numberOfLines = 2;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0];
    }
    return cell;
}

#pragma WebView

-(UIWebView*) getWebViewForUrl:(NSString*)relativeUrl {
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 2, self.bounds.size.width-10, HEIGHT_WEBVIEW)];
    webView.scrollView.bounces = NO;
    webView.scalesPageToFit = YES;
    webView.delegate = self;
    NSString* endpoint = [NSUserDefaultsManager getObjectFromUserDeafults:PORTAL_ENDPOINT];
    // NSString* url = [NSString stringWithFormat:@"%@/%@",endpoint,defect.html_description_source];
    //NSString* url = @"http://www.yahoo.com";
    NSString *url = [NSString stringWithFormat:@"%@%@.html?auth_token=%@&device_id=%@", endpoint, relativeUrl, [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"], [DeviceManager getDeviceID]];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    return webView;
}

-(void)showLoading {
    /*UIWindow *win = [[UIApplication sharedApplication] keyWindow];
     self.syncOverlayView = [[SyncOverlayView alloc] initWithFrame:CGRectMake(0, 0, win.bounds.size.width, win.bounds.size.height)];
     self.syncOverlayView.headingTitleLabel.text = @"Loading...";
     [self.syncOverlayView showActivityView];*/
    [self initSyncOverlayView];
    [self.syncOverlayView showActivityView];
    UIWindow *win = [[UIApplication sharedApplication] keyWindow];
    [win addSubview:self.syncOverlayView];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    //[self.syncOverlayView removeFromSuperview];//hide if already showing
    if(![self isLoadingVisible])
    [self showLoading];
}

-(void) hideLoadingScreen {
    [self.syncOverlayView removeFromSuperview];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self hideLoadingScreen];
}

-(void) initSyncOverlayView {
    if(!self.syncOverlayView){
        UIWindow *win = [[UIApplication sharedApplication] keyWindow];
        self.syncOverlayView = [[SyncOverlayView alloc] initWithFrame:CGRectMake(0, 0, win.bounds.size.width, win.bounds.size.height)];
        self.syncOverlayView.headingTitleLabel.text = @"Loading...";
    }
}

-(BOOL) isLoadingVisible {
    UIWindow *win = [[UIApplication sharedApplication] keyWindow];
    NSArray* views = win.subviews;
    for(UIView *view in views){
        if([view isKindOfClass:[SyncOverlayView class]]){
            return YES;
        }
    }
    return NO;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
