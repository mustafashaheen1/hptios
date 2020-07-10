//
//  CEProduct.m
//  Insights
//
//  Created by Vineet Pareek on 18/10/2016.
//  Copyright © 2016 Yottamark. All rights reserved.
//

#import "CEProduct.h"

@implementation CEProduct

+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    if ([propertyName isEqualToString: @"name"]) return YES;
    if ([propertyName isEqualToString: @"image_url"]) return YES;
    if ([propertyName isEqualToString: @"upc"]) return YES;
    if ([propertyName isEqualToString: @"commodity"]) return YES;
    if ([propertyName isEqualToString: @"brand"]) return YES;
    return NO;
}

@end
