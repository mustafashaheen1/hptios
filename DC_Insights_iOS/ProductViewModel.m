//
//  ProductViewModel.m
//  Insights
//
//  Created by Vineet on 10/3/18.
//  Copyright © 2018 Yottamark. All rights reserved.
//

#import "ProductViewModel.h"

@implementation ProductViewModel

-(id)init{
    self = [super init];
    return self;
}

-(InspectionMinimums*) getRequiredSampleCountWithGroupId:(int)groupId {
    InspectionMinimumsAPI* inspectionMinimum = [[InspectionMinimumsAPI alloc]init];
    InspectionMinimums *minimums = [inspectionMinimum getMinimumInspectionForGroup:groupId];
    
    //IMResult* inspectionMinimumsResult = [savedAudit getResultForInspectionMinimum:minimums];
    //float finalCount = [minimums getRequiredSampleCountForAudit:1 withTotalCases:currentAudit.countOfCasesFromSavedAudit]
    return minimums;
}

@end
