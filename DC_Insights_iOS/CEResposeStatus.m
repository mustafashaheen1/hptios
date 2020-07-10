//
//  CEResposeStatus.m
//  Insights
//
//  Created by Vineet Pareek on 2/11/2016.
//  Copyright © 2016 Yottamark. All rights reserved.
//

#import "CEResposeStatus.h"

@implementation CEResposeStatus

+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    if ([propertyName isEqualToString: @"message"])
        return YES;
    return NO;
}

@end
