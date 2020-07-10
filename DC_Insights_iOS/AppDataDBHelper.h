//
//  AppDataDBHelper.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/31/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppDataDBHelper : NSObject

- (void) createAllTables;
- (void) deleteAllTables;
- (void) createTablesForSavedAudits;

@end
