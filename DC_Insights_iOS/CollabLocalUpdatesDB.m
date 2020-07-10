//
//  CollabLocalUpdatesDB.m
//  Insights
//
//  Created by Vineet on 11/16/17.
//  Copyright © 2017 Yottamark. All rights reserved.
//

#import "CollabLocalUpdatesDB.h"
#import "DCBaseEntity.h"
#import "User.h"

@implementation CollabLocalUpdatesDB

+ (NSString *) getTableCreateStatment {
    NSString *sql =[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@", TBL_COLLABORATIVE_LOCAL_UPDATES];
    sql = [sql stringByAppendingString:@" ("];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_DATE_SUBMITTED, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@ %@,",COL_PRODUCT_ID, SQLITE_TYPE_TEXT ,SQLITE_TYPE_PRIMARY_KEY];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_INSPECTION_STATUS, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@",COL_ORDER_PO_NUMBER, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingString:@")"];
    return sql;
}

-(void)saveStatus:(int)status forProduct:(int)productId inPO:(NSString*)poNumber {
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
    [database open];
     NSString *queryForUpdate = [NSString stringWithFormat:@"INSERT OR REPLACE into %@ (%@,%@,%@,%@) values ('%@','%@',%@,%@)",
                               TBL_COLLABORATIVE_LOCAL_UPDATES,
                               COL_DATE_SUBMITTED,COL_ORDER_PO_NUMBER,COL_PRODUCT_ID,COL_INSPECTION_STATUS,
                               [DeviceManager getCurrentTimeString],poNumber,[NSNumber numberWithInteger:productId],[NSNumber numberWithInteger:status]];
    [database executeUpdate:queryForUpdate];
    [database close];
}

-(void)saveStatus:(int)status forProducts:(NSArray*)productIds inPO:(NSString*)poNumber {
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
    [database open];
    
    for(id productId in productIds){
        NSString *queryForUpdate = [NSString stringWithFormat:@"INSERT OR REPLACE into %@ (%@,%@,%@,%@) values ('%@','%@',%@,%@)",
                                    TBL_COLLABORATIVE_LOCAL_UPDATES,
                                    COL_DATE_SUBMITTED,COL_ORDER_PO_NUMBER,COL_PRODUCT_ID,COL_INSPECTION_STATUS,
                                    [DeviceManager getCurrentTimeString],poNumber,[NSNumber numberWithInteger:productId],[NSNumber numberWithInteger:status]];
        [database executeUpdate:queryForUpdate];
    }
    [database close];
}

-(NSArray<CollaborativeAPIResponse*>*) getStatus {
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
    [database open];
    NSString *query = [NSString stringWithFormat:@"SELECT * from %@",TBL_COLLABORATIVE_LOCAL_UPDATES];
    FMResultSet *rs = [database executeQuery:query];
    NSMutableArray<CollaborativeAPIResponse*>* resultsArray = [[NSMutableArray alloc]init];
    while ([rs next]) {
       // [resultsArray addObject:[rs resultDictionary]];
        NSUInteger productId = [rs intForColumn:COL_PRODUCT_ID];
        NSUInteger status = (int)[rs intForColumn:COL_INSPECTION_STATUS];
        NSString* poNumber = [rs objectForColumnName:COL_ORDER_PO_NUMBER];
        CollaborativeAPIResponse* product = [[CollaborativeAPIResponse alloc]init];
        product.product_id = productId;
        product.po = poNumber;
        product.status = (int)status;
        product.store_id = (int)[User sharedUser].currentStore.storeID;
        product.user_id = [User sharedUser].email;
        [resultsArray addObject:product];
    }
    [database close];
    return [resultsArray copy];
}

+(void)cleanupInspectionsForPO:(NSString*)poNumber {
    FMDatabase *databaseOfflineRatings = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
    [databaseOfflineRatings open];
     //   NSString *queryAllOfflineRatings = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@='%@'", TBL_COLLABORATIVE_LOCAL_UPDATES, COL_ORDER_PO_NUMBER, poNumber];
    //delete everything except the latest 100 records
    NSString* removeOldestRecords = [NSString stringWithFormat:@"DELETE FROM TBL_COLLABORATIVE_LOCAL_UPDATES WHERE DATE_SUBMITTED IN (SELECT DATE_SUBMITTED FROM TBL_COLLABORATIVE_LOCAL_UPDATES ORDER BY DATE_SUBMITTED DESC LIMIT -1 OFFSET 50)"];
        [databaseOfflineRatings executeUpdate:removeOldestRecords];
        [databaseOfflineRatings close];
}
+(void)cleanupInspectionsForGRN:(NSString*)grn {
    FMDatabase *databaseOfflineRatings = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
    [databaseOfflineRatings open];
     //   NSString *queryAllOfflineRatings = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@='%@'", TBL_COLLABORATIVE_LOCAL_UPDATES, COL_ORDER_PO_NUMBER, poNumber];
    //delete everything except the latest 100 records
    NSString* removeOldestRecords = [NSString stringWithFormat:@"DELETE FROM TBL_COLLABORATIVE_LOCAL_UPDATES WHERE DATE_SUBMITTED IN (SELECT DATE_SUBMITTED FROM TBL_COLLABORATIVE_LOCAL_UPDATES ORDER BY DATE_SUBMITTED DESC LIMIT -1 OFFSET 50)"];
        [databaseOfflineRatings executeUpdate:removeOldestRecords];
        [databaseOfflineRatings close];
}


@end
