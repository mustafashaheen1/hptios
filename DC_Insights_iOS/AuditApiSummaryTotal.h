//
//  AuditApiSummaryTotal.h
//  DC_Insights_iOS
//
//  Created by Vineet Pareek on 4/17/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "JSONModel.h"

@protocol AuditApiSummaryTotal
@end

@interface AuditApiSummaryTotal : JSONModel

@property (nonatomic, assign) NSInteger id;
@property (nonatomic, assign) float total;

@end

