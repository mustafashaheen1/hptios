//
//  AuditApiData.h
//  DC_Insights_iOS
//
//  Created by Vineet Pareek on 4/17/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "JSONModel.h"
#import "AuditApiTrackingCodes.h"
#import "AuditApiDescriptor.h"
#import "AuditApiDevice.h"
#import "AuditApiUser.h"
#import "AuditApiLocation.h"
#import "AuditApiSubmittedInfo.h"
#import "AuditApiContainerRating.h"
#import "AuditApiSummary.h"
#import "HPTInspectionApi.h"
@protocol AuditApiData

@end

@interface AuditApiData : JSONModel

@property (nonatomic, strong) AuditApiTrackingCodes *trackingCodes;
@property (nonatomic, strong) AuditApiDescriptor *audit;
@property (nonatomic, strong) AuditApiDevice *device;
@property (nonatomic, strong) AuditApiUser *user;
@property (nonatomic, strong) AuditApiLocation *location;
@property (nonatomic, strong) AuditApiSubmittedInfo *submittedInfo;
@property (nonatomic, strong) AuditApiSummary *summary;
@property (nonatomic, strong) HPTInspectionApi *hptApi;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, assign) BOOL duplicate;

@end

