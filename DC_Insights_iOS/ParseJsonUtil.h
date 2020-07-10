//
//  ParseJsonUtil.h
//  Insights
//
//  Created by Vineet Pareek on 27/08/2015.
//  Copyright (c) 2015 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParseJsonUtil : NSObject

+ (NSString*) parseStringFromJson:(NSDictionary*)data key:(NSString*)key;
+ (NSInteger) parseIntegerFromJson:(NSDictionary*)data key:(NSString*)key;
+ (double) parseDoubleFromJson:(NSDictionary*)data key:(NSString*)key;
+ (BOOL) parseBoolFromJson:(NSDictionary*)data key:(NSString*)key;
+ (NSDate*) parseDateFromJson:(NSDictionary*)data key:(NSString*)key;
+ (NSArray*) parseArrayFromJson:(NSDictionary*)data key:(NSString*)key;
+ (NSDictionary*) parseDictFromJson:(NSDictionary*)data key:(NSString*)key;
+ (NSString *)asCommaSeparatedString:(NSArray *)items;

@end
