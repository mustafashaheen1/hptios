//
//  InspectionMinimums.h
//  Insights
//
//  Created by Vineet on 2/12/18.
//  Copyright © 2018 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMRange.h"
#import "JSONModel.h"
#import "IMResult.h"

@protocol InspectionMinimums
@end

@interface InspectionMinimums : JSONModel
@property (atomic, assign) int id;
@property (atomic, assign) int rating_id;
@property (atomic, strong) NSString *name;
@property (atomic,strong) NSMutableArray<IMRange>* ranges;


-(IMResult*)getResultForAuditCount:(int)auditCount withTotalCount:(int)totalCount withInspectionStatus:(NSString*)inspStatus;
-(int)getRequiredSampleCountForAudit:(int)auditCount withTotalCases:(int)totalCases;
@end
