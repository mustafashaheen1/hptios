//
//  AuditApiProduct.m
//  DC_Insights_iOS
//
//  Created by Vineet Pareek on 4/17/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "AuditApiProduct.h"

@implementation AuditApiProduct

- (id)init
{
    self = [super init];
    if (self) {
        self.itemNumber = @" ";
        self.id = 0;
       // self.score = @"";
    }
    return self;
}

@end
