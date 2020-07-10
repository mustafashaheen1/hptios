//
//  WebviewForProductViewController.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 5/21/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "WebviewForProductViewController.h"

@interface WebviewForProductViewController ()

@end

@implementation WebviewForProductViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.pageTitle = @"WebviewForProductViewController";
    [super setupNavBar];
    self.currentManualIndex = 0;
    [self updateNavigationArrows];
    [self loadWebView];
}

-(void)addLeftRightButtons{
    if([self.product.qualityManuals count] > 0)
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithCustomView:self.forwardArrow],[[UIBarButtonItem alloc] initWithCustomView:self.backArrow], nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

-(void)updateNavigationArrows {
    BOOL needForward = NO;
    BOOL needBack = NO;
    if(self.currentManualIndex==0 && [self.product.qualityManuals count]>1){
        //show forward button
        needForward = YES;
    }else if(self.currentManualIndex>0 && self.currentManualIndex+1 == [self.product.qualityManuals count]){
        needBack = YES;
    }else if(self.currentManualIndex>0 && self.currentManualIndex+1 < [self.product.qualityManuals count]){
        needForward = YES;
        needBack = YES;
    }
    
    if(needForward && needBack){
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithCustomView:self.forwardArrow],[[UIBarButtonItem alloc] initWithCustomView:self.backArrow], nil];
    }else if(needForward){
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithCustomView:self.forwardArrow], nil];
    }else if(needBack){
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithCustomView:self.backArrow], nil];

    }
}

-(void)forwardArrowTouched
{
    if(self.currentManualIndex+1 <= [self.product.qualityManuals count]){
        self.currentManualIndex++;
        [self updateNavigationArrows];
        [self loadWebView];
    }
}

-(void)backArrowTouched
{
    if(self.currentManualIndex >0){
        self.currentManualIndex--;
        [self updateNavigationArrows];
        [self loadWebView];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadWebView {
//    QualityManual *qualityManual = [[QualityManual alloc] init];
//    qualityManual.deviceUrl = [NSString stringWithFormat:@"quality_manual_%d.html", self.product.product_id];
//    NSString *htmlString = [qualityManual getFileFromDeviceUrl];
//    if (htmlString) {
//        [self.webview loadHTMLString:htmlString baseURL:nil];
//    }
    QualityManual *manual = [self.product.qualityManuals objectAtIndex:self.currentManualIndex];
    //NSString* currentDocument = manual.document;//pdf
    NSString* currentDocument = manual.pdf;//pdf
    if(!currentDocument)
            currentDocument = [manual getHtmlUrl];//html
    [self.webview setScalesPageToFit:YES];
    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:currentDocument]]];
}



@end
