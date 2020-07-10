//
//  MasterProductRatingManager.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/17/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProductRatingViewController.h"

@interface MasterProductRatingManager : NSObject <ProductRatingViewControllerDelegate>

@property (retain, nonatomic) UINavigationController *navigationController;
@property (retain, nonatomic) NSArray *containers;
@property (retain, nonatomic) NSArray *orderDataArray;
- (void) navigateNow;

@end
