//
//  AppLaunchFlow.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 4/18/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "AppLaunchFlow.h"
#import "User.h"
#import "LocationManager.h"
#import "SyncManager.h"
#import "AppDataDBHelper.h"
#import "AuditsDBHelper.h"

@implementation AppLaunchFlow

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        [self createAllTheTables];
    }
    return self;
}

- (void) createAllTheTables {
    AppDataDBHelper *appHelper = [[AppDataDBHelper alloc] init];
    //[appHelper deleteAllTables];
    [appHelper createAllTables];
    AuditsDBHelper *auditHelper = [[AuditsDBHelper alloc] init];
    [auditHelper createAllTables];
}

- (void) startLaunchFlow {
    BOOL isUserLogged = [self isUserLoggedIn];
    if (isUserLogged) {
        [self setCurrentLocationToUser];
        NSLog(@"isusrlogeedd");
    }
}

- (BOOL) isUserLoggedIn {
    BOOL loggedIn = NO;
    [[User sharedUser] setEmail: [NSUserDefaultsManager getObjectFromUserDeafults:@"email"]];
    [[User sharedUser] setAccessToken: [NSUserDefaultsManager getObjectFromUserDeafults:@"accessToken"]];
    if (![[[User sharedUser] accessToken] isEqualToString:@""] && [[User sharedUser] accessToken]) {
        [self initializeAllOtherInfo];
        [self setCurrentLocationToUser];
        loggedIn = YES;
    }
    return loggedIn;
}

- (BOOL) initializeAllOtherInfo {
    [[User sharedUser] findStoreFromStoreIdAndSetToCurrentStore:[NSUserDefaultsManager getObjectFromUserDeafults:STOREID]];
    return YES;
}

- (BOOL) findIfUserSyncedRecently {
    BOOL hasUserSyncedRecently = NO;
    if ([NSUserDefaultsManager getObjectFromUserDeafults:LASTSYNCDATE]) {
        hasUserSyncedRecently = YES;
    }
    if (![NSUserDefaultsManager getBOOLFromUserDeafults:SYNCSUCCESS]) {
        hasUserSyncedRecently = NO;
    }
    return hasUserSyncedRecently;
}

- (void) setCurrentLocationToUser {
    [[LocationManager sharedLocationManager] retrieveCurrentLocationOnlyIfNotAlreadySet];
}

-(void)enableDefaultsAtStartup
{
    //enable incremental sync by default
    id incrSync = [[NSUserDefaults standardUserDefaults] objectForKey:enableIncrementalSync];
    
    if(!incrSync){
        [NSUserDefaultsManager saveBOOLToUserDefaults:YES withKey:enableIncrementalSync];
    }
    
    //enable background sync by default
    id bkgUpload = [[NSUserDefaults standardUserDefaults] objectForKey:BACKGROUND_UPLOAD_ENABLED];
    
    if(!bkgUpload){
        [NSUserDefaultsManager saveBOOLToUserDefaults:YES withKey:BACKGROUND_UPLOAD_ENABLED];
    }
}


@end
