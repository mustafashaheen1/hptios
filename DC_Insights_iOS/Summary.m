   //
  //  Summary.m
  //  DC_Insights_iOS
  //
  //  Created by Vineet Pareek on 4/30/14.
  //  Copyright (c) 2014 Yottamark. All rights reserved.
  //

  #import "Summary.h"
  #import "AuditApiSummary.h"
  #import "Product.h"
  #import "Audit.h"
  #import "Inspection.h"
  #import "FMDatabaseQueue.h"

  @implementation Summary

  @synthesize numberOfInspections;

  - (id)init
  {
      self = [super init];
      if (self) {
          self.inspectionStatus = @"Accept";
          self.globalThresholds = [[NSArray alloc] init];
          self.severityTotalThresholds = [[NSArray alloc] init];
          self.previousInspectionStatus = @"";
      }
      return self;
  }


  - (NSString *) getInspectionStatusFromDB:(int) totalAuditsCompleted withGroupId:(NSString *) groupId withAuditMasterId:(NSString *) auditMasterId withProductId: (NSString *) productId withProductGroupId: (NSString *) productGroupId withSplitGroupId:(NSString*)splitGroupId withDatabase: (FMDatabase *) databaseLocal {
      NSString *queryAllSummary = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%@' AND %@='%@' AND %@='%@' AND %@='%@' AND %@='%@'", TBL_SAVED_SUMMARY, COL_AUDIT_MASTER_ID, auditMasterId, COL_AUDIT_GROUP_ID, groupId, COL_PRODUCT_ID, productId, COL_PRODUCT_GROUP_ID, productGroupId,COL_SPLIT_GROUP_ID,splitGroupId];
      FMResultSet *results;
      NSString *summary;
      NSString *manullySelectedStatus = @"";
      FMDatabase *database;
      if (!databaseLocal || ![databaseLocal goodConnection]) {
          database = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
          [database open];
      } else {
          database = databaseLocal;
      }
      results = [database executeQuery:queryAllSummary];
      while ([results next]) {
          /*NSError *err = nil;
          summary = [results stringForColumn:COL_SUMMARY];
          if (![[results stringForColumn:COL_INSPECTION_STATUS] isEqualToString:@""]) {
              AuditApiSummary *summaryJson = [[AuditApiSummary alloc] initWithString:summary error:&err];
              if (summaryJson.inspectionSamples == totalAuditsCompleted) {
                  return summaryJson.inspectionStatus;
              }
          }*/
          //respond back with the user selected status
          //to fix the issue where modifying inspection does not affect the status
          manullySelectedStatus = [results stringForColumn:COL_INSPECTION_STATUS];
      }
      if (!databaseLocal) {
          [database close];
      }
      if(!manullySelectedStatus)
          manullySelectedStatus = @"";
      
      return manullySelectedStatus;
  }

  - (BOOL) getNotificationStatusFromDB:(int) totalAuditsCompleted withGroupId:(NSString *) groupId withAuditMasterId:(NSString *) auditMasterId withProductId: (NSString *) productId withProductGroupId: (NSString *) productGroupId withSplitGroupId:(NSString*)splitGroupId withDatabase: (FMDatabase *) databaseLocal {
      NSString *queryAllSummary = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%@' AND %@='%@' AND %@='%@' AND %@='%@' AND %@='%@'", TBL_SAVED_SUMMARY, COL_AUDIT_MASTER_ID, auditMasterId, COL_AUDIT_GROUP_ID, groupId, COL_PRODUCT_ID, productId, COL_PRODUCT_GROUP_ID, productGroupId, COL_SPLIT_GROUP_ID,splitGroupId];
      FMResultSet *results;
      NSString *summary;
      FMDatabase *database;
      if (!databaseLocal || ![databaseLocal goodConnection]) {
          database = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
          [database open];
      } else {
          database = databaseLocal;
      }
      results = [database executeQuery:queryAllSummary];
      BOOL notification = NO;
      while ([results next]) {
          NSError *err = nil;
          summary = [results stringForColumn:COL_SUMMARY];
          AuditApiSummary *summaryJson = [[AuditApiSummary alloc] initWithString:summary error:&err];
          if (summaryJson.sendNotification) {
              notification = YES;
          }
      }
      if (!databaseLocal) {
          [database close];
      }
      return notification;
  }

  - (NSString *) getUserEnteredNotificationStatusFromDB:(int) totalAuditsCompleted withGroupId:(NSString *) groupId withAuditMasterId:(NSString *) auditMasterId withProductId: (NSString *) productId withProductGroupId: (NSString *) productGroupId withSplitGroupId:(NSString*)splitGroupId withDatabase: (FMDatabase *) databaseLocal {
      NSString *queryAllSummary = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%@' AND %@='%@' AND %@='%@' AND %@='%@' AND %@='%@'", TBL_SAVED_SUMMARY, COL_AUDIT_MASTER_ID, auditMasterId, COL_AUDIT_GROUP_ID, groupId, COL_PRODUCT_ID, productId, COL_PRODUCT_GROUP_ID, productGroupId,COL_SPLIT_GROUP_ID,splitGroupId];
      FMResultSet *results;
      NSString *notification;
      FMDatabase *database;
      if (!databaseLocal || ![databaseLocal goodConnection]) {
          database = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
          [database open];
      } else {
          database = databaseLocal;
      }
      results = [database executeQuery:queryAllSummary];
      while ([results next]) {
          notification = [NSString stringWithFormat:@"%@", [results stringForColumn:COL_USERENTERED_NOTIFICATION]];
          if ([notification isEqualToString:@"(null)"]) {
              notification = @"";
          }
      }
      if (!databaseLocal) {
          [database close];
      }
      return notification;
  }
- (int) getUserEnteredChangedFromDB:(NSString *) groupId withAuditMasterId:(NSString *) auditMasterId withProductId: (NSString *) productId withProductGroupId: (NSString *) productGroupId withDatabase: (FMDatabase *) databaseLocal {
    NSString *queryAllSummary = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%@' AND %@='%@' AND %@='%@' AND %@='%@'", TBL_SAVED_SUMMARY, COL_AUDIT_MASTER_ID, auditMasterId, COL_AUDIT_GROUP_ID, groupId, COL_PRODUCT_ID, productId, COL_PRODUCT_GROUP_ID, productGroupId];
    FMResultSet *results;
    int changed;
    FMDatabase *database;
    if (!databaseLocal || ![databaseLocal goodConnection]) {
        database = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
        [database open];
    } else {
        database = databaseLocal;
    }
    results = [database executeQuery:queryAllSummary];
    while ([results next]) {
        changed = [results intForColumn:COL_NOTIFICATION_CHANGED];
    }
    if (!databaseLocal) {
        [database close];
    }
    return changed;
}
  + (NSString *) getCountOfCasesFromDB:(int) totalAuditsCompleted withGroupId:(NSString *) groupId withProductId:(NSString *) productId withSplitGroupId:(NSString*)splitGroupId withDatabase: (FMDatabase *) databaseLocal {
      NSString *auditMasterId = [[Inspection sharedInspection] auditMasterId];
      NSString *queryAllSummary = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%@' AND %@='%@' AND %@='%@' AND %@='%@'", TBL_SAVED_SUMMARY, COL_PRODUCT_ID, productId, COL_PRODUCT_GROUP_ID, groupId, COL_AUDIT_MASTER_ID, auditMasterId, COL_SPLIT_GROUP_ID,splitGroupId];
      FMResultSet *results;
      NSString *count;
      FMDatabase *database;
      if (!databaseLocal || ![databaseLocal goodConnection]) {
          database = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
          [database open];
      } else {
          database = databaseLocal;
      }
      results = [database executeQuery:queryAllSummary];
      while ([results next]) {
          count = [results stringForColumn:COL_COUNT_OF_CASES];
      }
      if (!databaseLocal) {
          [database close];
      }
      return count;
  }
