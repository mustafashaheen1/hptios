//
//  UserLocation.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 4/3/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserLocation : NSObject

@property (assign, nonatomic) double latitude;
@property (assign, nonatomic) double longitude;
@property (strong, nonatomic) NSString *gpsError;
@property (assign, nonatomic) double lastKnownLatitude;
@property (assign, nonatomic) double lastKnownLongitude;
@property (assign, nonatomic) double timeSinceLastLocationCheck;

@end
