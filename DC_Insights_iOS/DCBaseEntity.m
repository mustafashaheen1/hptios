//
//  DCBaseEntity.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/5/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "DCBaseEntity.h"
#import "LocationManager.h"

@implementation DCBaseEntity

/*------------------------------------------------------------------------------
 METHOD: parseStringFromJson
 
 PURPOSE:
 Helper method used to parse a value from JSON data into an NSString.  Handles
 various flavors of "null" representations.
 -----------------------------------------------------------------------------*/

- (NSString*) parseStringFromJson:(NSDictionary*)data key:(NSString*)key
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
- (NSInteger) parseIntegerFromJson:(NSDictionary*)data key:(NSString*)key
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
- (double) parseDoubleFromJson:(NSDictionary*)data key:(NSString*)key
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

- (BOOL) parseBoolFromJson:(NSDictionary*)data key:(NSString*)key
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
- (NSDate*) parseDateFromJson:(NSDictionary*)data key:(NSString*)key
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
- (NSArray*) parseArrayFromJson:(NSDictionary*)data key:(NSString*)key
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
- (NSDictionary*) parseDictFromJson:(NSDictionary*)data key:(NSString*)key
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
- (NSString *)asCommaSeparatedString:(NSArray *)items
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


/*------------------------------------------------------------------------------
 METHOD: ParamtersFortheGETCall
 
 PURPOSE:
 Auth token and device ID paramters for the GET call
 -----------------------------------------------------------------------------*/

- (NSDictionary *) paramtersFortheGETCall{
    //NSLog(@"[DeviceManager getDeviceID] %@", [DeviceManager getDeviceID]);
    //NSArray *values = @[@"sotJjiqygkNyPBostbu9", @"D8C2E73A-954A-4FE8-8BBE-0F5BFDC833DA"];
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSArray *keys;

    if(([bundleIdentifier isEqualToString:@"com.trimble.harvestmark.enterprise.inventory"]) || ([bundleIdentifier isEqualToString:@"com.trimble.harvestmark.insights"]) || ([bundleIdentifier isEqualToString:@"com.trimble.harvestmark.enterprise.insights"]) || ([bundleIdentifier isEqualToString:@"com.trimble.harvestmark.inventory"]))
    {
       keys = @[@"auth_token", DEVICE_ID,@"program_type_id"];
        
    }else{
        keys = @[@"auth_token", DEVICE_ID];
    }
    
    
    NSArray *values;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"]) {
        if(([bundleIdentifier isEqualToString:@"com.trimble.harvestmark.enterprise.inventory"]) || ([bundleIdentifier isEqualToString:@"com.trimble.harvestmark.inventory"]))
        {
            values = @[[[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"], [DeviceManager getDeviceID], INVENTORY_PROGRAM_TYPE];
        } else if(([bundleIdentifier isEqualToString:@"com.trimble.harvestmark.insights"]) || ([bundleIdentifier isEqualToString:@"com.trimble.harvestmark.enterprise.insights"]))
        {
            values = @[[[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"], [DeviceManager getDeviceID], INSIGHTS_PROGRAM_TYPE];
        }else{
            values = @[[[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"], [DeviceManager getDeviceID]];
        }
    }
    NSDictionary *parametersLocal;
    if (values && keys) {
        parametersLocal = [[NSDictionary alloc] initWithObjects:values forKeys:keys];
    }
    return parametersLocal;
}



- (NSDictionary *) paramtersFortheGETCallWithLatLon {
    //NSLog(@"[DeviceManager getDeviceID] %@", [DeviceManager getDeviceID]);
    //NSArray *values = @[@"sotJjiqygkNyPBostbu9", @"D8C2E73A-954A-4FE8-8BBE-0F5BFDC833DA"];
    CLLocation *currentLocation = [[LocationManager sharedLocationManager] currentLocation];
    NSArray *values;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"]) {
        values = @[[[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"], [DeviceManager getDeviceID], [NSString stringWithFormat:@"%f", currentLocation.coordinate.latitude], [NSString stringWithFormat:@"%f", currentLocation.coordinate.longitude]];
//        values = @[[[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"], [DeviceManager getDeviceID], @"37.7860973156434", @"-122.405682206154"];
    }
    NSArray *keys = @[@"auth_token", DEVICE_ID, @"latitude", @"longitude"];
    NSDictionary *parametersLocal;
    if (values && keys) {
        parametersLocal = [[NSDictionary alloc] initWithObjects:values forKeys:keys];
    }
    return parametersLocal;
}


/*------------------------------------------------------------------------------
 METHOD: WriteJSONToFile
-----------------------------------------------------------------------------*/


- (BOOL) writeJSONToFile: (NSString *) fileName withContents:(NSString *) jsonStringToBeSaved
{
    //applications Documents dirctory path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSError *error;
    BOOL success = NO;
    BOOL functionSuccess = NO;
    //attempt to download live data
    if (jsonStringToBeSaved)
    {
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,fileName];
        if([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            success = [fileManager removeItemAtPath:filePath error:NULL];
            if (success) {
                functionSuccess = [jsonStringToBeSaved writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
            }
        } else {
            functionSuccess = [jsonStringToBeSaved writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        }
    }
    return functionSuccess;
    //copy data from initial package into the applications Documents folder
}

/*------------------------------------------------------------------------------
 METHOD: ReadJSONFromFile
-----------------------------------------------------------------------------*/

- (NSString *) readJSONFromFile: (NSString *) fileName {
    //application Documents dirctory path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory;
    if (paths) {
        documentsDirectory = [paths objectAtIndex:0];
    }
    
    NSString *jsonFilePath;
    NSString *contents;
    NSError *error = nil;

    if (fileName && documentsDirectory) {
        jsonFilePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,fileName];
        contents = [NSString stringWithContentsOfFile:jsonFilePath encoding:NSUTF8StringEncoding error:&error];
    }
    return contents;
}


/*------------------------------------------------------------------------------
 METHOD: WriteJSONToFile
 -----------------------------------------------------------------------------*/


- (BOOL) writeDataToFile: (NSString *) fileName withContents:(id) JSON
{
    //applications Documents dirctory path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSError *error;
    BOOL success = NO;
    BOOL functionSuccess = NO;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:JSON
                                                       options:kNilOptions
                                                         error:&error];
    //attempt to download live data
    if (JSON)
    {
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,fileName];
        if([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            success = [fileManager removeItemAtPath:filePath error:NULL];
            if (success) {
                functionSuccess = [jsonData writeToFile:filePath atomically:YES];
            }
        } else {
            functionSuccess = [jsonData writeToFile:filePath atomically:YES];
        }
    }
    return functionSuccess;
    //copy data from initial package into the applications Documents folder
}

/*------------------------------------------------------------------------------
 METHOD: ReadJSONFromFile
 -----------------------------------------------------------------------------*/

- (id) readDataFromFile: (NSString *) fileName {
    //application Documents dirctory path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory;
    if (paths) {
        documentsDirectory = [paths objectAtIndex:0];
    }
    
    NSString *jsonFilePath;
    NSData *data;
    id JSON;
    NSError *error = nil;
    
    if (fileName && documentsDirectory) {
        jsonFilePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,fileName];
        data = [NSData dataWithContentsOfFile:jsonFilePath];
        JSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    }
    return JSON;
}



/*------------------------------------------------------------------------------
 METHOD: ConvertStringToDictionary
 -----------------------------------------------------------------------------*/

- (NSDictionary *) convertStringToDictionary: (NSString *) stringContents {
    NSData *data = [stringContents dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    return json;
}

@end
