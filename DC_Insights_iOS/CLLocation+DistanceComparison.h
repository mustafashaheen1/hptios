//
//  CLLocation+DistanceComparison.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 4/18/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

static CLLocation * referenceLocation;

@interface CLLocation (DistanceComparison)

- (NSComparisonResult) compareToLocation:(CLLocation *)other;

@end
