//
//  DeviceManager.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/5/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "DeviceManager.h"
#import "AppDelegate.h"
#import "Reachability.h"
#import "Constants.h"
#include "TargetConditionals.h"
#import "OpenUDID.h"
@implementation DeviceManager

+ (NSString *) getDeviceID {
    
#if (TARGET_IPHONE_SIMULATOR)
    return @"iOS_Simulator";
#endif
    
    NSString *udid = @"";
    NSString *model = [[UIDevice currentDevice] model];
    if ([model isEqualToString:@"iPhone Simulator"] /*|| [model isEqualToString:@"iPhone"] */) {
        return @"iOS_Simulator";
    }
    
    if (IS_OS_6_OR_LATER) {
        NSString* openUDID = [OpenUDID value];
        udid = openUDID;
    } else {
        udid = [UIDevice currentDevice].identifierForVendor.UUIDString;
    }
    return udid;
}

+ (NSString *) getCurrentVersionOfTheApp {
    NSString *version = @"";\
    version = SW_VERSION_NO;
    return version;
}

+ (BOOL) isConnectedToWifi {
    BOOL connectToWifi = NO;
	Reachability *serverReachability = [Reachability reachabilityWithHostName:ReachabilityHostDCInsightsPROD];
    if ([serverReachability currentReachabilityStatus] == ReachableViaWiFi) {
        connectToWifi = YES;
    }
    return connectToWifi;
}

+ (BOOL) isConnectedToWWan {
    BOOL connectToWWan = NO;
	Reachability *serverReachability = [Reachability reachabilityWithHostName:ReachabilityHostDCInsightsPROD];
    if ([serverReachability currentReachabilityStatus] == ReachableViaWWAN) {
        connectToWWan = YES;
    }
    return connectToWWan;
}

+ (BOOL) isConnectedToNetwork {
    BOOL connected = NO;
	Reachability *serverReachability = [Reachability reachabilityWithHostName:ReachabilityHostDCInsightsPROD];
    if (![serverReachability currentReachabilityStatus] == NotReachable) {
        connected = YES;
    }
    return connected;
}

+(BOOL) isConnectedToInternet {
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        return NO;
    } else {
        return YES;
    }
}

+(BOOL)isConnectedBasedOnAppSettings{
    if ([NSUserDefaultsManager getBOOLFromUserDeafults:SyncOverWifi] && [DeviceManager isConnectedToWifi]) {
        return YES;
    } else {
        return [DeviceManager isConnectedToNetwork];
    }
    return NO;
}

+ (NSString *) getCurrentTimeString {
    NSString * timestamp = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970] * 1000];
    return timestamp;
}

+ (NSString *) getTimeForAldi {
    float time = [[NSDate date] timeIntervalSince1970] * 1000 + seventeenHours;
    NSString * timestamp = [NSString stringWithFormat:@"%.0f",time];
    return timestamp;
}

+ (NSString *) getCurrentDate {
    NSDateFormatter *localTimeZoneFormatter = [NSDateFormatter new];
    localTimeZoneFormatter.timeZone = [NSTimeZone localTimeZone];
    localTimeZoneFormatter.dateFormat = @"yyyy-MM-dd";
    NSString *localTimeZoneOffset = [localTimeZoneFormatter stringFromDate:[NSDate date]];
    return localTimeZoneOffset;
}


//+ (NSString *) getPSTTimeString {
//    NSCalendar *cal = [NSCalendar currentCalendar];
//    NSDate *now = [NSDate date];
//    // create PDT date components
//    NSDateComponents *utcComponents = [cal components: NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSYearCalendarUnit fromDate: now];
//    utcComponents.timeZone = [NSTimeZone timeZoneWithName: @"UTC"];
//    // get the PDT date
//    NSDate *utcDate = [cal dateFromComponents: utcComponents];
//    NSString * timestamp = [NSString stringWithFormat:@"%.0f",[utcDate timeIntervalSince1970] * 1000];
//    return timestamp;
//}

