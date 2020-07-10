//
//  WebViewForDefectsViewController.m
//  Insights
//
//  Created by Vineet Pareek on 2/2/17.
//  Copyright © 2017 Yottamark. All rights reserved.
//

#import "WebViewForDefectsViewController.h"

@interface WebViewForDefectsViewController ()

@end

@implementation WebViewForDefectsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.pageTitle = @"WebviewForDefectsViewController";
    [super setupNavBar];
    [self loadWebView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadWebView {
    QualityManual *manual = self.qualityManual;
    NSString* currentDocument = manual.pdf;//pdf
    if(!currentDocument)
        currentDocument = [manual getHtmlUrl];//htm
    [self.webView setScalesPageToFit:YES];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:currentDocument]]];
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
