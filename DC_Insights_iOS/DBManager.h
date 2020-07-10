//
//  DBManager.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/7/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBConstants.h"
#import "FMDatabase.h"

@interface DBManager : NSObject {
    NSString *databasePath;
}

@property (nonatomic, strong) NSString *databasePath;

+ (DBManager*) sharedDBManager;
- (BOOL) createDB;
- (BOOL) createDataBase: (NSString *) databasePathGlobal;
- (BOOL) createAllRows: (NSMutableArray*)allContainers;
- (void) executeUpdateUsingFMDataBase: (NSArray *) updateStatements withDatabasePath: (NSString *) databasePathLocal;
- (void) deleteTableUsingFMDataBase: (NSArray *) deleteStatements withDatabasePath: (NSString *) databasePathLocal;
- (void) insertDataInToTableUsingFMDataBase: (NSArray *) insertStatements withDatabasePath: (NSString *) databasePathLocal;
- (FMResultSet *) retrieveDataFromTheTableUsingFMDataBase: (NSString *) retrieveStatement withDatabasePath: (NSString *) databasePathLocal;
- (FMDatabase *)openDatabase: (NSString *) databasePathLocal;
- (NSString *) buildInnerJoinQuery: (NSArray *) selectColumns withTables:(NSArray *) tables withJoinCriteria:(NSArray *) joinCriteria andWhereClause: (NSString *) whereClause;
- (NSString *) buildLeftJoinQuery: (NSArray *) selectColumns withTables:(NSArray *) tables withJoinCriteria:(NSArray *) joinCriteria andWhereClause: (NSString *) whereClause;
- (FMDatabase *)fileExistsAtPathLocal: (NSString *) databasePathLocal;
- (NSString *) getDBPath: (NSString *) databasePathLocal;

@end
