//
//  AuditApiSeverity.m
//  Insights-Trimble-Enterprise
//
//  Created by Mustafa Shaheen on 11/1/19.
//  Copyright © 2019 Yottamark. All rights reserved.
//

#import "AuditApiSeverity.h"

@implementation AuditApiSeverity

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        self.severity = @"";
        self.isSelected = NO;
        self.denominator = 0;
        self.numerator = 0;
        self.percentage = 0;
    }
    return self;
}

@end
