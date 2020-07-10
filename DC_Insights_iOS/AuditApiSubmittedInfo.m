//
//  AuditApiSubmittedInfo.m
//  DC_Insights_iOS
//
//  Created by Vineet Pareek on 4/17/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "AuditApiSubmittedInfo.h"

@implementation AuditApiSubmittedInfo

- (id)init
{
    self = [super init];
    if (self) {
        self.program = [[AuditApiProgram alloc] init];
        self.product = [[AuditApiProduct alloc] init];
        NSArray *containerRatingsLocal = [[NSArray alloc] init];
        NSArray *productRatingsLocal = [[NSArray alloc] init];
        self.containerRatings = (NSArray <AuditApiContainerRating>*)containerRatingsLocal;
        self.productRatings = (NSArray <AuditApiRating>*)productRatingsLocal;
        self.duplicates = [[AuditApiDuplicate alloc] init];
    }
    return self;
}

@end
