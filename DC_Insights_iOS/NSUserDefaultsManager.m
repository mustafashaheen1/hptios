//
//  NSUserDefaultsManager.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/6/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "NSUserDefaultsManager.h"

@implementation NSUserDefaultsManager

// Object (includes String, Array, Dictionary)
+ (void) saveObjectToUserDefaults: (id) object withKey:(NSString *) key {
    if (!object || !key) {
        NSLog(@"Object or Key missing");
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:object forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (id) getObjectFromUserDeafults: (NSString *) key {
    id object;
    if (!key) {
        NSLog(@"Key missing");
    } else {
        object = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    }
    return object;
}

+ (void) removeObjectFromUserDeafults: (NSString *) key {
    if (!key) {
        NSLog(@"Key missing");
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

//BOOL

+ (void) saveBOOLToUserDefaults: (BOOL) object withKey:(NSString *) key {
    [[NSUserDefaults standardUserDefaults] setBool:object forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL) getBOOLFromUserDeafults: (NSString *) key {
    BOOL object = NO;
    if (!key) {
        NSLog(@"Key missing");
    } else {
        object = [[NSUserDefaults standardUserDefaults] boolForKey:key];
    }
    return object;
}

//Float

+ (void) saveFloatToUserDefaults: (float) object withKey:(NSString *) key {
    if (object == 0 || !key) {
        NSLog(@"Object or Key missing");
    } else {
        [[NSUserDefaults standardUserDefaults] setFloat:object forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (float) getFloatFromUserDeafults: (NSString *) key {
    float object = 0.0;
    if (!key) {
        NSLog(@"Key missing");
    } else {
        object = [[NSUserDefaults standardUserDefaults] floatForKey:key];
    }
    return object;
}

//Integer

+ (void) saveIntegerToUserDefaults: (int) object withKey:(NSString *) key {
    if (object == 0 || !key) {
        NSLog(@"Object or Key missing");
    } else {
        [[NSUserDefaults standardUserDefaults] setInteger:object forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (float) getIntegerFromUserDeafults: (NSString *) key {
    float object = 0.0;
    if (!key) {
        NSLog(@"Key missing");
    } else {
        object = [[NSUserDefaults standardUserDefaults] integerForKey:key];
    }
    return object;
}

//Double

+ (void) saveDoubleToUserDefaults: (int) object withKey:(NSString *) key {
    if (object == 0 || !key) {
        NSLog(@"Object or Key missing");
    } else {
        [[NSUserDefaults standardUserDefaults] setDouble:object forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (double) getDoubleFromUserDeafults: (NSString *) key {
    double object = 0;
    if (!key) {
        NSLog(@"Key missing");
    } else {
        object = [[NSUserDefaults standardUserDefaults] doubleForKey:key];
    }
    return object;
}



@end
