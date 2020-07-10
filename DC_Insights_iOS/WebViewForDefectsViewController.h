//
//  WebViewForDefectsViewController.h
//  Insights
//
//  Created by Vineet Pareek on 2/2/17.
//  Copyright © 2017 Yottamark. All rights reserved.
//

#import "ParentNavigationViewController.h"
#import "QualityManual.h"

@interface WebViewForDefectsViewController : ParentNavigationViewController
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, strong) QualityManual *qualityManual;

@end
