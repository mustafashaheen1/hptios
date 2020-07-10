//
//  AuditApiSummaryDefect.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 4/24/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "AuditApiSummaryDefect.h"

@implementation AuditApiSummaryDefect

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        self.id = 0;
        self.ratingId = 0;
        NSMutableArray *defectsLocal = [[NSMutableArray alloc] init];
        self.severities = (NSMutableArray <AuditApiSummaryTotal>*) defectsLocal;
    }
    return self;
}


@end
