//
//  CEEventAttribute.m
//  Insights
//
//  Created by Vineet Pareek on 18/10/2016.
//  Copyright © 2016 Yottamark. All rights reserved.
//

#import "CEEventAttribute.h"
#import "Constants.h"

@implementation CEEventAttribute

+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    if ([propertyName isEqualToString: @"name"]) return YES;
    return NO;
}

-(double)getHeightWithFont:(UIFont*)font withFrameWidth:(double)width{
    double height = CE_EVENT_ATTRIBUTE_VALUE_ROW_HEIGHT;//for the name
    for(NSString* attributeValue in self.value){
        CGSize textSize = [attributeValue sizeWithFont:font];
        if(textSize.width > width)
            height+=CE_EVENT_ATTRIBUTE_VALUE_ROW_HEIGHT;
        
        height+=CE_EVENT_ATTRIBUTE_VALUE_ROW_HEIGHT;
    }
    return height;
}

@end
