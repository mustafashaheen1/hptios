//
//  AuditApiDefect.m
//  DC_Insights_iOS
//
//  Created by Vineet Pareek on 4/15/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "AuditApiDefect.h"

@implementation AuditApiDefect

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        self.id = 0;
        self.present = NO;
        self.group_id = 0;
        NSArray *allSeveritiesLocal = [[NSArray alloc] init];
        self.severities = (NSArray <AuditApiSeverity>*)allSeveritiesLocal;
        
    }
    return self;
}

@end
