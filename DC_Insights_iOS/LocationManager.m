//
//  LocationManager.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 4/18/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "LocationManager.h"
#import "Constants.h"
#import "NSUserDefaultsManager.h"

#define kLMNavigationDistanceFilter	10.0 // kCLDistanceFilterNone

// Private Declarations
@interface LocationManager ()
{
	CLLocationAccuracy	currentAccuracy;
	
	NSInteger			foundCount;
}


@end

static LocationManager *_sharedLocationManager = nil;

//// allocates sharedInstance BEFORE main is executed
//__attribute__((constructor)) static void construct_singleton() {
//	NSAutoreleasePool * p = [[NSAutoreleasePool alloc] init];
//	_sharedLocationManager = NSAllocateObject([LocationManager class], 0, nil);
//	[p drain];
//}


// destroys sharedInstance after main exits.. REQUIRED for unit tests
// to work correclty, otherwse the FIRST shared object gets used for ALL
// tests, resulting in KVO problems
__attribute__((destructor)) static void destroy_singleton() {
	_sharedLocationManager = nil;
}


@implementation LocationManager

@synthesize coreLocationManager;
@synthesize coordinateUpdateState;
@synthesize currLocation;
@synthesize sendNotification = _sendNotification;
@synthesize currLocationGlobalUse;


#pragma mark - Class Access Method

/*------------------------------------------------------------------------------
 METHOD: sharedAllMetacategories
 
 PURPOSE:
 Returns the singleton object.
 
 RETURN VALUE:
 The singleton object.
 
 -----------------------------------------------------------------------------*/
+ (id)sharedLocationManager
{
    // Already set by +initialize.
	
    //	NSLog(@"\n\n======================== SHARED LOCATION MANAGER =========\n\n%@\n\n", _sharedLocationManager);
	
    return _sharedLocationManager;
}



#pragma mark - Accessors

// override currentLocation to update previous AND do any KVO
- (void)setCurrLocation:(CLLocation *)newLocation
{
	// make sure new and old location are different
	// first, make sure they are not both nil or both non-nil
    //	BOOL newAndOldDifferent = ((newLocation != currLocation) ||
    //							   ((currLocation != nil) && !newLocation)) &&
    //	(currLocation.coordinate.latitude !=
    //	 newLocation.coordinate.latitude) &&
    //	(currLocation.coordinate.longitude !=
    //	 newLocation.coordinate.longitude);
    
	// only update if the new location is different
	if ((newLocation != currLocation) &&
		![currLocation isEqual:newLocation]) {
		// figure out the state change type
		// set the value of the update state
		LMCoordinateUpdateState newState = kLMStateBad;
        
		if (newLocation == nil) {
			// The new location is invalid
			newState = kLMStateInvalid;
			
		} else if (currLocation == nil) {
			// the old location is invalid and new location is valid
			newState = kLMStateValid;
			
		} else {
			// the old and new location are valid, so it is an update
			newState = kLMStateUpate;
			
		}
		
		// If the state has changed, update and broadcast update
		if (newState != kLMStateBad) {
            if (newLocation != currLocation) {
                if (!retrievingCurrentLocation) {
                    [self willChangeValueForKey:kLMUserLocationKVOKey];
                }
                
                // update the location and state
                currLocation = newLocation;
                NSString *latString = [NSString stringWithFormat:@"%f", currLocation.coordinate.latitude];
                NSString *longString = [NSString stringWithFormat:@"%f", currLocation.coordinate.longitude];
                [NSUserDefaultsManager saveObjectToUserDefaults:latString withKey:LatitudeForTheEntireApp];
                [NSUserDefaultsManager saveObjectToUserDefaults:longString withKey:LongitudeForTheEntireApp];
                
                coordinateUpdateState = newState;
                
                if (!retrievingCurrentLocation) {
                    [self didChangeValueForKey:kLMUserLocationKVOKey];
                }
                NSMutableDictionary *dictLocation = [NSMutableDictionary dictionary];
                if (currLocation) {
                    [dictLocation setObject:currLocation forKey:@"location"];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:kLMUserLocationUpdateKey object:nil userInfo:dictLocation];
            }
		}
	}
}


#pragma mark - Initialization

/*------------------------------------------------------------------------------
 METHOD: init:
 
 PURPOSE:
 Initialize the object values.
 
 RETURN VALUE:
 The initialized singleton
 
 -----------------------------------------------------------------------------*/
