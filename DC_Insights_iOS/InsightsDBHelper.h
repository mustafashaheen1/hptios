//
//  InsightsDBHelper.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/25/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InsightsDBHelper : NSObject

- (void) createAllTables;
- (void) deleteAllTables;
- (void) testInsertValues;

@end
