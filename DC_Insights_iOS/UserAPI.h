//
//  UserAPI.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/20/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "DCBaseEntity.h"

@interface UserAPI : DCBaseEntity

- (void)globalLoginWithBlock:(void (^)(BOOL isSuccess, NSError *error))block withDictionaryValues:(NSDictionary *)registrationValues;
- (void)googleLoginWithBlock:(void (^)(BOOL isSuccess, NSError *error))block withDictionaryValues:(NSDictionary *)registrationValues;
+ (NSString *) getTableCreateStatmentForUser;

@end
