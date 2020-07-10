//
//  DBManager.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/7/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "DBManager.h"
#import <sqlite3.h>
#import "Container.h"

static DBManager *_sharedDBManager = nil;
static sqlite3 *database = nil;
static sqlite3_stmt *statement = nil;

// destroys sharedInstance after main exits.. REQUIRED for unit tests
// to work correclty, otherwse the FIRST shared object gets used for ALL
// tests, resulting in KVO problems
__attribute__((destructor)) static void destroy_singleton() {
	@autoreleasepool {
		_sharedDBManager = nil;
	}
}

@implementation DBManager

@synthesize databasePath;

#pragma mark - Class Access Method

/*------------------------------------------------------------------------------
 METHOD: sharedDBManager
 
 PURPOSE:
 Gets the shared DBManager instance object and creates it if
 necessary.
 
 RETURN VALUE:
 The shared DBManager.
 
 -----------------------------------------------------------------------------*/
+ (DBManager*) sharedDBManager
{
	if (_sharedDBManager == nil)
		[DBManager initialize] ;
	
	return _sharedDBManager ;
}

/*------------------------------------------------------------------------------
 Singleton Methods.. Generic to any Singleton
 -----------------------------------------------------------------------------*/
#pragma mark - Singleton Methods

+ (void)initialize
{
    if (_sharedDBManager == nil)
        _sharedDBManager = [[self alloc] init];
}


+ (id)sharedUserNetworkActivityView
{
    //Already set by +initialize.
    return _sharedDBManager;
}

/* DB Functions */

-(NSString *) getTableCreateStatment{
    NSString *sql =[NSString stringWithFormat:@"CREATE TABLE  %@", TBL_CONTAINERS];
    sql = [sql stringByAppendingString:@" ("];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_ID,SQLITE_TYPE_INTEGER];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_PROGRAM_ID,SQLITE_TYPE_INTEGER];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_PARENT_ID,SQLITE_TYPE_INTEGER];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_NAME,SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@",COL_PIC_REQUIRED,SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingString:@")"];
    return sql;
}


-(BOOL) createDB{
    NSArray *dirPaths;
    NSString *docsDir;
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    // Build the path to the database file
    //databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent: DB_INSIGHTS_DATA]];
    BOOL isSuccess = YES;
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath: databasePath ] == NO)
    {
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK)
        {
            char *errMsg;
            NSString *sqlCreateStatement = [self getTableCreateStatment];
            const char *sql_stmt = [sqlCreateStatement UTF8String];
            if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg)
                != SQLITE_OK)
            {
                isSuccess = NO;
                NSLog(@"Failed to create table");
            }
            sqlite3_close(database);
            return  isSuccess;
        }
        else {
            isSuccess = NO;
            NSLog(@"Failed to open/create database");
        }
    }
    return isSuccess;
}


-(BOOL)createAllRows: (NSMutableArray*)allContainers {
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
    for (int i=0; i<[allContainers count]; i++) {
        Container *container = [allContainers objectAtIndex:i];
        //build the string
        NSString *sql =[NSString stringWithFormat:@"INSERT INTO %@", TBL_CONTAINERS];
        sql = [sql stringByAppendingString:@" ("];
        sql = [sql stringByAppendingFormat:@"%@,%@,%@,%@,%@",COL_ID,COL_PROGRAM_ID,COL_PARENT_ID,COL_NAME,COL_PIC_REQUIRED];
        sql = [sql stringByAppendingString:@") "];
        sql = [sql stringByAppendingString:@"VALUES ("];
        sql = [sql stringByAppendingString:@");"];
        const char *insert_stmt = [sql UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        char *errMsg;
        sqlite3_exec(database, insert_stmt, NULL, NULL, &errMsg);
        /*if (sqlite3_step(statement) == SQLITE_DONE) {
         return YES;
         } else {
         return NO;
         }*/
        sqlite3_reset(statement);
        }
    }
    
    /*NSString *dbPath = [[[NSBundle mainBundle] resourcePath ]stringByAppendingPathComponent:@"movieData.sqlite"];
    const char *dbpath = [dbPath UTF8String];
    sqlite3 *contactDB;
    
    sqlite3_stmt    *statement;
    
    NSLog(@"%@",dbPath);
    if (sqlite3_open(dbpath, &contactDB) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat: @"INSERT INTO myMovies (movieName) VALUES (\"%@\")", txt];
        
        const char *insert_stmt = [insertSQL UTF8String];
        
        sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            sqlite3_bind_text(statement, 1, [txt UTF8String], -1, SQLITE_TRANSIENT);
        } else {
            NSLog(@"error");
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
     }*/
    return false;
}

