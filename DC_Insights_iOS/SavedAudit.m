//
//  SavedAudit.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 4/20/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "SavedAudit.h"
#import "NSUserDefaultsManager.h"
#import "Constants.h"
#import "InspectionMinimums.h"

@implementation SavedAudit

- (id)init
{
    self = [super init];
    if (self) {
        self.inspectionStatus = @"";
        self.countOfCases = 0;
        self.inspectionCountOfCases = 0;
        self.productName = @"";
        self.auditsCount = 0;
        self.productId = 0;
        self.productGroupId = 0;
        self.auditGroupId = 0;
        self.userEnteredAuditsCount = 0;
        self.poNumber = @"";
        self.supplierName = @"";
        self.auditCountData = [[AuditCountData alloc]init];
        self.splitGroupId=@"";
        self.isFlagged = NO;
        self.score = @"";
        self.allFlaggedProductMessages = [[NSMutableArray alloc]init];
        self.defects = [[NSMutableArray alloc]init];
        self.globalInspectionStatus = [[InspectionStatus alloc]init];
        self.previousInspectionStatus = @"";
        self.grn = @"";
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    SavedAudit *copy = (SavedAudit *) object;
//    if (self == copy)
//        return true;
//    if (![super isEqual:copy])
//        return false;
//    if ([self class] != [copy class])
//        return false;
    if(self.productId == copy.productId) {
        return true;
    }
    else
        return false;
}

- (NSUInteger)hash {
    const NSUInteger prime = 31;
    NSUInteger result = 1;
    NSInteger copy = self.productId;
    result = prime * result + copy;
    return result;
}

-(IMResult*)getResultForInspectionMinimum:(InspectionMinimums*)inspectionMinimum {
    //InspectionMinimums *inspectionMinimum = [self populateInspectionMinimumsArray];

    //to check by count
    float auditCount = 0;
    if (self.userEnteredAuditsCount > 0) {
        auditCount = self.userEnteredAuditsCount;
    } else {
        auditCount = self.auditsCount;
        if(self.inspectionStatus==nil || [self.inspectionStatus isEqualToString:@""])
            self.inspectionStatus = INSPECTION_STATUS_ACCEPT;
    }
    //to check by percentage
    float auditCountPercentage = 0;
    float countOfCases = self.countOfCases;
    if(self.countOfCases>0)
        auditCountPercentage = (float)((auditCount/countOfCases)*100.0f);
    //to show percentage in text
    NSString *unit = @"";
    //if need to calculate based on percentage
    if(self.auditCountData.auditMinimumsBy==1){
        auditCount = auditCountPercentage;
        unit = @"%";
    }
    
    return [inspectionMinimum getResultForAuditCount:auditCount withTotalCount:countOfCases withInspectionStatus:self.inspectionStatus];
}
/*
-(InspectionMinimums*)populateInspectionMinimumsArray {
    InspectionMinimums* inspectionMinimum = [[InspectionMinimums alloc]init];
    //read from /groups
    NSString *queryAuditCount = [NSString stringWithFormat:@"SELECT %@ FROM %@ WHERE %@=%@", COL_INSPECTION_MINIMUMS_ID, TBL_GROUPS, COL_ID, [NSString stringWithFormat:@"%d", self.productGroupId]];
    FMDatabase *databaseGroupRatings = [[DBManager sharedDBManager] openDatabase:DB_INSIGHTS_DATA];
    FMResultSet *resultsGroupRatings;
    [databaseGroupRatings open];
    resultsGroupRatings = [databaseGroupRatings executeQuery:queryAuditCount];
    int inspectionMinimumId = -1;
    while ([resultsGroupRatings next]) {
        inspectionMinimumId = [resultsGroupRatings intForColumn:COL_INSPECTION_MINIMUMS_ID];
    }
    
    //read from /programs
    if(inspectionMinimumId<=0){
        int programId = [NSUserDefaultsManager getIntegerFromUserDeafults:SelectedProgramId];
        NSString *queryAuditCount = [NSString stringWithFormat:@"SELECT %@ FROM %@ WHERE %@=%@", COL_INSPECTION_MINIMUMS_ID, TBL_PROGRAMS, COL_ID, [NSString stringWithFormat:@"%d", programId]];
        FMDatabase *databaseGroupRatings = [[DBManager sharedDBManager] openDatabase:DB_INSIGHTS_DATA];
        FMResultSet *resultsGroupRatings;
        [databaseGroupRatings open];
        resultsGroupRatings = [databaseGroupRatings executeQuery:queryAuditCount];
        while ([resultsGroupRatings next]) {
            inspectionMinimumId = [resultsGroupRatings intForColumn:COL_INSPECTION_MINIMUMS_ID];
        }
    }
    
    //parse the minimums array and store in self
    
    if(inspectionMinimumId>0){
        NSString *queryAuditCount = [NSString stringWithFormat:@"SELECT %@ FROM %@ WHERE %@=%@", COL_INSPECTION_MINIMUMS, TBL_INSPECTION_MINIMUMS, COL_ID, [NSString stringWithFormat:@"%d", inspectionMinimumId]];
        FMDatabase *databaseGroupRatings = [[DBManager sharedDBManager] openDatabase:DB_INSIGHTS_DATA];
        FMResultSet *resultsGroupRatings;
        [databaseGroupRatings open];
        resultsGroupRatings = [databaseGroupRatings executeQuery:queryAuditCount];
        while ([resultsGroupRatings next]) {
            NSString* json = [resultsGroupRatings stringForColumn:COL_INSPECTION_MINIMUMS];
            NSError *error;
            inspectionMinimum = [[InspectionMinimums alloc]initWithString:json error:&error];
        }
    }
    return inspectionMinimum;
}
*/


-(void)populateAuditCounts{
    NSString *queryAuditCount = [NSString stringWithFormat:@"SELECT %@ FROM %@ WHERE %@=%@", COL_AUDIT_COUNT_DATA, TBL_GROUPS, COL_ID, [NSString stringWithFormat:@"%d", self.productGroupId]];
    FMDatabase *databaseGroupRatings = [[DBManager sharedDBManager] openDatabase:DB_INSIGHTS_DATA];
    FMResultSet *resultsGroupRatings;
    [databaseGroupRatings open];
    resultsGroupRatings = [databaseGroupRatings executeQuery:queryAuditCount];
    while ([resultsGroupRatings next]) {
         NSData* data = [resultsGroupRatings dataForColumn:COL_AUDIT_COUNT_DATA];
         NSDictionary* dict = [[NSDictionary alloc]init];
         if(data!=nil) {
         dict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
             //NSLog(@"Dictionary: %@", [dict description]);
         //self.auditCountData.audit_count_data = dict;
         self.auditCountData.auditMinimumsBy = [ParseJsonUtil parseIntegerFromJson:dict key:@"auditMinimumsBy"];
         self.auditCountData.acceptRequired = [ParseJsonUtil parseIntegerFromJson:dict key:@"acceptRequired"];
         self.auditCountData.acceptRecommended = [ParseJsonUtil parseIntegerFromJson:dict key:@"acceptRecommended"];
         self.auditCountData.acceptIssuesRequired = [ParseJsonUtil parseIntegerFromJson:dict key:@"acceptIssuesRequired"];
         self.auditCountData.acceptIssuesRecommended = [ParseJsonUtil parseIntegerFromJson:dict key:@"acceptIssuesRecommended"];
         self.auditCountData.rejectRequired = [ParseJsonUtil parseIntegerFromJson:dict key:@"rejectRequired"];
         self.auditCountData.rejectRecommended = [ParseJsonUtil parseIntegerFromJson:dict key:@"rejectRecommended"];
         }
    }
    [databaseGroupRatings close];
}

//Old implementation of inspection minimums - replaced by Tiered inspection Minimums
/*
-(NSString*) getWarningMessage {
    NSString *accept =  @"Accept";
    NSString *acceptWithIssues =@"Accept With Issues";
    NSString *reject =@"Reject";
    //to check by count
    float auditCount = 0;
    if (self.userEnteredAuditsCount > 0) {
        auditCount = self.userEnteredAuditsCount;
    } else {
        auditCount = self.auditsCount;
        if(self.inspectionStatus==nil || [self.inspectionStatus isEqualToString:@""])
        self.inspectionStatus = accept;
    }
    //to check by percentage
    float auditCountPercentage = 0;
    float countOfCases = self.countOfCases;
    if(self.countOfCases>0)
    auditCountPercentage = (float)((auditCount/countOfCases)*100.0f);
    //to show percentage in text
    NSString *unit = @"";
    //if need to calculate based on percentage
    if(self.auditCountData.auditMinimumsBy==1){
        auditCount = auditCountPercentage;
        unit = @"%";
    }
    
    if([self.inspectionStatus isEqualToString:accept]){
        if(auditCount<self.auditCountData.acceptRequired)
            return [NSString stringWithFormat:@"%ld%@ inspections are required",self.auditCountData.acceptRequired,unit];
        else if(auditCount<self.auditCountData.acceptRecommended)
            return [NSString stringWithFormat:@"%ld%@ inspections are recommended",self.auditCountData.acceptRecommended,unit];
    }else if([self.inspectionStatus isEqualToString:acceptWithIssues]){
        if(auditCount<self.auditCountData.acceptIssuesRequired)
            return [NSString stringWithFormat:@"%ld%@ inspections are required",self.auditCountData.acceptIssuesRequired,unit];
        else if(auditCount<self.auditCountData.acceptIssuesRecommended)
            return [NSString stringWithFormat:@"%ld%@ inspections are recommended",self.auditCountData.acceptIssuesRecommended,unit];
    }else if([self.inspectionStatus isEqualToString:reject]){
        if(auditCount<self.auditCountData.rejectRequired)
            return [NSString stringWithFormat:@"%ld%@ inspections are required",self.auditCountData.rejectRequired,unit];
        else if(auditCount<self.auditCountData.rejectRecommended)
            return [NSString stringWithFormat:@"%ld%@ inspections are recommended",self.auditCountData.rejectRecommended,unit];
    }
    return @"default"; //ideally return a data-structure with boolean+message
}
*/
@end
