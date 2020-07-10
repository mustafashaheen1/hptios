//
//  AuditApiSummaryDefect.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 4/24/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "JSONModel.h"
#import "AuditApiSummaryTotal.h"

@protocol AuditApiSummaryDefect
@end

@interface AuditApiSummaryDefect : JSONModel

@property (nonatomic, assign) NSInteger id;
@property (nonatomic, assign) NSInteger ratingId;
@property (nonatomic, strong) NSMutableArray<AuditApiSummaryTotal> *severities;

@end
