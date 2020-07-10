//
//  AppLaunchFlow.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 4/18/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SyncOverlayView.h"
#import "SyncManager.h"

@protocol AppLaunchFlowDelegate <NSObject>
@required
- (void) downloadSyncDone: (BOOL)success;
@end

@interface AppLaunchFlow : NSObject<SyncManagerDelegate>

@property (retain) id <AppLaunchFlowDelegate> delegate;

- (void) startLaunchFlow;
- (void) setCurrentLocationToUser;
- (BOOL) isUserLoggedIn;
- (BOOL) findIfUserSyncedRecently;
-(void) enableDefaultsAtStartup;

@end