/*------------------------------------------------------------------------------
 METHOD: Create Path For Database
 -----------------------------------------------------------------------------*/

- (FMDatabase *)openDatabase: (NSString *) databasePathLocal {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *documents_dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *db_path = [documents_dir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db", databasePathLocal]];
    NSString *template_path = [[NSBundle mainBundle] pathForResource:databasePathLocal ofType:@"db"];
    
    if (![fm fileExistsAtPath:db_path])
        [fm copyItemAtPath:template_path toPath:db_path error:nil];
    FMDatabase *db = [FMDatabase databaseWithPath:db_path];
    if (![db open])
        NSLog(@"Failed to open database!");
    return db;
}

- (NSString *) getDBPath: (NSString *) databasePathLocal {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *documents_dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *db_path = [documents_dir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db", databasePathLocal]];
    NSString *template_path = [[NSBundle mainBundle] pathForResource:databasePathLocal ofType:@"db"];
    if (![fm fileExistsAtPath:db_path])
        [fm copyItemAtPath:template_path toPath:db_path error:nil];
    return db_path;
}

- (FMDatabase *)fileExistsAtPathLocal: (NSString *) databasePathLocal {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *documents_dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *db_path = [documents_dir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db", databasePathLocal]];
    NSString *template_path = [[NSBundle mainBundle] pathForResource:databasePathLocal ofType:@"db"];
    
    if (![fm fileExistsAtPath:db_path])
        [fm copyItemAtPath:template_path toPath:db_path error:nil];
    FMDatabase *db = [FMDatabase databaseWithPath:db_path];
    return db;
}

/*------------------------------------------------------------------------------
 METHOD: createDataBase
 -----------------------------------------------------------------------------*/

- (BOOL) createDataBase: (NSString *) databasePathLocal {
    BOOL opened = NO;
    FMDatabase *db = [self openDatabase:databasePathLocal];
    NSLog(@"db %@", db);
    opened = [db open];
    return opened;
}

/*------------------------------------------------------------------------------
 METHOD: Execute Update For Database
 -----------------------------------------------------------------------------*/

- (void) executeUpdateUsingFMDataBase: (NSArray *) updateStatements withDatabasePath: (NSString *) databasePathLocal {
    FMDatabase *database = [self openDatabase:databasePathLocal];
    [database open];
    for (int i = 0; i < [updateStatements count]; i++) {
        [database executeUpdate:[updateStatements objectAtIndex:i]];
    }
    [database close];
}

/*------------------------------------------------------------------------------
 METHOD: Execute Update For Database
 -----------------------------------------------------------------------------*/

- (void) deleteTableUsingFMDataBase: (NSArray *) deleteStatements withDatabasePath: (NSString *) databasePathLocal {
    FMDatabase *database = [self openDatabase:databasePathLocal];
    [database open];
    for (int i = 0; i < [deleteStatements count]; i++) {
        [database executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", [deleteStatements objectAtIndex:i]]];
    }
    [database close];
}

/*------------------------------------------------------------------------------
 METHOD: Insert Data In to Table
 -----------------------------------------------------------------------------*/

- (void) insertDataInToTableUsingFMDataBase: (NSArray *) insertStatements withDatabasePath: (NSString *) databasePathLocal {
//    __block FMDatabase *database = [self openDatabase:databasePathLocal];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
//                                             (unsigned long)NULL), ^(void) {
//        [database open];
//        BOOL success = NO;
//        for (int i = 0; i < [insertStatements count]; i++) {
//            success = [database executeUpdate:[insertStatements objectAtIndex:i]];
//        }
//        NSLog(@"sucess %d", success);
//        [database close];
//    });
    FMDatabase *database = [self openDatabase:databasePathLocal];
    [database open];
    BOOL success = NO;
    for (int i = 0; i < [insertStatements count]; i++) {
        success = [database executeUpdate:[insertStatements objectAtIndex:i]];
    }
    NSLog(@"success %d", success);
    [database close];
}

/*------------------------------------------------------------------------------
 METHOD: Retrieve Data From the Table
 -----------------------------------------------------------------------------*/

- (FMResultSet *) retrieveDataFromTheTableUsingFMDataBase: (NSString *) retrieveStatement withDatabasePath: (NSString *) databasePathLocal {
    FMDatabase *database = [self openDatabase:databasePathLocal];
    FMResultSet *results;
    [database open];
    if (retrieveStatement) {
        results = [database executeQuery:retrieveStatement];
    }
    [database close];
    return results;
}

/*------------------------------------------------------------------------------
 METHOD: Build Inner Join Query
 -----------------------------------------------------------------------------*/

- (NSString *) buildInnerJoinQuery: (NSArray *) selectColumns withTables:(NSArray *) tables withJoinCriteria:(NSArray *) joinCriteria andWhereClause: (NSString *) whereClause {
    NSString *queryString = @"";
    if ([[selectColumns objectAtIndex:0] isEqualToString:@""]) {
        queryString = [queryString stringByAppendingString:@"SELECT *"];
    } else {
        queryString = [queryString stringByAppendingString:@"SELECT *"];
    }
    queryString = [queryString stringByAppendingString:[NSString stringWithFormat:@" FROM %@", [tables objectAtIndex:0]]];
    queryString = [queryString stringByAppendingString:[NSString stringWithFormat:@" INNER JOIN %@", [tables objectAtIndex:1]]];
    queryString = [queryString stringByAppendingString:[NSString stringWithFormat:@" ON %@=%@", [joinCriteria objectAtIndex:0], [joinCriteria objectAtIndex:1]]];
    queryString = [queryString stringByAppendingString:[NSString stringWithFormat:@" WHERE %@", whereClause]];
    return queryString;
}

/*------------------------------------------------------------------------------
 METHOD: Build Left Join Query
 -----------------------------------------------------------------------------*/

- (NSString *) buildLeftJoinQuery: (NSArray *) selectColumns withTables:(NSArray *) tables withJoinCriteria:(NSArray *) joinCriteria andWhereClause: (NSString *) whereClause {
    NSString *queryString = @"";
    if ([[selectColumns objectAtIndex:0] isEqualToString:@""]) {
        queryString = [queryString stringByAppendingString:@"SELECT *"];
    } else {
        queryString = [queryString stringByAppendingString:@"SELECT *"];
    }
    queryString = [queryString stringByAppendingString:[NSString stringWithFormat:@" FROM %@", [tables objectAtIndex:0]]];
    queryString = [queryString stringByAppendingString:[NSString stringWithFormat:@" LEFT JOIN %@", [tables objectAtIndex:1]]];
    queryString = [queryString stringByAppendingString:[NSString stringWithFormat:@" ON %@=%@", [joinCriteria objectAtIndex:0], [joinCriteria objectAtIndex:1]]];
    if (whereClause)
        queryString = [queryString stringByAppendingString:[NSString stringWithFormat:@" WHERE %@", whereClause]];
    return queryString;
}

@end
