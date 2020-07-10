//
//  AuditApiSummary.h
//  DC_Insights_iOS
//
//  Created by Vineet Pareek on 4/17/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "JSONModel.h"
#import "AuditApiSummaryDefect.h"
#import "AuditApiSummaryTotal.h"


@interface AuditApiSummary : JSONModel
@property (nonatomic, assign) NSInteger inspectionSamples;
@property (nonatomic, assign) NSInteger totalCases;
@property (nonatomic, assign) NSInteger inspectionCases;
@property (nonatomic, assign) float percentageOfCases;
@property (nonatomic, assign) float inspectionPercentageOfCases;
@property (nonatomic, assign) NSString<Optional> *inspectionStatus;
@property (nonatomic, strong) NSArray<AuditApiSummaryTotal,Optional>* totals;
@property (nonatomic, strong) NSArray<AuditApiSummaryDefect,Optional>* defectsSummary;
@property (nonatomic, strong) NSArray *auditGroupIds;
@property (nonatomic, assign) BOOL sendNotification;
@property (nonatomic, assign) BOOL failedDateValidation;
@end
