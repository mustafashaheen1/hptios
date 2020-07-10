//
//  WebviewForProductViewController.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 5/21/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Product.h"
#import "ParentNavigationViewController.h"

@interface WebviewForProductViewController : ParentNavigationViewController

@property (weak, nonatomic) IBOutlet UIWebView *webview;
@property (strong, nonatomic) Product *product;
@property int currentManualIndex;

@end
