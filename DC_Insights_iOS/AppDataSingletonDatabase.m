//
//  AppDataSingletonDatabase.m
//  Insights
//
//  Created by Shyam Ashok on 10/7/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "AppDataSingletonDatabase.h"

@implementation AppDataSingletonDatabase

@synthesize database;
@synthesize databaseQueue;

static AppDataSingletonDatabase *_sharedAppDataSingletonDatabase = nil;

__attribute__((destructor)) static void destroy_singleton() {
    @autoreleasepool {
        _sharedAppDataSingletonDatabase = nil;
    }
}

/*------------------------------------------------------------------------------
 METHOD: sharedUser
 
 PURPOSE:
 Gets the shared User instance object and creates it if
 necessary.
 
 RETURN VALUE:
 The shared User.
 
 -----------------------------------------------------------------------------*/
+ (AppDataSingletonDatabase *) sharedAppDataSingletonDatabase
{
    if (_sharedAppDataSingletonDatabase == nil)
        [AppDataSingletonDatabase initialize] ;
    
    return _sharedAppDataSingletonDatabase ;
}

/*------------------------------------------------------------------------------
 Singleton Methods.. Generic to any Singleton
 -----------------------------------------------------------------------------*/
#pragma mark - Singleton Methods

+ (void)initialize
{
    if (_sharedAppDataSingletonDatabase == nil)
        _sharedAppDataSingletonDatabase = [[self alloc] init];
}

- (void) openAppDataDatabase {
    database = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
    [database open];
}

- (void) closeAppDataDatabase {
    [database close];
}

- (id) init {
    self = [super init];
    if (self) {
        databaseQueue = [[FMDatabaseQueue alloc] initWithPath:[[DBManager sharedDBManager] getDBPath:DB_APP_DATA]];
    }
    return self;
}

@end
