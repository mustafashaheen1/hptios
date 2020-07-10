//
//  BackgroundUpload.h
//  Insights
//
//  Created by Vineet Pareek on 23/5/17.
//  Copyright © 2017 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SyncManager.h"


@interface BackgroundUpload : NSObject<SyncManagerDelegate>

@property (nonatomic) UIBackgroundTaskIdentifier bgTask;
@property SyncManager* syncManager;
@property BOOL isUploadInProgress;
@property NSTimer *timer;


-(void)startBackgroundUpload;
-(BOOL)isBackgroundUploadInProgress;
-(void) startBackgroundTimer;
-(void) stopBackgroundTimer;

@end
