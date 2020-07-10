//
//  UserAPI.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/20/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "UserAPI.h"
#import "DBManager.h"
#import "User.h"
#import "LocationManager.h"

@implementation UserAPI

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

// called to reset the user data to an empty state
- (void) resetUserData {
	
}

- (NSString *) getDeviceId {
    NSString *deviceIdLocal = @"";
    deviceIdLocal = [DeviceManager getDeviceID];
    return deviceIdLocal;
}

- (NSString *) getAppVersion {
    NSString *appVersion = @"";
    appVersion = [DeviceManager getCurrentVersionOfTheApp];
    return appVersion;
}

#pragma mark - CallToServer

- (void)globalLoginWithBlock:(void (^)(BOOL isSuccess, NSError *error))block withDictionaryValues:(NSDictionary *)registrationValues {
    NSDictionary *localRegistrationValues = [self getAdditionalParamtersForLogin: registrationValues];
    NSDictionary *parameters = @{COL_USERNAME : [registrationValues objectForKey:@"email"], COL_PASSWORD : [registrationValues objectForKey:@"password"]};
    if ([localRegistrationValues count] > 0) {
        [[AFAppDotNetAPIClient sharedClient] postPath:loginURL parameters:localRegistrationValues success:^(AFHTTPRequestOperation *operation, id JSON) {
            BOOL success = [self parseBoolFromJson:JSON key:@"success"];
            NSLog(@"JSON %@", JSON);
            NSMutableDictionary *registrationDicts = [[NSMutableDictionary alloc] initWithDictionary:registrationValues];
            [registrationDicts addEntriesFromDictionary:JSON];
            if (success) {
                [[LocationManager sharedLocationManager] retrieveCurrentLocationOnlyIfNotAlreadySet];
                [[User sharedUser] logUserInWithValues:registrationDicts];
            }
            if (success && parameters && [NSUserDefaultsManager getBOOLFromUserDeafults:@"rememberme"]) {
                NSArray *sqlRowArray = [self insertRowDataForDB:parameters];
                [[DBManager sharedDBManager] insertDataInToTableUsingFMDataBase:sqlRowArray withDatabasePath:DB_APP_DATA];
            }
            NSArray *roles = [JSON objectForKey:@"roles"];
            NSString *updateMethod = [JSON objectForKey:@"update_method"];
            BOOL auditor = NO;
            BOOL retailAuditor = NO;
            BOOL scanOutAuditor = NO;
            for (NSString *role in roles) {
                if ([role isEqualToString:AUDITOR_ROLE_DC]) {
                    auditor = YES;
                } else if ([role isEqualToString:AUDITOR_ROLE_RETAIL]) {
                    retailAuditor = YES;
                } else if ([role isEqualToString:AUDITOR_ROLE_SCANOUT]) {
                    scanOutAuditor = YES;
                }
            }
            
            NSString* allRoles = [roles componentsJoinedByString:@","];
            [NSUserDefaultsManager saveObjectToUserDefaults:allRoles withKey:ALL_ROLES];
            
            if (auditor) {
                [NSUserDefaultsManager saveObjectToUserDefaults:AUDITOR_ROLE_DC withKey:AUDITOR_ROLE];
            } else if (retailAuditor) {
                [NSUserDefaultsManager saveObjectToUserDefaults:AUDITOR_ROLE_RETAIL withKey:AUDITOR_ROLE];
            } else if (scanOutAuditor) {
                [NSUserDefaultsManager saveObjectToUserDefaults:AUDITOR_ROLE_SCANOUT withKey:AUDITOR_ROLE];
            } else {
                [NSUserDefaultsManager saveObjectToUserDefaults:AUDITOR_ROLE_DC withKey:AUDITOR_ROLE];
            }
            if (![updateMethod isEqualToString:@""]) {
                [NSUserDefaultsManager saveObjectToUserDefaults:updateMethod withKey:UPDATEMETHOD];
            }
            if (block) {
                block(success, nil);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (block) {
                block(NO, error);
            }
        }];
    }
}

// Create Parameters

- (NSDictionary *) getAdditionalParamtersForLogin: (NSDictionary *) paramters {
    NSArray *values = @[[paramters objectForKey:@"email"], [paramters objectForKey:@"password"], @"false", SW_BUILD_NO, [self getDeviceId]];
    NSArray *keys = @[EMAIL, PASSWORD, AUWS, SOFTWARE_VERSION, DEVICE_ID];
    NSDictionary *parametersLocal = [[NSDictionary alloc] initWithObjects:values forKeys:keys];
    return parametersLocal;
}

// google Sign-in
- (void)googleLoginWithBlock:(void (^)(BOOL isSuccess, NSError *error))block withDictionaryValues:(NSDictionary *)registrationValues {
    //NSDictionary *localRegistrationValues = [self getAdditionalParamtersForLogin: registrationValues];
    //NSDictionary *parameters = @{COL_USERNAME : [registrationValues objectForKey:@"email"], COL_PASSWORD : [registrationValues objectForKey:@"password"]};
    
    NSArray *values = @[[registrationValues objectForKey:@"auth_token"], SW_BUILD_NO, [self getDeviceId]];
    NSArray *keys = @[@"token",SOFTWARE_VERSION, DEVICE_ID];
    NSDictionary *parametersLocal = [[NSDictionary alloc] initWithObjects:values forKeys:keys];
    NSLog(@"Google Auth Parameters: %@",parametersLocal);
    
    if ([parametersLocal count] > 0) {
        [[AFAppDotNetAPIClient sharedClient] postPath:googleLoginURL parameters:parametersLocal success:^(AFHTTPRequestOperation *operation, id JSON) {
            BOOL success = [self parseBoolFromJson:JSON key:@"signed_in"];
            NSLog(@"JSON %@", JSON);
            NSMutableDictionary *registrationDicts = [[NSMutableDictionary alloc] initWithDictionary:registrationValues];
            [registrationDicts addEntriesFromDictionary:JSON];
            NSString* email = (NSString*)[registrationValues objectForKey:@"email"];
            [registrationDicts setObject:email forKey:@"email"];
            if (success) {
                [[LocationManager sharedLocationManager] retrieveCurrentLocationOnlyIfNotAlreadySet];
                [[User sharedUser] googleUserLoggedinWithValues:registrationDicts];
            }
            /*if (success && parameters && [NSUserDefaultsManager getBOOLFromUserDeafults:@"rememberme"]) {
             NSArray *sqlRowArray = [self insertRowDataForDB:parameters];
             [[DBManager sharedDBManager] insertDataInToTableUsingFMDataBase:sqlRowArray withDatabasePath:DB_APP_DATA];
             }*/
            NSArray *roles = [JSON objectForKey:@"roles"];
            NSString *updateMethod = [JSON objectForKey:@"update_method"];
            BOOL auditor = NO;
            BOOL retailAuditor = NO;
            BOOL scanOutAuditor = NO;
            for (NSString *role in roles) {
                if ([role isEqualToString:AUDITOR_ROLE_DC]) {
                    auditor = YES;
                } else if ([role isEqualToString:AUDITOR_ROLE_RETAIL]) {
                    retailAuditor = YES;
                } else if ([role isEqualToString:AUDITOR_ROLE_SCANOUT]) {
                    scanOutAuditor = YES;
                }
            }
            if (auditor) {
                [NSUserDefaultsManager saveObjectToUserDefaults:AUDITOR_ROLE_DC withKey:AUDITOR_ROLE];
            } else if (retailAuditor) {
                [NSUserDefaultsManager saveObjectToUserDefaults:AUDITOR_ROLE_RETAIL withKey:AUDITOR_ROLE];
            } else if (scanOutAuditor) {
                [NSUserDefaultsManager saveObjectToUserDefaults:AUDITOR_ROLE_SCANOUT withKey:AUDITOR_ROLE];
            } else {
                [NSUserDefaultsManager saveObjectToUserDefaults:AUDITOR_ROLE_DC withKey:AUDITOR_ROLE];
            }
            if (![updateMethod isEqualToString:@""]) {
                [NSUserDefaultsManager saveObjectToUserDefaults:updateMethod withKey:UPDATEMETHOD];
            }
            if (block) {
                block(success, nil);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (block) {
                block(NO, error);
            }
        }];
    }
}



#pragma mark - SQL Methods

+ (NSString *) getTableCreateStatmentForUser {
    NSString *sql =[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@", TBL_USERS];
    sql = [sql stringByAppendingString:@" ("];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_USERNAME, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@",COL_PASSWORD, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingString:@")"];
    return sql;
}

#pragma mark - SQL Insert Methods

- (NSArray *) insertRowDataForDB: (NSDictionary *) userDict {
    NSMutableArray *sqlRowArray = [[NSMutableArray alloc] init];
    if (userDict) {
        NSString *sql =[NSString stringWithFormat:@"INSERT INTO %@", TBL_USERS];
        sql = [sql stringByAppendingString:@" ("];
        sql = [sql stringByAppendingFormat:@"%@,%@", COL_USERNAME, COL_PASSWORD];
        sql = [sql stringByAppendingString:@")"];
        sql = [sql stringByAppendingString:@" VALUES "];
        sql = [sql stringByAppendingString:@"("];
        sql = [sql stringByAppendingFormat:@"'%@','%@'", [userDict objectForKey:COL_USERNAME], [userDict objectForKey:COL_PASSWORD]];
        sql = [sql stringByAppendingString:@");"];
        [sqlRowArray addObject:sql];
    }
    return [sqlRowArray copy];
}

#pragma mark - SQL Retrieve Data Methods

- (NSString *) retrieveRowDataForDB {
    NSString *retrieveStatement = [NSString stringWithFormat:@"SELECT * FROM %@", TBL_USERS];
    return retrieveStatement;
}

@end
