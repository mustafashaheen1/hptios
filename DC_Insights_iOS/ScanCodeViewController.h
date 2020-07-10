//
//  ScanCodeViewController.h
//  Insights
//
//  Created by Mustafa Shaheen on 7/6/20.
//  Copyright © 2020 Yottamark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParentNavigationViewController.h"
#define kScanCaseCodeViewNIBName @"ScanCodeViewController"
@interface ScanCodeViewController : ParentNavigationViewController
@property (strong, nonatomic) NSString *sscc;
@property (strong, nonatomic) NSMutableArray *caseCodes;
@property (strong, nonatomic) NSMutableArray *quantities;
@end