+ (NSString *) getPSTTimeString {
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
//    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"PST"];
//    [dateFormatter setTimeZone:gmt];
//    NSString *timeStamp = [dateFormatter stringFromDate:[NSDate date]];
//
//    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
//    dateFormatter2.dateFormat = @"yyyy-MM-dd HH:mm:ss";
//    NSDate *capturedStartDate = [dateFormatter2 dateFromString: timeStamp];
//    NSLog(@"date %@", capturedStartDate);
//    NSString * timestamp2 = [NSString stringWithFormat:@"%.0f",[capturedStartDate timeIntervalSince1970] * 1000];
//    NSLog(@"sfvfevv %@", capturedStartDate);
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd hh:mm:ss a";
    
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"PST"];
    [dateFormatter setTimeZone:gmt];
    NSString *timeStamp = [dateFormatter stringFromDate:[NSDate date]];
    
    
    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
    dateFormatter1.dateFormat = @"yyyy-MM-dd hh:mm:ss a";
    NSTimeZone *gmt2 = [NSTimeZone timeZoneWithAbbreviation:@"PST"];
    [dateFormatter1 setTimeZone:gmt2];

    NSDate *date = [dateFormatter dateFromString:timeStamp];

    NSLog(@"fvdf %@", date);
    NSString * timestamp = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970] * 1000];
    return @"";
}

+(NSString*) getCurrentTimeZoneString {
    NSDateFormatter *localTimeZoneFormatter = [NSDateFormatter new];
    localTimeZoneFormatter.timeZone = [NSTimeZone localTimeZone];
    localTimeZoneFormatter.dateFormat = @"Z";
    NSString *localTimeZoneOffset = [localTimeZoneFormatter stringFromDate:[NSDate date]];
    return localTimeZoneOffset;
}

+(NSString*) getTimeInMillisFromDate:(NSDate*)date{
 if(!date)
     return @"";
    NSTimeInterval seconds = [date timeIntervalSince1970];
    int64_t timeInMilisInt64 = (int64_t)(seconds*1000);
    NSString* millisecondsTimeStamp = [NSString stringWithFormat:@"%lld",timeInMilisInt64];
    return millisecondsTimeStamp;
}

+(NSString*)getTimeZone{
    int timeZoneOffset = [[NSTimeZone localTimeZone] secondsFromGMT] / 3600;
    NSString *timeZoneOffsetString = [NSString stringWithFormat:@"%+d",timeZoneOffset];
    return timeZoneOffsetString;
}


+(NSString*)getCurrentDateTimeWithTimeZone{
    NSDateFormatter *localTimeZoneFormatter = [NSDateFormatter new];
    localTimeZoneFormatter.timeZone = [NSTimeZone localTimeZone];
    localTimeZoneFormatter.dateFormat = @"E, d MMM yyyy HH:mm:ss Z";
    NSString *localTimeZoneOffset = [localTimeZoneFormatter stringFromDate:[NSDate date]];
    return localTimeZoneOffset;
}

+(NSString*)getConnectivityStatusLog{
    BOOL isWifi = [DeviceManager isConnectedToWifi];
    BOOL isConnectedToNet = [DeviceManager isConnectedToNetwork];
    BOOL syncOverWifiOnly = [NSUserDefaultsManager getBOOLFromUserDeafults:SyncOverWifi];
    BOOL connectionStatus = [DeviceManager isConnectedBasedOnAppSettings];
    NSString *connectivityStatus = [NSString stringWithFormat:@"\nConnectivity Status: %@ | Connected to Wifi: %@ | Connected to Network: %@ | SyncOverWifiOnly: %@",(connectionStatus ? @"Yes" : @"No"), (isWifi ? @"Yes" : @"No"), (isConnectedToNet ? @"Yes" : @"No"), (syncOverWifiOnly ? @"Yes" : @"No")];
    return connectivityStatus;
}
@end
