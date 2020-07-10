//
//  AuditApiData.m
//  DC_Insights_iOS
//
//  Created by Vineet Pareek on 4/17/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "AuditApiData.h"

@implementation AuditApiData

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        self.trackingCodes = [[AuditApiTrackingCodes alloc] init];
        self.audit = [[AuditApiDescriptor alloc] init];
        self.device = [[AuditApiDevice alloc] init];
        self.user = [[AuditApiUser alloc] init];
        self.location = [[AuditApiLocation alloc] init];
        self.submittedInfo = [[AuditApiSubmittedInfo alloc] init];
        self.summary = [[AuditApiSummary alloc] init];
        self.images = [[NSArray alloc] init];
        self.hptApi = [[HPTInspectionApi alloc] init];
    }
    return self;
}


@end
