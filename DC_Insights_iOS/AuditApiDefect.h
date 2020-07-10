//
//  AuditApiDefect.h
//  DC_Insights_iOS
//
//  Created by Vineet Pareek on 4/15/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
#import "AuditApiSeverity.h"
@protocol AuditApiDefect
@end

@interface AuditApiDefect : JSONModel

@property (nonatomic, assign) NSInteger id;
@property (nonatomic, assign) NSInteger group_id;
@property (nonatomic, assign) BOOL present;
@property (nonatomic, strong) NSArray<AuditApiSeverity>* severities;

@end
