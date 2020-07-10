//
//  AuditApiContainerRating.m
//  DC_Insights_iOS
//
//  Created by Vineet Pareek on 4/11/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "AuditApiContainerRating.h"

@implementation AuditApiContainerRating

- (id)init
{
    self = [super init];
    if (self) {
        self.id = 0;
        self.container_id = 0;
        self.value = @"";
        NSArray *containerDefectsLocal = [[NSArray alloc] init];
        self.defects = (NSArray <AuditApiDefect>*)containerDefectsLocal;
    }
    return self;
}

@end
