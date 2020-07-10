//
//  LocationManager.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 4/18/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

// KVO Key
#define kLMUserLocationKVOKey		@"coordinateUpdateState"
#define kLMUserLocationUpdateKey    @"LocationUpdateNotification"

// notification userInfo dictionary keys
#define KLMOldLocationKey			@"oldLocation"
#define KLMLocationDelta			@"locationDelta"

#define kLMDefaultDistanceFilter	200.0

enum {
	kLMStateBad,
	kLMStateInvalid,
	kLMStateValid,
	kLMStateUpate
};
typedef NSUInteger LMCoordinateUpdateState;

@interface LocationManager : NSObject <CLLocationManagerDelegate> {
    CLLocationManager		*coreLocationManager;
    BOOL					retrievingCurrentLocation;
	LMCoordinateUpdateState	coordinateUpdateState;
}

// Class Methods
+ (id) sharedLocationManager;

@property (nonatomic, retain) CLLocationManager *coreLocationManager;
@property (nonatomic) LMCoordinateUpdateState coordinateUpdateState;
@property (nonatomic, retain) CLLocation *currLocation;
@property (nonatomic, retain) CLLocation *currLocationGlobalUse;
@property (nonatomic) BOOL sendNotification;
@property (nonatomic) BOOL sendNotificationToHomeScreen;

- (CLLocation*)currentLocation;

- (void)retrieveCurrentLocation;
- (void)retrieveCurrentLocationOnlyIfAlreadySet;
- (void)retrieveCurrentLocationOnlyIfNotAlreadySet;
- (void) log:(NSString *)message;
- (void) reportLocation:(CLLocation *)location withMessage:(NSString *)message;


@end
