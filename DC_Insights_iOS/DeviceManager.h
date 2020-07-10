//
//  DeviceManager.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/5/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TAG "DCInsights";

@interface DeviceManager : NSObject

+ (NSString *) getDeviceID;
+ (NSString *) getCurrentVersionOfTheApp;
+ (BOOL) isConnectedToWifi;
+ (BOOL) isConnectedToWWan;
+ (BOOL) isConnectedToNetwork;
+ (NSString *) getCurrentTimeString;
+ (NSString*) getCurrentTimeZoneString;
+ (NSString *) getCurrentDate;
+ (NSString *) getPSTTimeString;
+ (NSString *) getTimeForAldi;
+(NSString*) getTimeInMillisFromDate:(NSDate*)date;
+(NSString*)getTimeZone;
+(NSString*)getCurrentDateTimeWithTimeZone;
+(BOOL) isConnectedToInternet;
+(BOOL)isConnectedBasedOnAppSettings;
+(NSString*)getConnectivityStatusLog;

@end
