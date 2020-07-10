//
//  AuditCountData.m
//  Insights
//
//  Created by Vineet Pareek on 27/08/2015.
//  Copyright (c) 2015 Yottamark. All rights reserved.
//

#import "AuditCountData.h"

@implementation AuditCountData

- (id)init
{
    self = [super init];
    if (self) {
        self.auditMinimumsBy = 0;
        self.acceptRequired = 0;
        self.acceptRecommended = 0;
        self.acceptIssuesRequired = 0;
        self.acceptIssuesRecommended = 0;
        self.rejectRequired = 0;
        self.rejectRecommended = 0;
    }
    return self;
}


@end
