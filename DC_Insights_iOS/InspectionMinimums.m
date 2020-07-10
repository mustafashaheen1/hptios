//
//  InspectionMinimums.m
//  Insights
//
//  Created by Vineet on 2/12/18.
//  Copyright © 2018 Yottamark. All rights reserved.
//

#import "InspectionMinimums.h"

@implementation InspectionMinimums

-(IMResult*)getResultForAuditCount:(int)auditCount withTotalCount:(int)totalCount withInspectionStatus:(NSString*)inspStatus {
    IMRange *range = [self getRangeForAuditCount:auditCount withTotalCount:totalCount];
    if(range){
        float finalCount = 0;
        if(range.minimums_by == MINIMUMS_BY_COUNT){
            finalCount = auditCount;
        }else if(range.minimums_by == MINIMUMS_BY_PRECENTAGE){
            float percentage = 0;
            if(totalCount>0)
                percentage = (float)(((float)auditCount/(float)totalCount)*100.0f);
            finalCount = percentage;
        }
        //float finalCount = [self calculateCountForRange:range withAuditCount:auditCount withTotalCount:totalCount];
        return [range getResultForCount:finalCount withInspectionStatus:inspStatus statusBy:range.minimums_by];
    }
    return nil;
}

//find the range
-(IMRange*)getRangeForAuditCount:(int)auditCount withTotalCount:(int)totalCount{
    if(self.ranges){
        for(IMRange *range in self.ranges){
            int from = range.from;
            int to = range.to;
            if(from == -1)
                from = 0;
            if(to == -1)
                to = INT_MAX;
            if(totalCount>=from && totalCount <=to)
               return range;
        }
    }
    return nil;
}

-(int) calculateCountForRange:(IMRange*)range withAuditCount:(int)auditCount withTotalCount:(int)totalCount{
     float finalCount = 0;
     if(range){
        if(range.minimums_by == MINIMUMS_BY_COUNT){
            finalCount = auditCount;
        }else if(range.minimums_by == MINIMUMS_BY_PRECENTAGE){
            float percentage = 0;
            if(totalCount>0)
                percentage = (float)(((float)auditCount/(float)totalCount)*100.0f);
            finalCount = percentage;
        }
    }
    return finalCount;
}

-(int)getRequiredSampleCountForAudit:(int)auditCount withTotalCases:(int)totalCases {
     IMRange *range = [self getRangeForAuditCount:auditCount withTotalCount:totalCases];
     float finalCount = [self calculateCountForRange:range withAuditCount:auditCount withTotalCount:totalCases];
     return finalCount;
}

@end
