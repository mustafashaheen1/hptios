//
//  VerticalGalleryViewController.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 5/20/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParentNavigationViewController.h"

@interface VerticalGalleryViewController : ParentNavigationViewController <UIScrollViewDelegate,UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *imagesArray;
@property (nonatomic, strong) NSMutableArray *rawImagesArray;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, assign) int deleteTouchedIndex;
@property (nonatomic, assign) BOOL productView;
@property (nonatomic, assign) BOOL positionChanged;

- (void) addContentsToScrollView;

@end
