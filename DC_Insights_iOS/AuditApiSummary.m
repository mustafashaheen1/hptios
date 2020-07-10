//
//  AuditApiSummary.m
//  DC_Insights_iOS
//
//  Created by Vineet Pareek on 4/17/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "AuditApiSummary.h"

@implementation AuditApiSummary

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        self.inspectionSamples = 0;
        self.percentageOfCases = 0;
        self.inspectionCases = 0;
        self.inspectionPercentageOfCases = 0;
        self.inspectionStatus = @"";
        NSArray *defectsSummaryLocal = [[NSArray alloc] init];
        NSArray *totalsLocal = [[NSArray alloc] init];
        self.sendNotification = NO;
        self.defectsSummary = (NSArray <AuditApiSummaryDefect>*)defectsSummaryLocal;
        self.totals = (NSArray <AuditApiSummaryTotal>*)totalsLocal;
        self.auditGroupIds = [[NSArray alloc]init];
        self.failedDateValidation = NO;
    }
    return self;
}


@end
