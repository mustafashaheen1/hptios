//
//  NSUserDefaultsManager.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/6/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaultsManager : NSObject

+ (void) saveObjectToUserDefaults: (id) object withKey:(NSString *) key;
+ (id) getObjectFromUserDeafults: (NSString *) key;
+ (void) removeObjectFromUserDeafults: (NSString *) key;
+ (void) saveBOOLToUserDefaults: (BOOL) object withKey:(NSString *) key;
+ (BOOL) getBOOLFromUserDeafults: (NSString *) key;
+ (void) saveFloatToUserDefaults: (float) object withKey:(NSString *) key;
+ (float) getFloatFromUserDeafults: (NSString *) key;
+ (void) saveIntegerToUserDefaults: (int) object withKey:(NSString *) key;
+ (float) getIntegerFromUserDeafults: (NSString *) key;
+ (void) saveDoubleToUserDefaults: (int) object withKey:(NSString *) key;
+ (double) getDoubleFromUserDeafults: (NSString *) key;

@end
