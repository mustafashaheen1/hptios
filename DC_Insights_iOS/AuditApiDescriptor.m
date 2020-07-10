//
//  AuditApiDescriptor.m
//  DC_Insights_iOS
//
//  Created by Vineet Pareek on 4/17/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "AuditApiDescriptor.h"

@implementation AuditApiDescriptor

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        self.start = @"";
        self.end = @"";
        self.timezone = @"";
        self.id = @"";
    }
    return self;
}

-(NSString*)getTransactionId{
    NSString* auditId = self.id;
    NSString* transactionId = @"";
    if (auditId) {
        NSArray *individualIds = [auditId componentsSeparatedByString:@"-"];
        if([individualIds count]==4)
            transactionId = [individualIds objectAtIndex:3];
    }
    return transactionId;
}

-(void)updateTransacationIdWithId:(NSString*)newTransactionId{
    NSString* auditId = self.id;
    if (auditId) {
        NSArray *individualIds = [auditId componentsSeparatedByString:@"-"];
        NSMutableArray* individualIdsCopy = [individualIds mutableCopy];
        NSString* transactionId = [individualIds objectAtIndex:3];
        [individualIdsCopy replaceObjectAtIndex:3 withObject:newTransactionId];
        self.id =  [individualIdsCopy componentsJoinedByString:@"-"];
    }
}


@end

