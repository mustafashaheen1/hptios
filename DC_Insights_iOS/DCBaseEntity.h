//
//  DCBaseEntity.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/5/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ErrorMessages.h"
#import "Constants.h"
#import "NSUserDefaultsManager.h"
#import "DeviceManager.h"
#import "AFAppDotNetAPIClient.h"
#import "DBConstants.h"
#import "FMResultSet.h"
#import "DBManager.h"
#import "JSONModel.h"

@interface DCBaseEntity : NSObject

- (NSString*) parseStringFromJson:(NSDictionary*)data key:(NSString*)key;
- (NSInteger) parseIntegerFromJson:(NSDictionary*)data key:(NSString*)key;
- (double) parseDoubleFromJson:(NSDictionary*)data key:(NSString*)key;
- (BOOL) parseBoolFromJson:(NSDictionary*)data key:(NSString*)key;
- (NSDate*) parseDateFromJson:(NSDictionary*)data key:(NSString*)key;
- (NSArray*) parseArrayFromJson:(NSDictionary*)data key:(NSString*)key;
- (NSDictionary*) parseDictFromJson:(NSDictionary*)data key:(NSString*)key;
- (NSString *)asCommaSeparatedString:(NSArray *)items;
- (NSDictionary *) paramtersFortheGETCall;
- (NSDictionary *) paramtersFortheGETCallWithLatLon;
- (BOOL) writeJSONToFile: (NSString *) fileName withContents:(NSString *) jsonStringToBeSaved;
- (NSString *) readJSONFromFile: (NSString *) fileName;
- (NSDictionary *) convertStringToDictionary: (NSString *) stringContents;
- (BOOL) writeDataToFile: (NSString *) fileName withContents:(id) JSON;
- (id) readDataFromFile: (NSString *) fileName;

-(void)saveApiResponseArray:(NSMutableArray*)array;

@end