+ (NSString *) getInspectionCountOfCasesFromDB:(int) totalAuditsCompleted withGroupId:(NSString *) groupId withProductId:(NSString *) productId withSplitGroupId:(NSString*)splitGroupId withDatabase: (FMDatabase *) databaseLocal {
    NSString *auditMasterId = [[Inspection sharedInspection] auditMasterId];
    NSString *queryAllSummary = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%@' AND %@='%@' AND %@='%@' AND %@='%@'", TBL_SAVED_SUMMARY, COL_PRODUCT_ID, productId, COL_PRODUCT_GROUP_ID, groupId, COL_AUDIT_MASTER_ID, auditMasterId, COL_SPLIT_GROUP_ID,splitGroupId];
    FMResultSet *results;
    NSString *count;
    FMDatabase *database;
    if (!databaseLocal || ![databaseLocal goodConnection]) {
        database = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
        [database open];
    } else {
        database = databaseLocal;
    }
    results = [database executeQuery:queryAllSummary];
    while ([results next]) {
        count = [results stringForColumn:COL_INSPECTION_COUNT_OF_CASES];
    }
    if (!databaseLocal) {
        [database close];
    }
    return count;
}
  + (NSDictionary *) getCountOfCasesForProductsFromDB:(NSArray *) productsArray {
      NSString *auditMasterId = [[Inspection sharedInspection] auditMasterId];
      FMResultSet *results;
      NSString *count;
      NSMutableDictionary *dictionaryCountOfCases = [[NSMutableDictionary alloc] init];
      FMDatabase *database;
      database = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
      [database open];
      for (Product *product in productsArray) {
          NSString *queryAllSummary = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%@' AND %@='%@' AND %@='%@' AND %@=%@", TBL_SAVED_SUMMARY, COL_PRODUCT_ID, [NSString stringWithFormat:@"%d", product.product_id], COL_PRODUCT_GROUP_ID, [NSString stringWithFormat:@"%d", product.group_id], COL_AUDIT_MASTER_ID, auditMasterId,COL_SPLIT_GROUP_ID,[Inspection sharedInspection].currentSplitGroupId];
          results = [database executeQuery:queryAllSummary];
          while ([results next]) {
              count = [results stringForColumn:COL_COUNT_OF_CASES];
          }
          [dictionaryCountOfCases setObject:product forKey:count];
      }
      [database close];
      return dictionaryCountOfCases;
  }

  - (NSString *) getInspectionSummaryFromDB:(NSString *) groupId withAuditMasterId:(NSString *) auditMasterId withDatabase: (FMDatabase *) databaseLocal {
      NSString *queryAllSummary = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%@ AND %@=%@ AND %@=%@", TBL_SAVED_SUMMARY, COL_AUDIT_MASTER_ID, auditMasterId, COL_AUDIT_GROUP_ID, groupId,COL_SPLIT_GROUP_ID,[Inspection sharedInspection].currentSplitGroupId];
      FMResultSet *results;
      NSString *summary;
      FMDatabase *database;
      if (!databaseLocal || ![databaseLocal goodConnection]) {
          database = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
          [database open];
      } else {
          database = databaseLocal;
      }
      results = [database executeQuery:queryAllSummary];
      while ([results next]) {
          summary = [results stringForColumn:COL_SUMMARY];
      }
      if (!databaseLocal) {
          [database close];
      }
      return summary;
  }

  - (NSString *) getUserEnteredInspectionSamplesFromDB:(NSString *) groupId withAuditMasterId:(NSString *) auditMasterId
                                         withProductId:(NSString *) productId withSplitGroupId:(NSString*)splitGroupId withDatabase: (FMDatabase *) databaseLocal {
      NSString *queryAllSummary = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%@' AND %@='%@' AND %@='%@' AND %@='%@'", TBL_SAVED_SUMMARY, COL_PRODUCT_ID, productId, COL_PRODUCT_GROUP_ID, groupId, COL_AUDIT_MASTER_ID, auditMasterId,COL_SPLIT_GROUP_ID,splitGroupId];
      FMResultSet *results;
      NSString *inspectionSamples;
      FMDatabase *database;
      if (!databaseLocal || ![databaseLocal goodConnection]) {
          database = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
          [database open];
      } else {
          database = databaseLocal;
      }
      results = [database executeQuery:queryAllSummary];
      while ([results next]) {
          inspectionSamples = [results stringForColumn:COL_USERENTERED_SAMPLES];
      }
      if (!databaseLocal) {
          [database close];
      }
      return inspectionSamples;
  }

  // update only the inspection status
  - (void) updateInspectionStatusInDB:(NSString *) newInspectionStatus withGroupId:(NSString *) groupId withAuditMasterID:(NSString *)auditMasterId withProductId: (NSString *) productId withProductGroupId: (NSString *) productGroupId withSplitGroupId:(NSString *)splitGroupId withDatabase: (FMDatabase *) databaseLocal {
      NSString *queryAllSummary = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%@ AND %@=%@ AND %@=%@", TBL_SAVED_SUMMARY, COL_AUDIT_MASTER_ID, auditMasterId, COL_AUDIT_GROUP_ID, groupId, COL_SPLIT_GROUP_ID, splitGroupId];
      FMResultSet *results;
      NSString *queryForUpdate = @"";
      FMDatabase *database;
      if (!databaseLocal || ![databaseLocal goodConnection]) {
          database = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
          [database open];
      } else {
          database = databaseLocal;
      }
      results = [database executeQuery:queryAllSummary];
      while ([results next]) {
          NSError *err = nil;
          NSString *summary = [results stringForColumn:COL_SUMMARY];
          AuditApiSummary *summaryJson = [[AuditApiSummary alloc] initWithString:summary error:&err];
          summaryJson.inspectionStatus = newInspectionStatus;
          NSString *updatedSummary = [summaryJson toJSONString];
          queryForUpdate = [NSString stringWithFormat:@"UPDATE %@ SET %@='%@' WHERE %@=%@ AND %@=%@ AND %@=%@ AND %@=%@", TBL_SAVED_SUMMARY, COL_SUMMARY, updatedSummary, COL_AUDIT_MASTER_ID, auditMasterId, COL_PRODUCT_ID, productId, COL_PRODUCT_GROUP_ID, productGroupId, COL_SPLIT_GROUP_ID, splitGroupId];
          [database executeUpdate:queryForUpdate];
      }
      if (!databaseLocal) {
          [database close];
      }
      [self checkInspectionStatus];
  }

  - (AuditApiSummary*) getSummaryFromDBForGroupId:(NSString *) groupId withAuditMasterID:(NSString *)auditMasterId withProductId: (NSString *) productId withSplitGroupId:(NSString *)splitGroupId{
      AuditApiSummary* auditApiSummary;
      NSString *queryAllSummary = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%@ AND %@=%@ AND %@=%@", TBL_SAVED_SUMMARY, COL_AUDIT_MASTER_ID, auditMasterId, COL_AUDIT_GROUP_ID, groupId, COL_SPLIT_GROUP_ID, splitGroupId];
      FMResultSet *results;
      NSString *queryForUpdate = @"";
      FMDatabase *database;
          database = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
          [database open];

      results = [database executeQuery:queryAllSummary];
      while ([results next]) {
          NSError *err = nil;
          NSString *summary = [results stringForColumn:COL_SUMMARY];
          auditApiSummary = [[AuditApiSummary alloc] initWithString:summary error:&err];
      }

          [database close];
      
      return auditApiSummary;
  }

  - (void) updateDaysRemainingValidationFailedStatus:(BOOL)status withGroupId:(NSString *) groupId withAuditMasterID:(NSString *)auditMasterId withProductId: (NSString *) productId withProductGroupId: (NSString *) productGroupId withSplitGroupId:(NSString *)splitGroupId withDatabase: (FMDatabase *) databaseLocal {
      NSString *queryAllSummary = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%@ AND %@=%@ AND %@=%@", TBL_SAVED_SUMMARY, COL_AUDIT_MASTER_ID, auditMasterId, COL_AUDIT_GROUP_ID, groupId, COL_SPLIT_GROUP_ID, splitGroupId];
      FMResultSet *results;
      NSString *queryForUpdate = @"";
      FMDatabase *database;
      if (!databaseLocal || ![databaseLocal goodConnection]) {
          database = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
          [database open];
      } else {
          database = databaseLocal;
      }
      results = [database executeQuery:queryAllSummary];
      while ([results next]) {
          NSError *err = nil;
          NSString *summary = [results stringForColumn:COL_SUMMARY];
          AuditApiSummary *summaryJson = [[AuditApiSummary alloc] initWithString:summary error:&err];
          summaryJson.failedDateValidation = NO;
          NSString *updatedSummary = [summaryJson toJSONString];
          queryForUpdate = [NSString stringWithFormat:@"UPDATE %@ SET %@='%@' WHERE %@=%@ AND %@=%@ AND %@=%@ AND %@=%@", TBL_SAVED_SUMMARY, COL_SUMMARY, updatedSummary, COL_AUDIT_MASTER_ID, auditMasterId, COL_PRODUCT_ID, productId, COL_PRODUCT_GROUP_ID, productGroupId, COL_SPLIT_GROUP_ID, splitGroupId];
          [database executeUpdate:queryForUpdate];
      }
      if (!databaseLocal) {
          [database close];
      }
  }

  // update Notification
  - (void) updateNotificationInDB:(BOOL) notification withGroupId:(NSString *) groupId withAuditMasterID:(NSString *)auditMasterId withProductId: (NSString *) productId withProductGroupId: (NSString *) productGroupId withDatabase: (FMDatabase *) databaseLocal withSplitGroupId: (NSString *) splitGroupId{
      NSString *queryAllSummary = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%@ AND %@=%@ AND %@=%@", TBL_SAVED_SUMMARY, COL_AUDIT_MASTER_ID, auditMasterId, COL_AUDIT_GROUP_ID, groupId,COL_SPLIT_GROUP_ID,splitGroupId];
      FMResultSet *results;
      NSString *queryForUpdate = @"";
      FMDatabase *database;
      if (!databaseLocal || ![databaseLocal goodConnection]) {
          database = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
          [database open];
      } else {
          database = databaseLocal;
      }
      results = [database executeQuery:queryAllSummary];
      while ([results next]) {
          NSError *err = nil;
          NSString *summary = [results stringForColumn:COL_SUMMARY];
          AuditApiSummary *summaryJson = [[AuditApiSummary alloc] initWithString:summary error:&err];
          summaryJson.sendNotification = notification;
          NSString *updatedSummary = [summaryJson toJSONString];
          queryForUpdate = [NSString stringWithFormat:@"UPDATE %@ SET %@='%@', %@='%@' WHERE %@=%@ AND %@=%@ AND %@=%@ AND %@=%@", TBL_SAVED_SUMMARY, COL_SUMMARY, updatedSummary, COL_USERENTERED_NOTIFICATION, [NSString stringWithFormat:@"%d", notification], COL_AUDIT_MASTER_ID, auditMasterId, COL_PRODUCT_ID, productId, COL_PRODUCT_GROUP_ID, productGroupId,COL_SPLIT_GROUP_ID,splitGroupId];
          [database executeUpdate:queryForUpdate];
      }
      if (!databaseLocal) {
          [database close];
      }
  }
