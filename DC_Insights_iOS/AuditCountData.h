//
//  AuditCountData.h
//  Insights
//
//  Created by Vineet Pareek on 27/08/2015.
//  Copyright (c) 2015 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AuditCountData : NSObject
@property (nonatomic, assign) NSInteger auditMinimumsBy;
@property (nonatomic, assign) NSInteger acceptRequired;
@property (nonatomic, assign) NSInteger acceptRecommended;
@property (nonatomic, assign) NSInteger acceptIssuesRequired;
@property (nonatomic, assign) NSInteger acceptIssuesRecommended;
@property (nonatomic, assign) NSInteger rejectRequired;
@property (nonatomic, assign) NSInteger rejectRecommended;
@end
