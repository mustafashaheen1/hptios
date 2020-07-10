//
//  OrderDataDBHelper.m
//  DC Insights
//
//  Created by Shyam Ashok on 7/28/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "OrderDataDBHelper.h"
#import "OrderDataAPI.h"

@implementation OrderDataDBHelper

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void) createAllTables {
    //create default Api Mapping tables
    NSMutableArray *createStatements = [[NSMutableArray alloc] init];
    [createStatements addObject:[OrderDataAPI getTableCreateStatmentForOrderData]];
    
    [[DBManager sharedDBManager] executeUpdateUsingFMDataBase:[createStatements copy] withDatabasePath:DB_ORDER_DATA];
}

- (void) deleteAllTables {
    NSMutableArray *deleteStatements = [[NSMutableArray alloc] init];
    [deleteStatements addObject:TBL_ORDERDATA];
    
    [[DBManager sharedDBManager] deleteTableUsingFMDataBase:[deleteStatements copy] withDatabasePath:DB_ORDER_DATA];
}


@end
