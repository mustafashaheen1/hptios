//
//  CLLocation+DistanceComparison.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 4/18/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "CLLocation+DistanceComparison.h"

@implementation CLLocation (DistanceComparison)

- (NSComparisonResult) compareToLocation:(CLLocation *)other {
    CLLocationDistance thisDistance = [self distanceFromLocation:referenceLocation];
    CLLocationDistance thatDistance = [other distanceFromLocation:referenceLocation];
    if (thisDistance < thatDistance) { return NSOrderedAscending; }
    if (thisDistance > thatDistance) { return NSOrderedDescending; }
    return NSOrderedSame;
}

@end
