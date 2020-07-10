//
//  CEProductBrandCompany.m
//  Insights
//
//  Created by Vineet Pareek on 18/10/2016.
//  Copyright © 2016 Yottamark. All rights reserved.
//

#import "CEProductBrandCompany.h"

@implementation CEProductBrandCompany

+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    if ([propertyName isEqualToString: @"name"]) return YES;
    return NO;
}

@end
