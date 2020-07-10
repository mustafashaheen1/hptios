//
//  HPTInspection.m
//  Insights
//
//  Created by Mustafa Shaheen on 6/29/20.
//  Copyright © 2020 Yottamark. All rights reserved.
//

#import "HPTInspection.h"
#import "User.h"
#import "Rating.h"
#import "LocationManager.h"
#import "Store.h"
#import "Audit.h"
#import "Inspection.h"
#import "HPTCaseCodeModel.h"


@implementation HPTInspection
-(AuditApiData *) getApiObjectFromViewModel: (HPTCaseCodeModel *) activityModel{
    AuditApiData *auditData = [[AuditApiData alloc] init];
    [self setDeviceInfo:auditData];
    [self setLocationInfo:auditData];
    [self setImages:auditData];
    [self setUser:auditData];
    [self setHPTInfo:activityModel :auditData];
    [self setAuditInfo:auditData];
    [self setTrackingCodes:auditData];
    [self setIgnoredValues:auditData];
    
    return auditData;
}

-(void) setDeviceInfo: (AuditApiData *) auditApiData{
    AuditApiDevice *auditApiDevice = [self setupAuditApiDevice];
    auditApiData.device = auditApiDevice;
}

- (AuditApiDevice *) setupAuditApiDevice {
    AuditApiDevice *auditApiDevice = [[AuditApiDevice alloc] init];
    auditApiDevice.os_name = @"iOS";
    auditApiDevice.os_version = [[UIDevice currentDevice] systemVersion];
    if ([DeviceManager getDeviceID]) {
        auditApiDevice.id = [DeviceManager getDeviceID];
    }
    if ([DeviceManager getCurrentVersionOfTheApp]) {
        auditApiDevice.version = [DeviceManager getCurrentVersionOfTheApp];
    }
    return auditApiDevice;
}

-(void) setUser: (AuditApiData *) auditApiData{
    
    AuditApiUser *auditApiUser = [self setupAuditApiUser];
    auditApiData.user = auditApiUser;
    
}

- (AuditApiUser *) setupAuditApiUser {
    User *user = [User sharedUser];
    AuditApiUser *auditApiUser = [[AuditApiUser alloc]init];
    auditApiUser.id = user.email;
    return auditApiUser;
}

-(void) setLocationInfo: (AuditApiData *) auditApiData{
    AuditApiLocation *location = [self setupAuditApiLocation];
    auditApiData.location = location;
}

- (AuditApiLocation *) setupAuditApiLocation {
    AuditApiLocation *auditApiLocation = [[AuditApiLocation alloc]init];
    auditApiLocation.gpsMessage = @"GPSNotAvailable";
    CLLocation *location =  [[LocationManager sharedLocationManager] currentLocation];
    if (location) {
        auditApiLocation.latitude = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
        auditApiLocation.longitude = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
        auditApiLocation.gpsMessage = @"GPSAvailable";
        if (location.coordinate.latitude == 0 && location.coordinate.longitude == 0) {
            auditApiLocation.gpsMessage = @"GPSNotAvailable";
        }
    }
    return auditApiLocation;
}
-(void) setImages: (AuditApiData *) auditApiData{
    auditApiData.images = [[NSArray alloc]init];
}
-(void) setHPTInfo: (HPTCaseCodeModel *) activityModel: (AuditApiData *) auditApiData{
    
    HPTInspectionApi *hptInspectionApi = [[HPTInspectionApi alloc] init];
    for(Rating *rating in activityModel.ratings){
        AuditApiRating *ratingApi = [[AuditApiRating alloc] init];
        ratingApi.id = rating.ratingID;
        ratingApi.type = rating.type;
        ratingApi.value = rating.value;
        [hptInspectionApi.ratings addObject:ratingApi];
    }
    auditApiData.hptApi.toAddress = activityModel.toAddress;
    auditApiData.hptApi.ratings = hptInspectionApi.ratings;
    Store *store = [[User sharedUser] currentStore];
    auditApiData.hptApi.fromAddress = [activityModel convert:store];
    auditApiData.hptApi.ptiCodes = activityModel.caseCodes;
    auditApiData.hptApi.sscc = activityModel.sscc;
    
}

-(void) setAuditInfo: (AuditApiData *) auditApiData{
    AuditApiDescriptor *auditApiDescriptor = [self setupAuditApiDescriptor];
    auditApiData.audit = auditApiDescriptor;
}

- (AuditApiDescriptor *) setupAuditApiDescriptor {
    
    AuditApiDescriptor *auditApiDescriptor = [[AuditApiDescriptor alloc]init];
    NSString *start = [DeviceManager getCurrentTimeString];
    NSInteger currentTime = [start intValue];
    currentTime = currentTime + 1;
    NSInteger start_int = [start intValue];
    start_int = start_int + 2;
    start = [@(start_int) stringValue];
    NSInteger end_int = start_int + 1;
    NSString *end = [@(end_int) stringValue];
    auditApiDescriptor.timezone = [DeviceManager getCurrentTimeZoneString];
    auditApiDescriptor.id = [NSString stringWithFormat:@"%@-%@-%@-%@",[DeviceManager getDeviceID],[DeviceManager getCurrentTimeString],[@(currentTime) stringValue],start];
    auditApiDescriptor.start = start;
    auditApiDescriptor.end = end;
    return auditApiDescriptor;
}

-(void) setTrackingCodes: (AuditApiData *) auditApiData{
    [auditApiData.trackingCodes setTrackingCode:@"HPT_Event"];
}

-(void) setIgnoredValues: (AuditApiData *) auditApiData{
    auditApiData.submittedInfo = nil;
    auditApiData.summary = nil;
}

-(void) saveToDB: (AuditApiData *) auditApiData{
    Audit *auditApi = [[Audit alloc] init];
    auditApi.auditData = auditApiData;
    [[Inspection sharedInspection] saveAuditInOfflineTable:auditApi withImages:@"[]"];
    
}
@end