- (void) updateChangedInDB:(int) changed withGroupId:(NSString *) groupId withAuditMasterID:(NSString *)auditMasterId withProductId: (NSString *) productId withProductGroupId: (NSString *) productGroupId withDatabase: (FMDatabase *) databaseLocal{
    NSString *queryAllSummary = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%@ AND %@=%@ AND %@=%@", TBL_SAVED_SUMMARY, COL_AUDIT_MASTER_ID, auditMasterId, COL_AUDIT_GROUP_ID, groupId,COL_SPLIT_GROUP_ID,[Inspection sharedInspection].currentSplitGroupId];
    FMResultSet *results;
    NSString *queryForUpdate = @"";
    FMDatabase *database;
    if (!databaseLocal || ![databaseLocal goodConnection]) {
        database = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
        [database open];
    } else {
        database = databaseLocal;
    }
    results = [database executeQuery:queryAllSummary];
    while ([results next]) {
        NSError *err = nil;
        NSString *summary = [results stringForColumn:COL_SUMMARY];
        AuditApiSummary *summaryJson = [[AuditApiSummary alloc] initWithString:summary error:&err];
        NSString *updatedSummary = [summaryJson toJSONString];
        queryForUpdate = [NSString stringWithFormat:@"UPDATE %@ SET %@='%@', %@='%d' WHERE %@=%@ AND %@=%@ AND %@=%@ AND %@=%@", TBL_SAVED_SUMMARY, COL_SUMMARY, updatedSummary, COL_NOTIFICATION_CHANGED, changed, COL_AUDIT_MASTER_ID, auditMasterId, COL_PRODUCT_ID, productId, COL_PRODUCT_GROUP_ID, productGroupId,COL_SPLIT_GROUP_ID,[Inspection sharedInspection].currentSplitGroupId];
        [database executeUpdate:queryForUpdate];
    }
    if (!databaseLocal) {
        [database close];
    }
}
- (void) updateNotificationInDB:(BOOL) notification withGroupId:(NSString *) groupId withAuditMasterID:(NSString *)auditMasterId withProductId: (NSString *) productId withProductGroupId: (NSString *) productGroupId withDatabase: (FMDatabase *) databaseLocal{
    NSString *queryAllSummary = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%@ AND %@=%@ AND %@=%@", TBL_SAVED_SUMMARY, COL_AUDIT_MASTER_ID, auditMasterId, COL_AUDIT_GROUP_ID, groupId,COL_SPLIT_GROUP_ID,[Inspection sharedInspection].currentSplitGroupId];
    FMResultSet *results;
    NSString *queryForUpdate = @"";
    FMDatabase *database;
    if (!databaseLocal || ![databaseLocal goodConnection]) {
        database = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
        [database open];
    } else {
        database = databaseLocal;
    }
    results = [database executeQuery:queryAllSummary];
    while ([results next]) {
        NSError *err = nil;
        NSString *summary = [results stringForColumn:COL_SUMMARY];
        AuditApiSummary *summaryJson = [[AuditApiSummary alloc] initWithString:summary error:&err];
        summaryJson.sendNotification = notification;
        NSString *updatedSummary = [summaryJson toJSONString];
        queryForUpdate = [NSString stringWithFormat:@"UPDATE %@ SET %@='%@', %@='%@' WHERE %@=%@ AND %@=%@ AND %@=%@ AND %@=%@", TBL_SAVED_SUMMARY, COL_SUMMARY, updatedSummary, COL_USERENTERED_NOTIFICATION, [NSString stringWithFormat:@"%d", notification], COL_AUDIT_MASTER_ID, auditMasterId, COL_PRODUCT_ID, productId, COL_PRODUCT_GROUP_ID, productGroupId,COL_SPLIT_GROUP_ID,[Inspection sharedInspection].currentSplitGroupId];
        [database executeUpdate:queryForUpdate];
    }
    if (!databaseLocal) {
        [database close];
    }
}
  //delete summary row from the table - only when deleting all the audits
  -(void) deleteSummaryForProductWithGroupId:(NSString *) productGroupId withAuditMasterID:(NSString *) auditMasterId withProductId: (NSString *) productId withDatabase: (FMDatabase *) databaseLocal {
      FMResultSet *results;
      NSString *queryForUpdate = @"";
      FMDatabase *database;
      if (!databaseLocal || ![databaseLocal goodConnection]) {
          database = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
          [database open];
      } else {
          database = databaseLocal;
      }
      
      NSString *queryAllSummary = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@=%@ AND %@=%@ AND %@=%@ AND %@=%@", TBL_SAVED_SUMMARY, COL_PRODUCT_ID, productId, COL_PRODUCT_GROUP_ID, productGroupId, COL_AUDIT_MASTER_ID,auditMasterId,COL_SPLIT_GROUP_ID,[Inspection sharedInspection].currentSplitGroupId]; //fix DI-1132
      
      [[DBManager sharedDBManager] executeUpdateUsingFMDataBase:[NSArray arrayWithObjects:queryAllSummary, nil] withDatabasePath:DB_APP_DATA];
   
      if (!databaseLocal) {
          [database close];
      }
  }

  - (void) updateNumberOfInspectionsInDB:(int) newInspectionsCount withGroupId:(NSString *) productGroupId withAuditMasterID:(NSString *) auditMasterId withProductId: (NSString *) productId withSplitGroupId:(NSString *)splitGroupId withDatabase: (FMDatabase *) databaseLocal {
      NSString *queryAllSummary = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%@ AND %@=%@ AND %@=%@ AND %@=%@", TBL_SAVED_SUMMARY, COL_PRODUCT_ID, productId, COL_PRODUCT_GROUP_ID, productGroupId, COL_AUDIT_MASTER_ID,auditMasterId, COL_SPLIT_GROUP_ID, [Inspection sharedInspection].currentSplitGroupId]; //fix DI-1132
      FMResultSet *results;
      NSString *queryForUpdate = @"";
      FMDatabase *database;
      if (!databaseLocal || ![databaseLocal goodConnection]) {
          database = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
          [database open];
      } else {
          database = databaseLocal;
      }
      results = [database executeQuery:queryAllSummary];
      while ([results next]) {
          NSString *summaryJSONLocal = [results stringForColumn:COL_SUMMARY];
          AuditApiSummary *summary = [[AuditApiSummary alloc] initWithString:summaryJSONLocal error:nil];
          summary.percentageOfCases = [self calculateAveragePercentageOfCases:summary.totalCases withInspectionSamples:newInspectionsCount];
          summary.inspectionPercentageOfCases = [self calculateAverageInspectionPercentageOfCases:summary.inspectionCases withInspectionSamples:newInspectionsCount];
          NSString *summaryJSONAgain = [summary toJSONString];
          
          queryForUpdate = [NSString stringWithFormat:@"UPDATE %@ SET %@='%@', %@='%@', %@='%d', %@='%d' WHERE %@='%@' AND %@='%@' AND %@='%@' AND %@='%@'", TBL_SAVED_SUMMARY, COL_USERENTERED_SAMPLES, [NSString stringWithFormat:@"%d", newInspectionsCount], COL_SUMMARY, summaryJSONAgain, COL_COUNT_OF_CASES, summary.totalCases, COL_INSPECTION_COUNT_OF_CASES, summary.inspectionCases, COL_PRODUCT_ID, productId, COL_PRODUCT_GROUP_ID, productGroupId, COL_AUDIT_MASTER_ID, auditMasterId, COL_SPLIT_GROUP_ID, [Inspection sharedInspection].currentSplitGroupId];
          [database executeUpdate:queryForUpdate];
          if (aggregateSamplesMode) {
              queryForUpdate = [NSString stringWithFormat:@"UPDATE %@ SET %@='%@' WHERE %@='%@' AND %@='%@' AND %@='%@' AND %@='%@'", TBL_SAVED_AUDITS, COL_USERENTERED_SAMPLES, [NSString stringWithFormat:@"%d", newInspectionsCount], COL_PRODUCT_GROUP_ID, productGroupId, COL_AUDIT_MASTER_ID, auditMasterId, COL_AUDIT_PRODUCT_ID, productId, COL_SPLIT_GROUP_ID,[Inspection sharedInspection].currentSplitGroupId];
              [database executeUpdate:queryForUpdate];
          }
      }
      if (!databaseLocal) {
          [database close];
      }
  }

  // update only the inspection status
  - (void) updateInspectionColumnStatusInDB:(NSString *) newInspectionStatus withGroupId:(NSString *) groupId withAuditMasterID:(NSString *)auditMasterId withProductId: (NSString *) productId withProductGroupId: (NSString *) productGroupId withSplitGroupId:(NSString*)splitGroupId withDatabase: (FMDatabase *) databaseLocal {
      NSString *queryAllSummary = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%@ AND %@=%@ AND %@='%@' AND %@='%@' AND %@='%@'", TBL_SAVED_SUMMARY, COL_AUDIT_MASTER_ID, auditMasterId, COL_AUDIT_GROUP_ID, groupId, COL_PRODUCT_ID, productId, COL_PRODUCT_GROUP_ID, productGroupId, COL_SPLIT_GROUP_ID, splitGroupId];
      FMResultSet *results;
      NSString *queryForUpdate = @"";
      FMDatabase *database;
      if (!databaseLocal || ![databaseLocal goodConnection]) {
          database = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
          [database open];
      } else {
          database = databaseLocal;
      }
      results = [database executeQuery:queryAllSummary];
      while ([results next]) {
          NSError *err = nil;
          NSString *summary = [results stringForColumn:COL_SUMMARY];
          AuditApiSummary *summaryJson = [[AuditApiSummary alloc] initWithString:summary error:&err];
          summaryJson.inspectionStatus = newInspectionStatus;
          if ([self.inspectionStatus isEqualToString:INSPECTION_STATUS_ACCEPT]) {
              summaryJson.sendNotification = NO;
          } else {
              summaryJson.sendNotification = YES;
          }

          //TODO combine the queries
          NSString *updatedSummary = [summaryJson toJSONString];
          queryForUpdate = [NSString stringWithFormat:@"UPDATE %@ SET %@='%@' WHERE %@=%@ AND %@=%@ AND %@='%@' AND %@='%@' AND %@='%@'", TBL_SAVED_SUMMARY, COL_SUMMARY, updatedSummary, COL_AUDIT_MASTER_ID, auditMasterId, COL_AUDIT_GROUP_ID, groupId, COL_PRODUCT_ID, productId, COL_PRODUCT_GROUP_ID, productGroupId, COL_SPLIT_GROUP_ID, splitGroupId];
          [database executeUpdate:queryForUpdate];
          queryForUpdate = [NSString stringWithFormat:@"UPDATE %@ SET %@='%@' WHERE %@=%@ AND %@=%@ AND %@='%@' AND %@='%@' AND %@='%@'", TBL_SAVED_SUMMARY, COL_INSPECTION_STATUS, self.inspectionStatus, COL_AUDIT_MASTER_ID, auditMasterId, COL_AUDIT_GROUP_ID, groupId, COL_PRODUCT_ID, productId, COL_PRODUCT_GROUP_ID, productGroupId, COL_SPLIT_GROUP_ID, splitGroupId];
          [database executeUpdate:queryForUpdate];
          queryForUpdate = [NSString stringWithFormat:@"UPDATE %@ SET %@='%@' WHERE %@=%@ AND %@=%@ AND %@='%@' AND %@='%@' AND %@='%@'", TBL_SAVED_SUMMARY, COL_USERENTERED_NOTIFICATION, [NSString stringWithFormat:@"%d", summaryJson.sendNotification], COL_AUDIT_MASTER_ID, auditMasterId, COL_AUDIT_GROUP_ID, groupId, COL_PRODUCT_ID, productId, COL_PRODUCT_GROUP_ID, productGroupId, COL_SPLIT_GROUP_ID, splitGroupId];
          [database executeUpdate:queryForUpdate];
      }
      if (!databaseLocal) {
          [database close];
      }
      [self checkInspectionStatus];
  }


  //// update only the Count Of Cases
  - (void) updateCountOfCasesInDB:(NSString *) newCount withInspectionCount: (NSString *) inspectionCount withGroupId:(NSString *) productGroupId withProductId:(NSString *) productId withDatabase: (FMDatabase *) databaseLocal {
      NSString *auditMasterId = [[Inspection sharedInspection] auditMasterId];
      NSString *queryAllSummary = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%@ AND %@=%@ AND %@=%@ AND %@=%@", TBL_SAVED_SUMMARY, COL_PRODUCT_ID, productId, COL_PRODUCT_GROUP_ID, productGroupId, COL_AUDIT_MASTER_ID, [Inspection sharedInspection].auditMasterId, COL_SPLIT_GROUP_ID, [Inspection sharedInspection].currentSplitGroupId];
      FMResultSet *results;
      NSString *queryForUpdate = @"";
      FMDatabase *database;
      if (!databaseLocal || ![databaseLocal goodConnection]) {
          database = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
          [database open];
      } else {
          database = databaseLocal;
      }
      results = [database executeQuery:queryAllSummary];
      BOOL present = NO;
      while ([results next]) {
          NSString *updatedSummary;
          present = YES;
          NSError *err = nil;
          NSString *summary = [results stringForColumn:COL_SUMMARY];
          AuditApiSummary *summaryJson = [[AuditApiSummary alloc] initWithString:summary error:&err];
          summaryJson.totalCases = [newCount integerValue];
          summaryJson.inspectionCases = [inspectionCount integerValue];
          updatedSummary = [summaryJson toJSONString];
          queryForUpdate = [NSString stringWithFormat:@"UPDATE %@ SET %@='%@', %@='%@', %@='%@' WHERE %@='%@' AND %@='%@' AND %@='%@' AND %@='%@'", TBL_SAVED_SUMMARY, COL_COUNT_OF_CASES, newCount, COL_INSPECTION_COUNT_OF_CASES, inspectionCount, COL_SUMMARY, updatedSummary, COL_PRODUCT_ID, productId, COL_PRODUCT_GROUP_ID, productGroupId, COL_AUDIT_MASTER_ID, auditMasterId,COL_SPLIT_GROUP_ID, [Inspection sharedInspection].currentSplitGroupId];
          [database executeUpdate:queryForUpdate];
          if (aggregateSamplesMode) {
              queryForUpdate = [NSString stringWithFormat:@"UPDATE %@ SET %@='%@', %@='%@' WHERE %@='%@' AND %@='%@' AND %@='%@'", TBL_SAVED_AUDITS, COL_COUNT_OF_CASES, newCount, COL_INSPECTION_COUNT_OF_CASES, inspectionCount, COL_PRODUCT_GROUP_ID, productGroupId, COL_AUDIT_MASTER_ID, auditMasterId,COL_SPLIT_GROUP_ID, [Inspection sharedInspection].currentSplitGroupId];
              [database executeUpdate:queryForUpdate];
              [self updateAuditCountOfCasesRating:database withProductGroupId:productGroupId withProductId:productId withCount:newCount];
          }
      }
      if (!present) {
          NSString *updatedSummary2 = @"";
          AuditApiSummary *summaryJson = [[AuditApiSummary alloc] init];
          summaryJson = [self generateAuditApiSummary];
          summaryJson.totalCases = [newCount integerValue];
          updatedSummary2 = [summaryJson toJSONString];
          NSString *queryForInsert = [NSString stringWithFormat:@"INSERT INTO %@ (%@,%@,%@,%@,%@,%@,%@,%@) VALUES ('%@','%@','%@','%@','%@','%@','%@','%@');", TBL_SAVED_SUMMARY, COL_AUDIT_MASTER_ID, COL_AUDIT_GROUP_ID, COL_SUMMARY, COL_PRODUCT_ID, COL_PRODUCT_GROUP_ID, COL_COUNT_OF_CASES, COL_INSPECTION_COUNT_OF_CASES, COL_SPLIT_GROUP_ID, [[Inspection sharedInspection] auditMasterId], productGroupId, updatedSummary2, productId, productGroupId, newCount, inspectionCount,[Inspection sharedInspection].currentSplitGroupId];
          [database executeUpdate:queryForInsert];
      }
      if (!databaseLocal) {
          [database close];
      }
      self.totalCountOfCases = [newCount integerValue];
      self.inspectionCountOfCases = [inspectionCount integerValue];
      [self calculateAveragePercentageOfCases];
  }

  - (void) updateAuditCountOfCasesRating: (FMDatabase *) database withProductGroupId: (NSString *) productGroupId withProductId:(NSString *) productId withCount: (NSString *) count {
      NSString *queryAuditRating = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%@ AND %@=%@ AND %@=%@ AND %@=%@", TBL_SAVED_AUDITS, COL_PRODUCT_GROUP_ID, productGroupId, COL_AUDIT_MASTER_ID, [Inspection sharedInspection].auditMasterId, COL_AUDIT_PRODUCT_ID,productId, COL_SPLIT_GROUP_ID,[Inspection sharedInspection].currentSplitGroupId];
      FMDatabase *databaseLocal;
      databaseLocal = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
      FMResultSet *results2;
      results2 = [databaseLocal executeQuery:queryAuditRating];
      NSString *jsonString;
      while ([results2 next]) {
          jsonString = [results2 stringForColumn:COL_AUDIT_JSON];
      }
      int ratingIdLocal = [self findOutCountOfCasesRatingId:productId WithProductGroupId:productGroupId];
      NSMutableArray *productRatingsLocal = [[NSMutableArray alloc] init];
      NSMutableArray<AuditApiRating>* productRatings = (NSMutableArray <AuditApiRating>*)productRatingsLocal;
      Audit *auditData = [[Audit alloc] initWithString:jsonString error:nil];
      NSArray<AuditApiRating>* productRatingsLocalArray = auditData.auditData.submittedInfo.productRatings;
      for (AuditApiRating *auditApiRating in productRatingsLocalArray) {
          if (auditApiRating.id == ratingIdLocal) {
              auditApiRating.value = count;
          }
          [productRatings addObject:auditApiRating];
      }
      auditData.auditData.submittedInfo.productRatings = productRatings;
      NSString *jsonStringLocal = [auditData toJSONString];
      NSString *auditMasterId = [[Inspection sharedInspection] auditMasterId];
      NSString *queryForUpdate = [NSString stringWithFormat:@"UPDATE %@ SET %@='%@' WHERE %@='%@' AND %@='%@' AND %@='%@' AND %@='%@'", TBL_SAVED_AUDITS, COL_AUDIT_JSON, jsonStringLocal, COL_PRODUCT_GROUP_ID, productGroupId, COL_AUDIT_MASTER_ID, auditMasterId, COL_AUDIT_PRODUCT_ID,productId, COL_SPLIT_GROUP_ID,[Inspection sharedInspection].currentSplitGroupId];
      [database executeUpdate:queryForUpdate];
  }

  - (int) findOutCountOfCasesRatingId:(NSString *) productId WithProductGroupId: (NSString *) productGroupId {
      int countOfCasesRatingId = 0;
      Product *product = [[Inspection sharedInspection] getProduct:[productGroupId integerValue] withProductID:[productId integerValue]];
      for (Rating *rating in product.ratings) {
          if ([rating.order_data_field isEqualToString:QuantityOfCasesString]) {
              countOfCasesRatingId = rating.ratingID;
              break;
          }
      }
      return countOfCasesRatingId;
  }


  /* generate Json and store in DB with corresponding groupId */
  - (void) saveSummaryToDBWithGroupId:(NSString *) groupId withAuditMasterId:(NSString *) auditMasterID withDatabase: (FMDatabase *) databaseLocal {
      NSString *summaryJSON = [self generateJson];
      
      NSString *queryAllSummary = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%@' AND %@='%@'", TBL_SAVED_SUMMARY, COL_AUDIT_MASTER_ID, auditMasterID, COL_AUDIT_GROUP_ID, groupId];
      FMResultSet *results;
      BOOL present = NO;
      FMDatabase *database;
      if (!databaseLocal || ![databaseLocal goodConnection]) {
          database = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
          [database open];
      } else {
          database = databaseLocal;
      }
      results = [database executeQuery:queryAllSummary];
      while ([results next]) {
          present = YES;
          NSString *auditMasterId = [results stringForColumn:COL_AUDIT_MASTER_ID];
          NSString *groupIdLocal = [results stringForColumn:COL_AUDIT_GROUP_ID];
          NSString *queryForUpdate = [NSString stringWithFormat:@"UPDATE %@ SET %@='%@', %@='%@', %@='%@' WHERE %@=%@ AND %@=%@", TBL_SAVED_SUMMARY, COL_AUDIT_MASTER_ID, auditMasterId, COL_AUDIT_GROUP_ID, groupIdLocal, COL_SUMMARY, summaryJSON, COL_AUDIT_MASTER_ID, auditMasterId, COL_AUDIT_GROUP_ID, groupId];
          [database executeUpdate:queryForUpdate];
      }
      if (!present) {
          NSString* newSplitGroupId = [DeviceManager getCurrentTimeString];
          NSString *queryForInsert = [NSString stringWithFormat:@"INSERT INTO %@ (%@,%@,%@,%@) VALUES ('%@','%@','%@','%@');", TBL_SAVED_SUMMARY, COL_AUDIT_MASTER_ID, COL_AUDIT_GROUP_ID, COL_SPLIT_GROUP_ID,COL_SUMMARY, auditMasterID, groupId, newSplitGroupId,summaryJSON];
          [database executeUpdate:queryForInsert];
      }
      if (!databaseLocal) {
          [database close];
      }
  }

  /* generate Json and store in DB with corresponding groupId */
  - (void) saveSummaryToDBWithGroupId:(NSString *) groupId withAuditMasterId:(NSString *) auditMasterID withProductId:(NSString *) productId withProductGroupId: (NSString *) productGroupId withSplitGroupId:(NSString*)splitGroupId withDatabase: (FMDatabase *) databaseLocal {
      NSString *summaryJSON = [self generateJson];
      
      NSString *queryAllSummary = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%@' AND %@='%@' AND %@='%@' AND %@='%@' AND %@='%@'", TBL_SAVED_SUMMARY, COL_AUDIT_MASTER_ID, auditMasterID, COL_AUDIT_GROUP_ID, groupId, COL_PRODUCT_ID, productId, COL_PRODUCT_GROUP_ID, productGroupId, COL_SPLIT_GROUP_ID,splitGroupId];
      FMResultSet *results;
      BOOL present = NO;
      FMDatabase *database;
      if (!databaseLocal || ![databaseLocal goodConnection]) {
          database = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
          [database open];
      } else {
          database = databaseLocal;
      }
      results = [database executeQuery:queryAllSummary];
      NSString *queryForUpdate = @"";
      while ([results next]) {
          present = YES;
          NSString *auditMasterId = [results stringForColumn:COL_AUDIT_MASTER_ID];
          NSString *groupIdLocal = [results stringForColumn:COL_AUDIT_GROUP_ID];
          queryForUpdate = [NSString stringWithFormat:@"UPDATE %@ SET %@='%@', %@='%@', %@='%@' WHERE %@=%@ AND %@=%@ AND %@=%@ AND %@=%@ AND %@=%@", TBL_SAVED_SUMMARY, COL_AUDIT_MASTER_ID, auditMasterId, COL_AUDIT_GROUP_ID, groupIdLocal, COL_SUMMARY, summaryJSON, COL_AUDIT_MASTER_ID, auditMasterId, COL_AUDIT_GROUP_ID, groupId, COL_PRODUCT_ID, productId, COL_PRODUCT_GROUP_ID, productGroupId, COL_SPLIT_GROUP_ID,splitGroupId];
      }
      if (!present) {
          //NSString* newSplitGroupId = [DeviceManager getCurrentTimeString];
          
          NSString *queryForInsert = [NSString stringWithFormat:@"INSERT INTO %@ (%@,%@,%@,%@,%@,%@,%@) VALUES ('%@','%@','%@','%@','%@','%@','%@');", TBL_SAVED_SUMMARY, COL_AUDIT_MASTER_ID, COL_AUDIT_GROUP_ID,COL_SPLIT_GROUP_ID, COL_SUMMARY, COL_PRODUCT_ID, COL_PRODUCT_GROUP_ID, COL_COUNT_OF_CASES, auditMasterID, groupId,splitGroupId, summaryJSON, productId, productGroupId, @"0"];
          [database executeUpdate:queryForInsert];
      }
      if (present) {
          [database executeUpdate:queryForUpdate];
      }
      if (!databaseLocal) {
          [database close];
      }
  }

  - (NSString *) generateJson {
      NSString *summaryJson = [[self generateAuditApiSummary] toJSONString];
      NSLog(@"%@",summaryJson);
      return summaryJson;
  }

  - (AuditApiSummary *) generateAuditApiSummary {
      AuditApiSummary *summaryObject = [[AuditApiSummary alloc] init];
      summaryObject.inspectionSamples = self.numberOfInspections;
      summaryObject.percentageOfCases = self.averagePercentageOfCases;
      summaryObject.inspectionPercentageOfCases = self.inspectionPercentageOfCases;
      summaryObject.sendNotification = self.sendNotification;
      summaryObject.failedDateValidation = self.failedDateValidation;
      NSMutableArray *ratingMasterList = [[NSMutableArray alloc] init];
      for (Rating *rating in self.allRatingsList) {
          for (Defect *defect in rating.defects) {
              AuditApiSummaryDefect *summaryRatingDefect = [[AuditApiSummaryDefect alloc] init];
              summaryRatingDefect.ratingId = rating.ratingID;
              summaryRatingDefect.id = defect.defectID;
              for (Severity *severity in defect.severities) {
                  AuditApiSummaryTotal *summaryRatingTotal = [[AuditApiSummaryTotal alloc] init];
                  summaryRatingTotal.id = severity.id;
                  summaryRatingTotal.total = [[NSString stringWithFormat:@"%.2f", severity.inputOrCalculatedPercentage] floatValue];
                  [summaryRatingDefect.severities addObject:summaryRatingTotal];
              }
              [ratingMasterList addObject:summaryRatingDefect];
          }
      }
      summaryObject.defectsSummary = [ratingMasterList copy];
      
      NSMutableArray *summaryTotalList = [[NSMutableArray alloc] init];
      for (Severity *severity in self.allTotalsList) {
          AuditApiSummaryTotal *summaryTotal = [[AuditApiSummaryTotal alloc] init];
          summaryTotal.id = severity.id;
          summaryTotal.total = [[NSString stringWithFormat:@"%.2f", severity.inputOrCalculatedPercentage] floatValue];
          [summaryTotalList addObject:summaryTotal];
      }
      summaryObject.totals = [summaryTotalList copy];
      summaryObject.inspectionStatus = self.inspectionStatus;
      summaryObject.totalCases = self.totalCountOfCases;
      summaryObject.inspectionCases = self.inspectionCountOfCases;
      return summaryObject;
  }

  - (NSString *) getSeverityThresholds:(Product*) productWithReferenceData withRatingId:(int) ratingId withDefectId:(int) defectId withSevName:(NSString *) sevName {
      NSArray *allRatings = productWithReferenceData.ratings;
      Defect *defect = [[Defect alloc] init];
      defect.defectID = defectId;
      for (Rating *rating in allRatings) {
          for (int i = 0; i < [rating.defects count]; i++) {
              Defect *defectLocal = [rating.defects objectAtIndex:i];
              if (defectLocal.defectID == defect.defectID) {
                  Defect *refDefect = [rating.defects objectAtIndex:i];
                  return refDefect.name;
              }
          }
      }
      return nil;
  }

  - (NSString *) getDefectName:(Product*) productWithReferenceData withRatingId:(int) ratingId withDefectId:(int) defectId {
      NSArray *allRatings = productWithReferenceData.ratings;
      Defect *defect = [[Defect alloc] init];
      defect.defectID = defectId;
      for (Rating *rating in allRatings) {
          for (int i = 0; i < [rating.defects count]; i++) {
              Defect *defectLocal = [rating.defects objectAtIndex:i];
              if (defectLocal.defectID == defect.defectID) {
                  Defect *refDefect = [rating.defects objectAtIndex:i];
                  return refDefect.name;
              }
          }
      }
      return nil;
  }

  - (NSString *) getRating:(Product*) productWithReferenceData withRatingId:(int) ratingId {
      NSArray *allRatings = productWithReferenceData.ratings;
      for (Rating *rating in allRatings) {
          if(rating.ratingID == ratingId) {
              return rating;
          }
      }
      return nil;
  }

  - (NSString *) getRatingName:(Product*) productWithReferenceData withRatingId:(int) ratingId {
      NSArray *allRatings = productWithReferenceData.ratings;
      for (Rating *rating in allRatings) {
          if(rating.ratingID == ratingId) {
              return rating.name;
          }
      }
      return nil;
  }

  - (int) getRatingIdForCountOfCases:(Product*) productWithReferenceData {
      NSArray *allRatings = productWithReferenceData.ratings;
      for (Rating *rating in allRatings) {
          if([rating.name compare:@"COUNT OF CASES" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
              return rating.ratingID;
          }
      }
      return -1;
  }


  - (double) getAveragePercentage:(double) baseNumber withNoOfInspections:(int) numberOfInspectionsLocal {
      @try {
          return baseNumber/numberOfInspectionsLocal;
      } @catch (NSException *exception) {
          return 0;
      }
  }

  - (NSString *) calculateInspectionStatus: (NSArray *) totalsList  {
      NSString* currentStatus = INSPECTION_STATUS_ACCEPT;
      if ([self isInspectionReject:totalsList])
          return INSPECTION_STATUS_REJECT;
      else if([self isInspectionAcceptWithIssues:totalsList])
          currentStatus = INSPECTION_STATUS_ACCEPT_WITH_ISSUES;

      currentStatus = [self getStatusBySeverityTotals:currentStatus withList:totalsList];
      return currentStatus;
      
  }

  - (void) checkInspectionStatus {
      if ([self.inspectionStatus isEqualToString:INSPECTION_STATUS_ACCEPT]) {
          self.sendNotification = NO;
      } else {
          self.sendNotification = YES;
      }
  }


  -(BOOL) isInspectionReject:(NSArray*) totalsList {
      if(self.globalThresholds.count > 0){
      if ([self.globalThresholds[0] floatValue] > 0.0 && self.grandTotal > [self.globalThresholds[0] floatValue])
          return true;
      }

      for (Severity *sev in totalsList) {
          if ((sev.name == nil || [sev.name  isEqual: @""]) && sev.thresholdTotal == 0)
              continue;

          if(sev.thresholdTotal > 0.0) {
              if(self.grandTotal > sev.thresholdTotal)
                  return true;
              else if(sev.inputOrCalculatedPercentage > sev.criteriaReject)
                  return true;
          } else if(sev.inputOrCalculatedPercentage > sev.criteriaReject)
              return true;

      }
      return false;
      
  }

  -(BOOL) isInspectionAcceptWithIssues:(NSArray*) totalsList {
      if(self.globalThresholds.count > 0){
      if([self.globalThresholds[1] floatValue] > 0.0 && self.grandTotal > [self.globalThresholds[1] floatValue])
          return true;
      }
      for (Severity *sev in totalsList) {
          if ((sev.name == nil || [sev.name  isEqual: @""]) && sev.thresholdAcceptWithIssues == 0)
              continue;
          if(sev.thresholdAcceptWithIssues > 0.0) {
              if(self.grandTotal > sev.thresholdAcceptWithIssues)
                  return true;
              else if(sev.inputOrCalculatedPercentage > sev.criteriaAcceptWithIssues)
                  return true;
          } else if(sev.inputOrCalculatedPercentage > sev.criteriaAcceptWithIssues)
              return true;
      }
      return false;
  }

  /* Method to populate the summary object */
  - (Summary *) getSummaryOfAudits: (Product*) productWithReferenceData withGroupId:(NSString *) groupId
                  withSplitGroupId:(NSString*)splitGroupId withDatabase: (FMDatabase *) databaseLocal {
      self.product = [productWithReferenceData getCopy];
      NSMutableArray *listOfAllRatingJson = [[NSMutableArray alloc] init];
      NSString *auditMasterId =     [NSUserDefaultsManager getObjectFromUserDeafults:PREF_AUDIT_MASTER_ID];
      //NSString *queryAllSummary = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%ld", TBL_SAVED_AUDITS, COL_AUDIT_PRODUCT_ID, (long)productWithReferenceData.product_id];
      NSString *queryAllSummary = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%ld AND %@=%@ AND %@=%@", TBL_SAVED_AUDITS, COL_AUDIT_PRODUCT_ID, (long)productWithReferenceData.product_id, COL_AUDIT_MASTER_ID, auditMasterId, COL_SPLIT_GROUP_ID,splitGroupId];
      FMResultSet *results;
      FMDatabase *database;
      if (!databaseLocal || ![databaseLocal goodConnection]) {
          database = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
          [database open];
      } else {
          database = databaseLocal;
      }
      results = [database executeQuery:queryAllSummary];
      while ([results next]) {
          NSString *ratings = [results stringForColumn:COL_AUDIT_JSON];
          NSLog(@"%@",ratings);
          NSError *err = nil;
          Audit *auditJson = [[Audit alloc] initWithString:ratings error:&err];
          if (auditJson) {
              [listOfAllRatingJson addObject:auditJson];
          }
      }
      if (!databaseLocal) {
          [database close];
      }
      [NSUserDefaultsManager saveObjectToUserDefaults:splitGroupId withKey:@"splitGroupId"];
      [self populateSummaryobject:productWithReferenceData withSavedRatings:listOfAllRatingJson withGroupId:groupId withMasterId:auditMasterId withSplitGroupId:splitGroupId withSave:YES withDatabase:database];
      return self;
  }

  /* Method to populate the summary object */
  // Dead Code?
  - (Summary *) getSummaryOfAuditsWithDatabase: (FMDatabase *)dataBase withProduct: (Product*) productWithReferenceData withGroupId:(NSString *) groupId {
      
      NSMutableArray *listOfAllRatingJson = [[NSMutableArray alloc] init];
      NSString *auditMasterId =     [NSUserDefaultsManager getObjectFromUserDeafults:PREF_AUDIT_MASTER_ID];
      //NSString *queryAllSummary = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%ld", TBL_SAVED_AUDITS, COL_AUDIT_PRODUCT_ID, (long)productWithReferenceData.product_id];
      NSString *queryAllSummary = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%ld AND %@=%@ AND %@=%@", TBL_SAVED_AUDITS, COL_AUDIT_PRODUCT_ID, (long)productWithReferenceData.product_id, COL_AUDIT_MASTER_ID, auditMasterId,COL_SPLIT_GROUP_ID,[Inspection sharedInspection].currentSplitGroupId];

      FMResultSet *results;
      results = [dataBase executeQuery:queryAllSummary];
      while ([results next]) {
          NSString *ratings = [results stringForColumn:COL_AUDIT_JSON];
          NSError *err = nil;
          Audit *auditJson = [[Audit alloc] initWithString:ratings error:&err];
          if (auditJson) {
              [listOfAllRatingJson addObject:auditJson];
          }
      }
      // populate the summary object
      [self populateSummaryobject:productWithReferenceData withSavedRatings:listOfAllRatingJson withGroupId:groupId withMasterId:auditMasterId withSplitGroupId:[Inspection sharedInspection].currentSplitGroupId withSave:NO withDatabase:dataBase];
      return self;
  }

  - (void) populateSummaryobject: (Product*) productWithReferenceData withSavedRatings:(NSArray *) savedRatings withGroupId:(NSString *) groupId withMasterId: (NSString *) auditMasterId withSplitGroupId:(NSString*)splitGroupId withSave: (BOOL) saveToDB withDatabase: (FMDatabase *) databaseLocal {
      //Product refProduct = productWithReferenceData;
      self.product = [productWithReferenceData getCopy];
      NSArray *masterListOfAllRatings = savedRatings;
      int countOfCases = 0;
      //Product summaryProduct = new Product(productWithReferenceData.id);
      self.numberOfInspections = [masterListOfAllRatings count];
      
      // go thru master list of ratings of all products
      // for each rating, add the defects with severities
      // each product and add severity for each defect
      
      NSMutableArray *summaryRatingsSet = [[NSMutableArray alloc] init];
      self.inspectionSamples = [[NSMutableArray alloc] init];
      //NSMutableArray *summaryDefectsSet = [[NSMutableArray alloc] init];
      //Product Quality - slimy - major 10 //Display - clean - minor - 5
      for (Audit *allRatingsForProduct in masterListOfAllRatings) {
          NSArray *auditApiRating = allRatingsForProduct.auditData.submittedInfo.productRatings;
          Product *inspectionSampleProduct = [[Product alloc]init]; //inspection sample 1
          for (AuditApiRating *singleRating in auditApiRating) {
              Rating *rating = [[Rating alloc] init];
              rating.ratingID = singleRating.id;
              rating.value = singleRating.value;
                  //populate rating name from ref object
                  Rating *origRating = [self getRating:productWithReferenceData withRatingId:singleRating.id];
              NSString *ratingName = origRating.name; //[self getRatingName:productWithReferenceData withRatingId:singleRating.id];//null??
              rating.name = ratingName;
              rating.displayName = origRating.displayName;
              rating.type = singleRating.type;
              //optimize summary calculation
              if(![rating.type isEqualToString:STAR_RATING]
                 && ![rating.type isEqualToString:LABEL_RATING] )//DI-2930-support defects for label rating
                  continue;
              
              Rating* inspectionSampleRating = [[Rating alloc]init];
              inspectionSampleRating.ratingID = rating.ratingID;
              inspectionSampleRating.name = rating.name;
              inspectionSampleRating.type = rating.type;
              inspectionSampleRating.value = rating.value;
              
              if([summaryRatingsSet containsObject:rating]) {
                  //int ratingIndex = summaryRatingsSet.indexOf(rating);
                  //rating = summaryRatingsSet.get(ratingIndex);
                  int ratingIndex = [summaryRatingsSet indexOfObject:rating];
                  if([singleRating.type isEqualToString:STAR_RATING]) {
                      Rating *existingRating = [summaryRatingsSet objectAtIndex:ratingIndex];
                      int newRatingValue = [existingRating.value intValue] + [rating.value intValue];//to average later
                      existingRating.value = [NSString stringWithFormat:@"%d",newRatingValue];
                      [summaryRatingsSet replaceObjectAtIndex:ratingIndex withObject:existingRating];
                  }
                  rating = [summaryRatingsSet objectAtIndex:ratingIndex];
              }
              
              //populate rating name from ref object
              /*NSString *ratingName = [self getRatingName:productWithReferenceData withRatingId:singleRating.id];//null??
              rating.name = ratingName;
              rating.type = singleRating.type;
              //rating.value = singleRating.value;*/
              //NSLog(@"RATING NAME is: %@",rating.name);
              if([rating.name compare:@"COUNT OF CASES" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                  int countofCasesForOneRating = [singleRating.value intValue];
                  countOfCases+=countofCasesForOneRating; // keep adding here and then average at the end
              }
              
             
              
              Defect *inspectionSampleDefect = [[Defect alloc] init];
               Severity *inspectionSampleSeverity = [[Severity alloc] init];
              
              NSArray *listOfDefects = singleRating.defects;
              for(AuditApiDefect *singleDefect in listOfDefects) {
                  inspectionSampleDefect = [[Defect alloc] init];
                  inspectionSampleSeverity = [[Severity alloc] init];
                  if (singleDefect.present) {
                      Defect *defect = [[Defect alloc] init];
                      defect.defectID = singleDefect.id;
                      // populate defect name from ref object
                      NSString *defectName = [self getDefectName:productWithReferenceData withRatingId:rating.ratingID withDefectId:defect.defectID];//null??
                      defect.name = defectName;
                      NSArray *listOfSeverities = singleDefect.severities;
                      for(AuditApiSeverity *singleSeverity in listOfSeverities){
                          Severity *severity = [[Severity alloc] init];
                          
                          severity.name = singleSeverity.severity;
                          severity.inputNumerator = singleSeverity.numerator;
                          severity.inputDenominator = singleSeverity.denominator;
                          severity.inputOrCalculatedPercentage = singleSeverity.percentage;
                          
                          
                          [severity populateSeverityWithCriteria:productWithReferenceData withRatingId:rating.ratingID withDefectId:defect.defectID];
                          inspectionSampleSeverity.name = severity.name;
                          inspectionSampleSeverity.inputOrCalculatedPercentage = severity.inputOrCalculatedPercentage;
                          inspectionSampleSeverity.inputNumerator = severity.inputNumerator;
                          inspectionSampleSeverity.inputDenominator = severity.inputDenominator;
                          
                          [inspectionSampleDefect.severities addObject:inspectionSampleSeverity];
                          if ([rating.defects containsObject:defect]) {
                              Defect *existingDefect = [rating.defects objectAtIndex:[rating.defects indexOfObject:defect]];
                              if ([existingDefect.severities containsObject:severity]) {
                                  int index = [existingDefect.severities indexOfObject:severity];
                                  Severity *sev = [existingDefect.severities objectAtIndex:index];
                                  [sev addPercentage:severity.inputOrCalculatedPercentage];
                                  [existingDefect.severities replaceObjectAtIndex:index withObject:sev];
                              } else {
                                  [existingDefect.severities addObject:severity];
                              }
                          } else {
                              [defect.severities addObject:severity];
                              [rating.defects addObject:defect];
                          }
                      }
                      
                      //defect.addSeverity(severity);
                      
                      //inspection sample defect&severity
                      
                      inspectionSampleDefect.defectID = singleDefect.id;
                      inspectionSampleDefect.name = defectName;
                      
                     
                      
                      [inspectionSampleRating.defects addObject:inspectionSampleDefect];
                      
                      
                      
                      
                      // if defect already exists
                      
                      
                      
                  }
              }
             /* if(![listOfDefects count] == 0) {
                  rating.defects = summaryDefectsSet;
                  //fix for duplicate severities
                  //rating.defects = [[NSMutableArray arrayWithArray:summaryDefectsSet] init];
                  //[summaryDefectsSet removeAllObjects];
              }*/
              if(![summaryRatingsSet containsObject:rating]) {
                  [summaryRatingsSet addObject:rating];
              }
              if([inspectionSampleRating.type isEqualToString:STAR_RATING])
              [inspectionSampleProduct.ratingsFromUI addObject:inspectionSampleRating];
          }
          [self.inspectionSamples addObject:inspectionSampleProduct];
      }
      
      // calculate averages
      NSMutableArray *summaryRatingsWithAverages = [[NSMutableArray alloc] init];
      for(Rating *prodRatings in summaryRatingsSet) {
          Rating *rating = [[Rating alloc] init];
          rating.ratingID = prodRatings.ratingID;
          rating.name = prodRatings.name;
          rating.displayName = prodRatings.displayName;
          rating.type = prodRatings.type;
          rating.value = prodRatings.value;
          if([rating.type isEqualToString:STAR_RATING]){
              double starRatingAverage =[self getAveragePercentage:[rating.value intValue] withNoOfInspections:self.numberOfInspections];
              rating.value = [NSString stringWithFormat:@"%.1f", starRatingAverage];
          }
          rating.average = [self getAveragePercentage:[rating.value intValue] withNoOfInspections:self.numberOfInspections];
          NSArray *defects = prodRatings.defects;
          for(Defect *oneDefect in defects) {
              Defect *defect = [[Defect alloc] init];
              defect.defectID = oneDefect.defectID;
              defect.name = oneDefect.name;
              NSArray *severities = oneDefect.severities;
              for(Severity *oneSeverity in severities) {
                  
                  Severity *sev = [[Severity alloc] init];
                  sev.name = oneSeverity.name;
                  sev.id = oneSeverity.id;
                  sev.inputOrCalculatedPercentage = oneSeverity.inputOrCalculatedPercentage;
                  sev.criteriaAcceptWithIssues = oneSeverity.criteriaAcceptWithIssues;
                  sev.criteriaReject = oneSeverity.criteriaReject;
                  sev.thresholdTotal = oneSeverity.thresholdTotal;
                  sev.thresholdAcceptWithIssues = oneSeverity.thresholdAcceptWithIssues;
                  
                  double avgPercent = [self getAveragePercentage:oneSeverity.inputOrCalculatedPercentage withNoOfInspections:self.numberOfInspections];
                  sev.inputOrCalculatedPercentage = avgPercent;
                  if (sev.inputOrCalculatedPercentage > 0) {
                      [defect.severities addObject:sev];
                  }
              }
              if ([defect.severities count] > 0) {
                  [rating.defects addObject:defect];
              }
          }
          if ([rating.defects count] > 0) {
              [summaryRatingsWithAverages addObject:rating];
          }
      }
      FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_INSIGHTS_DATA];
      // calculate totals
      NSMutableArray *severityTotalList = [[NSMutableArray alloc] init];
      for(Rating *prodRatings in summaryRatingsWithAverages) {
          NSArray *defects = prodRatings.defects;
          if(defects != nil && defects.count > 0) {

              
              int defectFamilyId = [prodRatings getDefectFamilyId:productWithReferenceData.product_id withGroupId:productWithReferenceData.group_id withRatingId:prodRatings.ratingID withDatabase:database];

                          if(defectFamilyId != 0) {
                              self.globalThresholds = [prodRatings getGlobalThresholds:defectFamilyId withDatabase:database];
                              self.severityTotalThresholds = [prodRatings getSeverityTotals:defectFamilyId withDatabase:database];
                          }
                      }
          for(Defect *oneDefect in defects) {
              NSArray *severities = oneDefect.severities;
              for(Severity *oneSeverity in severities) {
                  if(![severityTotalList containsObject:oneSeverity]) {
                      Severity *severityToAdd = [[Severity alloc] init];
                      severityToAdd.id = oneSeverity.id;
                      severityToAdd.name = oneSeverity.name;
                      severityToAdd.inputOrCalculatedPercentage = oneSeverity.inputOrCalculatedPercentage;
                      severityToAdd.criteriaAcceptWithIssues = oneSeverity.criteriaAcceptWithIssues;
                      severityToAdd.criteriaReject = oneSeverity.criteriaReject;
                      severityToAdd.thresholdTotal = oneSeverity.thresholdTotal;
                      severityToAdd.thresholdAcceptWithIssues = oneSeverity.thresholdAcceptWithIssues;
                      [severityTotalList addObject:severityToAdd];
                  } else {
                      int index = [severityTotalList indexOfObject:oneSeverity];
                      Severity *sev = [severityTotalList objectAtIndex:index];
                      [sev addPercentage:oneSeverity.inputOrCalculatedPercentage];
                      [severityTotalList replaceObjectAtIndex:index withObject:sev];
                  }
              }
          }
      }
      
      self.allTotalsList = severityTotalList;
      // calculate the grandTotal
      if([self.allTotalsList count] > 0) {
          double total = 0;
          for(Severity *sev in self.allTotalsList) {
              total+=sev.inputOrCalculatedPercentage;
          }
          //this.grandTotal.name = "GRAND_TOTAL";
          self.grandTotal = total;
      }
      
      self.allRatingsList = [[NSMutableArray alloc] init];
      [self.allRatingsList addObjectsFromArray:summaryRatingsWithAverages];
      self.allTotalsList = severityTotalList;
      
      NSString *inspectionSamples = @"";
      
      inspectionSamples = [self getUserEnteredInspectionSamplesFromDB:groupId withAuditMasterId:auditMasterId withProductId:[NSString stringWithFormat:@"%d", productWithReferenceData.product_id] withSplitGroupId:(NSString*)splitGroupId withDatabase:databaseLocal];
      if (![inspectionSamples isEqualToString:@""] && inspectionSamples) {
          int integerInspectionSamples = [inspectionSamples integerValue];
          if (integerInspectionSamples > 0) {
              self.numberOfInspections = integerInspectionSamples;
          }
      }
      
      @try {
          //calculate the average of the rating "Count of Cases"
          [self calculateAveragePercentageOfCases];
      }
      @catch (NSException * e) {
          NSLog(@"Exception: %@", e);
          self.averagePercentageOfCases = 0;
      }
      
  //    for(Rating *aRating in self.allRatingsList) {
  //        NSLog(@"---AFTER SUMMARY ---");
  //        NSLog(@"Rating: %d", aRating.ratingID);
  //        for(Defect *aDefect in aRating.defects) {
  //            NSLog(@"Defect: %d", aDefect.defectID);
  //            for(Severity *aSeverity in aDefect.severities) {
  //                NSLog(@"Severity: %@-%f", aSeverity.name, aSeverity.inputOrCalculatedPercentage);
  //            }
  //        }
  //    }
  //    for(Severity *aSev in self.allTotalsList) {
  //        NSLog(@"Totals: %@-%f", aSev.name, aSev.inputOrCalculatedPercentage);
  //    }
      //NSLog(@"Grand Total: %f", self.grandTotal);
      
      self.inspectionStatus = [self calculateInspectionStatus:self.allTotalsList];
      // check if there is a inspection status already set for the current number of audits
      //NSString *summaryJSON = [self generateJson];
      //NSLog(@"summaryJSON %@", summaryJSON);
      NSString *existingInspectionStatus = [self getInspectionStatusFromDB:self.numberOfInspections withGroupId:groupId withAuditMasterId:auditMasterId withProductId:[NSString stringWithFormat:@"%d", productWithReferenceData.product_id] withProductGroupId:[NSString stringWithFormat:@"%d", productWithReferenceData.group_id] withSplitGroupId:(NSString*)splitGroupId withDatabase:databaseLocal];
      BOOL notificationLocal = [self getNotificationStatusFromDB:self.numberOfInspections withGroupId:groupId withAuditMasterId:auditMasterId withProductId:[NSString stringWithFormat:@"%d", productWithReferenceData.product_id] withProductGroupId:[NSString stringWithFormat:@"%d", productWithReferenceData.group_id] withSplitGroupId:(NSString*)splitGroupId withDatabase:databaseLocal];
      self.sendNotification = notificationLocal;
      if(![existingInspectionStatus isEqualToString:@""]){
          self.inspectionStatus = existingInspectionStatus;
      }
      
      //if days remaining fails then status is reject
      if(self.failedDateValidation)
          self.inspectionStatus = INSPECTION_STATUS_REJECT;

      //TODO check the summary based on the
      [self checkInspectionStatus];
      NSString *userEnteredNot = [self getUserEnteredNotificationStatusFromDB:self.numberOfInspections withGroupId:groupId withAuditMasterId:auditMasterId withProductId:[NSString stringWithFormat:@"%d", productWithReferenceData.product_id] withProductGroupId:[NSString stringWithFormat:@"%d", productWithReferenceData.group_id] withSplitGroupId:(NSString*)splitGroupId withDatabase:databaseLocal];
      if (userEnteredNot && ![userEnteredNot isEqualToString:@""]) {
          self.sendNotification = [userEnteredNot integerValue];
      }else{
          if ([self.inspectionStatus isEqualToString:INSPECTION_STATUS_ACCEPT]) {
              self.sendNotification = NO;
          } else {
              self.sendNotification = YES;
          }
      }

      //fix count of cases after split - check if correct for distinct mode
      //if (self.totalCountOfCases < 1) {
          NSString *countOfCasesLocal = [Summary getCountOfCasesFromDB:self.numberOfInspections withGroupId:groupId withProductId:[NSString stringWithFormat:@"%d", productWithReferenceData.product_id] withSplitGroupId:(NSString*)splitGroupId withDatabase:databaseLocal];
          if (![countOfCasesLocal isEqualToString:@""] && countOfCasesLocal) {
              self.totalCountOfCases = [countOfCasesLocal integerValue];
              [self calculateAveragePercentageOfCases];
          } else {
              self.totalCountOfCases = 0;
          }
        NSString *inspectionCountOfCasesLocal = [Summary getInspectionCountOfCasesFromDB:self.numberOfInspections withGroupId:groupId withProductId:[NSString stringWithFormat:@"%d", productWithReferenceData.product_id] withSplitGroupId:(NSString*)splitGroupId withDatabase:databaseLocal];
      if (![inspectionCountOfCasesLocal isEqualToString:@""] && inspectionCountOfCasesLocal) {
          self.inspectionCountOfCases = [inspectionCountOfCasesLocal integerValue];
          [self calculateAveragePercentageOfCases];
      } else {
          self.inspectionCountOfCases = 0;
      }
      //}
      
      if (saveToDB) {
          [self saveSummaryToDBWithGroupId:groupId withAuditMasterId:auditMasterId withProductId:[NSString stringWithFormat:@"%d", productWithReferenceData.product_id] withProductGroupId:groupId withSplitGroupId:(NSString*)splitGroupId withDatabase:databaseLocal];
      }
  }

  - (void) calculateAveragePercentageOfCases {
      if (self.totalCountOfCases > 0) {
          if (self.numberOfInspections > 0) {
              //calculate percentage of cases
              float numerOfInsp = self.numberOfInspections;
              float totalCount = self.totalCountOfCases;
              float inspectionCount = self.inspectionCountOfCases;
              self.averagePercentageOfCases = (numerOfInsp/totalCount)*100;
              if(inspectionCount > 0)
              self.inspectionPercentageOfCases = (numerOfInsp/inspectionCount)*100;
          } else{
              self.averagePercentageOfCases = 0;
              self.inspectionPercentageOfCases = 0;
          }
      } else {
          self.averagePercentageOfCases = 0;
          self.inspectionPercentageOfCases = 0;
      }
  }
-(BOOL) isInspectionAcceptWithIssuesWithSeverityTotals:(NSArray*) totalsList{
    for(NSDictionary *dict in self.severityTotalThresholds){
        NSArray* defectIds = [dict objectForKey:@"defect_severity_ids"];
        float accept_total = [[dict objectForKey:@"accept_issues_total"] floatValue];
        float sev_accept_total = 0.0;
        int i = 0;
        while(i<defectIds.count){
            int defectId = [defectIds[i] intValue];
            for(Severity *sev in totalsList){
                if(defectId == sev.id){
                    sev_accept_total += sev.inputOrCalculatedPercentage;
                }
            }
            i += 1;
        }
        if(sev_accept_total > accept_total){
            return true;
        }
        
    }
    
    return false;
}

-(BOOL) isInspectionRejectWithSeverityTotals:(NSArray*) totalsList {
    for(NSDictionary *dict in self.severityTotalThresholds){
        NSArray* defectIds = [dict objectForKey:@"defect_severity_ids"];
        float reject_total = [[dict objectForKey:@"reject_total"] floatValue];
        float sev_reject_total = 0.0;
        int i = 0;
        while(i<defectIds.count){
            int defectId = [defectIds[i] intValue];
            for(Severity *sev in totalsList){
                if(defectId == sev.id){
                    sev_reject_total += sev.inputOrCalculatedPercentage;
                }
            }
            i += 1;
        }
        if(sev_reject_total > reject_total){
            return true;
        }
        
    }
    
    return false;
}

-(NSString*) getStatusBySeverityTotals:(NSString*) currentStatus withList: (NSArray*) totalsList{
    
        if ([self isInspectionRejectWithSeverityTotals:totalsList])
            return INSPECTION_STATUS_REJECT;
        else if([self isInspectionAcceptWithIssuesWithSeverityTotals:totalsList])
            currentStatus = INSPECTION_STATUS_ACCEPT_WITH_ISSUES;
        return currentStatus;
}
  - (float) calculateAveragePercentageOfCases: (int) countOfCasesLocal withInspectionSamples: (int) inspectionSamplesCount {
      float averagePercentageOfCasesLocal = 0;
      if (countOfCasesLocal > 0) {
          if (inspectionSamplesCount > 0) {
              //calculate percentage of cases
              float numerOfInsp = inspectionSamplesCount;
              float totalCount = countOfCasesLocal;
              averagePercentageOfCasesLocal = (numerOfInsp/totalCount)*100;
          }
      }
      return averagePercentageOfCasesLocal;
  }
- (float) calculateAverageInspectionPercentageOfCases: (int) countOfCasesLocal withInspectionSamples: (int) inspectionSamplesCount {
     float averagePercentageOfCasesLocal = 0;
     if (countOfCasesLocal > 0) {
         if (inspectionSamplesCount > 0) {
             //calculate percentage of cases
             float numerOfInsp = inspectionSamplesCount;
             float totalCount = countOfCasesLocal;
             averagePercentageOfCasesLocal = (numerOfInsp/totalCount)*100;
         }
     }
     return averagePercentageOfCasesLocal;
 }
  @end
