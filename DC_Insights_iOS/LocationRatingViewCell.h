//
//  LocationRatingViewCell.h
//  Insights
//
//  Created by Mustafa Shaheen on 7/1/20.
//  Copyright © 2020 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseTableViewCell.h"
#import "UIPopoverListView.h"
#import "SyncOverlayView.h"
#import "RowSectionButton.h"

@protocol LocationRatingCellDelegate <NSObject>
- (void) refreshTheView;
@end
#define kLocationRatingViewCellReuseID @"LocationRatingViewCell"
#define kLocationRatingViewCellNIBFile @"LocationRatingViewCell"
@interface LocationRatingViewCell : BaseTableViewCell <UIPopoverListViewDelegate, UIPopoverListViewDataSource, ScannerProtocol>
@property (weak, nonatomic) IBOutlet UIButton *selectOptionButton;
@property (weak, nonatomic) IBOutlet UILabel *selectLabel;
@property (retain, nonatomic) NSMutableArray *comboItems;
@property (retain, nonatomic) NSMutableArray *comboItemsGlobal;
@property (retain, nonatomic) UIPopoverListView *poplistview;
@property (nonatomic, weak) id <LocationRatingCellDelegate> delegate;
@property (retain, nonatomic) SyncOverlayView *syncOverlayView;
@end
