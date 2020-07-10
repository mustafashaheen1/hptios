//
//  DefectsTableViewCell.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 5/21/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Defect.h"
#import "Image.h"
#import "SyncOverlayView.h"

@interface DefectsTableViewCell : UITableViewCell <UITableViewDataSource, UITableViewDelegate,UIWebViewDelegate>

@property (nonatomic, strong) Defect *defect;
@property (nonatomic, strong) Image *image;
@property (nonatomic, assign) int heightForCell;
@property (nonatomic, strong) UILabel *descripionLabel;
@property (nonatomic, strong) UIImageView *imageViewGlobal;
@property (nonatomic, strong) SyncOverlayView *syncOverlayView;

- (int) calculateHeightForTheInspectionDefectCell;

@end
