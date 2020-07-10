//
//  AuditApiRating.m
//  DC_Insights_iOS
//
//  Created by Vineet Pareek on 4/17/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "AuditApiRating.h"

@implementation AuditApiRating

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        self.id = 0;
        self.value = @"";
        self.type = @"";
        NSArray *allDefectsLocal = [[NSArray alloc] init];
        self.defects = (NSArray <AuditApiDefect>*)allDefectsLocal;
    }
    return self;
}

@end
