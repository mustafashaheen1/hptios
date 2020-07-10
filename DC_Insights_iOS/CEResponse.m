//
//  CEResponse.m
//  Insights
//
//  Created by Vineet Pareek on 17/10/2016.
//  Copyright © 2016 Yottamark. All rights reserved.
//

#import "CEResponse.h"

@implementation CEResponse

+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    if ([propertyName isEqualToString: @"code"]) return YES;
    return NO;
}

@end
