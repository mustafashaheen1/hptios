//
//  ParseJsonUtil.m
//  Insights
//
//  Created by Vineet Pareek on 27/08/2015.
//  Copyright (c) 2015 Yottamark. All rights reserved.
//

#import "ParseJsonUtil.h"

@implementation ParseJsonUtil

/*------------------------------------------------------------------------------
 METHOD: parseStringFromJson
 
 PURPOSE:
 Helper method used to parse a value from JSON data into an NSString.  Handles
 various flavors of "null" representations.
 -----------------------------------------------------------------------------*/
+ (NSString*) parseStringFromJson:(NSDictionary*)data key:(NSString*)key
{
    if (!data || !key) return nil;
    
    id rawValue = [data objectForKey:key];
    if (!rawValue) return nil;
    if ([rawValue isKindOfClass:[NSNull class]]) return nil;
    if ([rawValue isKindOfClass:[NSString class]] && [rawValue isEqualToString:@"<null>"]) return nil;
    if ([rawValue isKindOfClass:[NSString class]] && [rawValue isEqualToString:@"null"]) return nil;
    if ([rawValue isKindOfClass:[NSString class]] && [rawValue isEqualToString:@"(null)"]) return nil;
    
    if (![rawValue isKindOfClass:[NSString class]]) {
        rawValue = [rawValue stringValue];
    }
    
    return rawValue;
}


/*------------------------------------------------------------------------------
 METHOD: parseIntegerFromJson
 
 PURPOSE:
 Helper method used to parse a value from JSON data into an NSInterger.  Handles
 various flavors of "null" representations, defaults to -1
 -----------------------------------------------------------------------------*/
+ (NSInteger) parseIntegerFromJson:(NSDictionary*)data key:(NSString*)key
{
    NSInteger theInteger = -1;
    
    NSString *integerAsString = [self parseStringFromJson:data key:key];
    if (integerAsString != nil) {
        theInteger = [integerAsString integerValue];
    }
    
    return theInteger;
}


/*------------------------------------------------------------------------------
 METHOD: parseIntegerFromJson
 
 PURPOSE:
 Helper method used to parse a value from JSON data into an NSInterger.  Handles
 various flavors of "null" representations, defaults to -1
 -----------------------------------------------------------------------------*/
+ (double) parseDoubleFromJson:(NSDictionary*)data key:(NSString*)key
{
    double theDouble = -1;
    
    NSString *doubleAsString = [self parseStringFromJson:data key:key];
    if (doubleAsString != nil) {
        theDouble = [doubleAsString doubleValue];
    }
    
    return theDouble;
}



/*------------------------------------------------------------------------------
 METHOD: parseBoolFromJson
 
 PURPOSE:
 Helper method used to parse a value from JSON data into a BOOL.  Handles
 various flavors of "null" representations, defaults to NO
 -----------------------------------------------------------------------------*/

+ (BOOL) parseBoolFromJson:(NSDictionary*)data key:(NSString*)key
{
    BOOL theBool = NO;
    
    NSString *boolAsString = [self parseStringFromJson:data key:key];
    if (boolAsString != nil) {
        theBool = [boolAsString boolValue];
    }
    
    return theBool;
}


/*------------------------------------------------------------------------------
 METHOD: parseDateFromJson
 
 PURPOSE:
 Helper method used to parse a value from JSON data into an NSDate.  Assumes
 RFC3339 formatted dates, which is the format used by the ShopWell server
 -----------------------------------------------------------------------------*/
+ (NSDate*) parseDateFromJson:(NSDictionary*)data key:(NSString*)key
{
    NSDate *theDate = nil;
    NSString *dateAsString = [self parseStringFromJson:data key:key];
    
    if (dateAsString) {
        static NSDateFormatter *rfc3339DateFormatter;
        if (rfc3339DateFormatter == nil) {
            rfc3339DateFormatter = [[NSDateFormatter alloc] init];
            [rfc3339DateFormatter setDateFormat:@"yyyy-MM-dd"];
            //[rfc3339DateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        }
        
        theDate = [rfc3339DateFormatter dateFromString:dateAsString];
    }
    
    return theDate;
}

/*------------------------------------------------------------------------------
 METHOD: parseArrayFromJson
 
 PURPOSE:
 Helper method used to parse a value from JSON data into an Array.
 -----------------------------------------------------------------------------*/
+ (NSArray*) parseArrayFromJson:(NSDictionary*)data key:(NSString*)key
{
    NSArray *theArray = [NSMutableArray arrayWithCapacity:0];
    
    id rawValue = [data objectForKey:key];
    if (rawValue != nil && [rawValue isKindOfClass:[NSArray class]]) {
        theArray = (NSArray *)rawValue;
    }
    
    return theArray;
}


/*------------------------------------------------------------------------------
 METHOD: parseDictFromJson
 
 PURPOSE:
 Helper method used to parse a value from JSON data into an Array.
 -----------------------------------------------------------------------------*/
+ (NSDictionary*) parseDictFromJson:(NSDictionary*)data key:(NSString*)key
{
    NSDictionary *theDictionary = [NSMutableDictionary dictionaryWithCapacity:0];
    
    id rawValue = [data objectForKey:key];
    if (rawValue != nil && [rawValue isKindOfClass:[NSDictionary class]]) {
        theDictionary = (NSDictionary *)rawValue;
    }
    
    return theDictionary;
}


/*------------------------------------------------------------------------------
 METHOD: asCommaSeparatedString
 
 PURPOSE:
 Helper method used to create a comma separated string from the specified
 NSArray of items.  Helpful in some POST operations.
 -----------------------------------------------------------------------------*/
+ (NSString *)asCommaSeparatedString:(NSArray *)items
{
    NSString *commaSeparatedString = @"";
    
    BOOL isFirst = YES;
    for (id item in items) {
        if (isFirst) {
            commaSeparatedString = [NSString stringWithFormat:@"%@%@", commaSeparatedString, item];
            isFirst = NO;
        } else {
            commaSeparatedString = [NSString stringWithFormat:@"%@,%@", commaSeparatedString, item];
        }
    }
    
    return commaSeparatedString;
}

@end