- (id)init
{
	if (self = [super init]) {
        self.coreLocationManager = nil;
        self.currLocation = nil;
        retrievingCurrentLocation = NO;
		currentAccuracy = kCLLocationAccuracyBest;
		coordinateUpdateState = kLMStateBad;
		foundCount = 0;
        self.sendNotificationToHomeScreen = NO;
	}
	
	return self;
}

#pragma mark - Utility Methods

- (CLLocation *)currentLocation
{
	return currLocation;
}


- (void)retrieveCurrentLocation
{
    //    self.currLocation = nil;
	foundCount = 0;
	
    if ([CLLocationManager locationServicesEnabled]) {
        
        if (coreLocationManager == nil) {
            coreLocationManager = [[CLLocationManager alloc] init];
            
            coreLocationManager.delegate = self;
            coreLocationManager.desiredAccuracy = currentAccuracy;
            coreLocationManager.distanceFilter = kLMDefaultDistanceFilter;
            if (IS_OS_8_OR_LATER)
            {
                [coreLocationManager requestWhenInUseAuthorization];
                [coreLocationManager requestAlwaysAuthorization];
            }
        }
        
        retrievingCurrentLocation = YES;
        [coreLocationManager startUpdatingLocation];
        //[coreLocationManager startMonitoringSignificantLocationChanges];
    }
}


- (void)retrieveCurrentLocationOnlyIfAlreadySet
{
    if (currLocation && !retrievingCurrentLocation) {
        [self retrieveCurrentLocation];
        self.sendNotificationToHomeScreen = YES;
    }
}


- (void)retrieveCurrentLocationOnlyIfNotAlreadySet
{
    if (!currLocation && !retrievingCurrentLocation) {
        [self retrieveCurrentLocation];
    }
}


#pragma mark - CLLocationManagerDelegate Methods


- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
    if (self.sendNotificationToHomeScreen) {
        if (retrievingCurrentLocation) {
            if (newLocation.horizontalAccuracy <= kLMDefaultDistanceFilter) {
                retrievingCurrentLocation = NO;
                [coreLocationManager stopUpdatingLocation];
                self.currLocation = newLocation;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LocationNotification" object:self];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LocationNotificationHomeScreen" object:self];
            }
        }
        self.sendNotificationToHomeScreen = NO;
    } else {
        if (retrievingCurrentLocation) {
            if (newLocation.horizontalAccuracy <= kLMDefaultDistanceFilter) {
                retrievingCurrentLocation = NO;
                [coreLocationManager stopUpdatingLocation];
                self.currLocation = newLocation;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LocationNotification" object:self];
            }
        }
    }
	
}

#pragma mark - Significant Location Change Methods

/*------------------------------------------------------------------------------
 Singleton Methods.. Generic to any Singleton
 -----------------------------------------------------------------------------*/

- (void) reportLocation:(CLLocation *)location withMessage:(NSString *)message {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"hh:mmaa"];
    
    NSString *msg = [NSString stringWithFormat:@"\n%@: %@ <%+.6f, %+.6f> (+/-%.0fm) %.1fkm/h",
                     message,
                     [dateFormat stringFromDate:location.timestamp],
                     location.coordinate.latitude,
                     location.coordinate.longitude,
                     location.horizontalAccuracy,
                     location.speed * 3.6];
    if (location.altitude > 0) {
        msg = [NSString stringWithFormat:@"%@ alt: %.2fm (+/-%.0fm)",
               msg,
               location.altitude,
               location.verticalAccuracy];
    }
    
    if (self.sendNotification) {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        if (notification) {
            notification.alertBody = msg;
            notification.soundName = UILocalNotificationDefaultSoundName;
            [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        }
    }
}


#pragma mark - Singleton Methods

/*------------------------------------------------------------------------------
 Singleton Methods.. Generic to any Singleton
 -----------------------------------------------------------------------------*/

+ (void)initialize
{
    if (_sharedLocationManager == nil)
        _sharedLocationManager = [[self alloc] init];
}


+ (id)allocWithZone:(NSZone*)zone
{
    //Usually already set by +initialize.
    if (_sharedLocationManager) {
        //The caller expects to receive a new object, so implicitly retain it
        //to balance out the eventual release message.
        return _sharedLocationManager;
    } else {
        //When not already set, +initialize is our caller.
        //It's creating the shared instance, let this go through.
        return [super allocWithZone:zone];
    }
}


- (id)copyWithZone:(NSZone*)zone
{
    return self;
}

@end
