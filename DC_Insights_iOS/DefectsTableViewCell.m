//
//  DefectsTableViewCell.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 5/21/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "DefectsTableViewCell.h"

#define heightForLabel 120
#define heightForImage 213
#define widthForImageAndLabel 280

#define HEIGHT_WEBVIEW 420


@implementation DefectsTableViewCell

@synthesize defect;
@synthesize descripionLabel;

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        //self.frame = CGRectMake(0, 0, 300, 50);
        UITableView *subMenuTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        subMenuTableView.tag = 100;
        subMenuTableView.delegate = self;
        subMenuTableView.dataSource = self;
        subMenuTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        subMenuTableView.bounces = NO;
        [self addSubview:subMenuTableView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculateHeightForTheInspectionDefectCell];
    UITableView *subMenuTableView =(UITableView *) [self viewWithTag:100];
    subMenuTableView.scrollEnabled = NO;
    subMenuTableView.alwaysBounceVertical = NO;
    [subMenuTableView reloadData];
    subMenuTableView.frame = CGRectMake(0.2, 0.3, self.bounds.size.width-5,    self.bounds.size.height-5);//set the frames for tableview
}

- (int) calculateHeightForTheInspectionDefectCell {
    self.heightForCell = heightForLabel + 30;
    Image *imageLocal = [defect returnImageIfThereIsOne];
    UIImage *imageForView = [imageLocal getImageFromDeviceUrl];
    if (imageForView) {
        self.image = imageLocal;
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
        {
            self.heightForCell = self.heightForCell + 280 + 20;
        } else {
            CGFloat width = imageForView.size.width;
            CGFloat height = imageForView.size.height;
            if (width == height) {
                self.heightForCell = self.heightForCell + widthForImageAndLabel + 20;
            } else {
                self.heightForCell = self.heightForCell + heightForImage + 20;
            }
        }
    }
    if(defect.enable_html_description)
        self.heightForCell = HEIGHT_WEBVIEW;
    return self.heightForCell;
}

//manage datasource and  delegate for submenu tableview
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int numberOfSections = 1;
    return numberOfSections;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cellID"];
    }
    
    if(defect.enable_html_description){
        UIWebView* webview = [self getWebView];
        [cell addSubview:webview];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return cell;
    }
    Image *imageLocal = [defect returnImageIfThereIsOne];
    UIImage *imageForView = [imageLocal getImageFromDeviceUrl];
    
    if (!self.imageViewGlobal)
        self.imageViewGlobal = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, widthForImageAndLabel, heightForImage)];
    self.imageViewGlobal.contentMode = UIViewContentModeScaleAspectFit;
    CGFloat width = imageForView.size.width;
    CGFloat height = imageForView.size.height;
    if (width == height) {
        self.imageViewGlobal.frame = CGRectMake(20, 20, widthForImageAndLabel, widthForImageAndLabel);
    }
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        self.imageViewGlobal.frame = CGRectMake(self.frame.size.width/2 - 150, 20, widthForImageAndLabel, 280);
    }
    
    [self.imageViewGlobal setImage:imageForView];
    if (imageForView) {
        [cell addSubview:self.imageViewGlobal];
    }
    
    if (!self.descripionLabel)
        descripionLabel = [[UILabel alloc] init];
    descripionLabel.frame = CGRectMake(20, 20 + heightForImage + 2, widthForImageAndLabel, heightForLabel);
    if (width == height) {
        descripionLabel.frame = CGRectMake(20, 20 + widthForImageAndLabel + 2, widthForImageAndLabel, heightForLabel);
    }
    if (!imageForView) {
        descripionLabel.frame = CGRectMake(20, 20, widthForImageAndLabel, heightForLabel);
    }
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        descripionLabel.frame = CGRectMake(20, 20 + 280 + 2, self.frame.size.width - 50, heightForLabel);
        if (!imageForView) {
            descripionLabel.frame = CGRectMake(20, 20, self.frame.size.width - 50, heightForLabel);
        }
    }
    
    descripionLabel.text = @"No Description";
    if (![self.defect.description isEqualToString:@""]) {
        descripionLabel.text = self.defect.description;
    }
    descripionLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    descripionLabel.textAlignment = NSTextAlignmentCenter;
    descripionLabel.layer.borderWidth = 1.0;
    descripionLabel.numberOfLines = 0;
    descripionLabel.layer.borderColor = [[UIColor blackColor] CGColor];
    [cell addSubview:descripionLabel];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.heightForCell;
}

-(UIWebView*) getWebView {
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 2, self.bounds.size.width, HEIGHT_WEBVIEW)];
    webView.scrollView.bounces = NO;
    webView.scalesPageToFit = YES;
    webView.delegate = self;
    NSString* endpoint = [NSUserDefaultsManager getObjectFromUserDeafults:PORTAL_ENDPOINT];
    // NSString* url = [NSString stringWithFormat:@"%@/%@",endpoint,defect.html_description_source];
    //NSString* url = @"http://www.yahoo.com";
    NSString *url = [NSString stringWithFormat:@"%@%@.html?auth_token=%@&device_id=%@", endpoint, self.defect.html_description_source, [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"], [DeviceManager getDeviceID]];
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

@end

