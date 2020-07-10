//
//  StarQualityViewController.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 5/3/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StarRatingQualityImageView.h"
#import "ParentNavigationViewController.h"
#import "Rating.h"
#import "ASStarRatingView.h"

@interface StarQualityViewController : ParentNavigationViewController <UIScrollViewDelegate>

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet StarRatingQualityImageView *starRatingQualityImageView;
@property (nonatomic, strong) Rating *rating;

@end
