//
//  AppDataSingletonDatabase.h
//  Insights
//
//  Created by Shyam Ashok on 10/7/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "DBManager.h"

@interface AppDataSingletonDatabase : NSObject

@property (strong, nonatomic) FMDatabase *database;
@property (nonatomic, strong) FMDatabaseQueue *databaseQueue;

+ (AppDataSingletonDatabase *) sharedAppDataSingletonDatabase;

- (void) openAppDataDatabase;
- (void) closeAppDataDatabase;

@end
