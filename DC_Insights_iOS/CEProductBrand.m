//
//  CEProductBrand.m
//  Insights
//
//  Created by Vineet Pareek on 18/10/2016.
//  Copyright © 2016 Yottamark. All rights reserved.
//

#import "CEProductBrand.h"

@implementation CEProductBrand

+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    if ([propertyName isEqualToString: @"name"]) return YES;
    if ([propertyName isEqualToString: @"image_url"]) return YES;
    return NO;
}

@end
