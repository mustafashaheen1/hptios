//
//  CEEvent.m
//  Insights
//
//  Created by Vineet Pareek on 18/10/2016.
//  Copyright © 2016 Yottamark. All rights reserved.
//

#import "CEEvent.h"

@implementation CEEvent

+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    if ([propertyName isEqualToString: @"name"]) return YES;
    if ([propertyName isEqualToString: @"date"]) return YES;
    return NO;
}

@end
