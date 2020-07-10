//
//  CollabBackgroundUpload.h
//  Insights
//
//  Created by Vineet on 12/4/17.
//  Copyright © 2017 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CollabBackgroundUpload : NSObject


@property (nonatomic) UIBackgroundTaskIdentifier bgTask;
@property BOOL isUploadInProgress;
@property NSTimer *timer;

-(void)startUpload;
-(BOOL)isBackgroundUploadInProgress;
-(void) startBackgroundTimer;
-(void) stopBackgroundTimer;


@end
