//
//  OrderDataAPI.h
//  DC Insights
//
//  Created by Shyam Ashok on 7/23/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "DCBaseEntity.h"
#import "SyncOverlayView.h"

@interface OrderDataAPI : DCBaseEntity

@property (nonatomic, assign) int totalNumberOfPagesToBeDownloaded;
@property (nonatomic, assign) int totalNumberOfData;
@property (nonatomic, strong) NSMutableArray *jsonOrderDataPages;
@property (nonatomic, strong) SyncOverlayView *syncOverlayViewGlobal;
@property (nonatomic, strong) NSString *timeSet;

+ (NSString *) getTableCreateStatmentForOrderData;
- (void)orderDataCallWithBlock:(void (^)(BOOL isSuccess, NSArray *array, NSError *error))block withSyncOverlayView:(SyncOverlayView *) syncOverlayView;

- (void)orderDataCallwithAllTheBlocks:(void (^)(BOOL isSuccess, NSArray *array, NSError *error))block withSyncOverlayView:(SyncOverlayView *) syncOverlayView;
@end
