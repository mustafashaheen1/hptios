//
//  CEHistory.m
//  Insights
//
//  Created by Vineet Pareek on 19/10/2016.
//  Copyright © 2016 Yottamark. All rights reserved.
//

#import "CEHistory.h"


@implementation CEHistory

- (id)init
{
    self = [super init];
    if (self) {
        self.date = @"";
        self.hmCode = @"";
        self.productName = @"";
    }
    return self;
}

+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    if ([propertyName isEqualToString: @"date"]) return YES;
    if ([propertyName isEqualToString: @"hmCode"]) return YES;
    if ([propertyName isEqualToString: @"productName"]) return YES;
    return NO;
}

@end
