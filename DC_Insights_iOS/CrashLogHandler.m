//
//  CrashLogHandler.m
//  Insights
//
//  Created by Vineet Pareek on 9/2/17.
//  Copyright © 2017 Yottamark. All rights reserved.
//

#import "CrashLogHandler.h"
#import "Constants.h"
#import "NSUserDefaultsManager.h"
#import "DeviceManager.h"

#define CRASH_LOGS_LIMIT 20

@implementation CrashLogHandler

- (id)init
{
    self = [super init];
    if (self) {
        self.crashLogsArray = [[NSMutableArray alloc] init];
        }
    return self;
}

-(void)deleteCrashLogs
{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:CRASH_LOGS];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)addToCrashLogs:(NSString*)error
{
    [self deleteOlderItems];
    NSString* uploadLogs = [NSString stringWithFormat:@"---- Log Added at %@ ----\n\n%@", [DeviceManager getCurrentDateTimeWithTimeZone],error];
    self.crashLogsArray = [[[NSUserDefaults standardUserDefaults] arrayForKey:CRASH_LOGS] mutableCopy];
    if(self.crashLogsArray){
        [self.crashLogsArray addObject:uploadLogs];
    }else{
        self.crashLogsArray = [[NSMutableArray alloc] init];
    }
    [[NSUserDefaults standardUserDefaults] setObject:self.crashLogsArray forKey:CRASH_LOGS];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSString*)getEmailText
{
    NSString* emailText = @"";
    self.crashLogsArray = [[[NSUserDefaults standardUserDefaults] arrayForKey:CRASH_LOGS] mutableCopy];
    if(!self.crashLogsArray || [self.crashLogsArray count]==0)
        return @"Crash Logs Empty";
    emailText = [[self.crashLogsArray valueForKey:@"description"] componentsJoinedByString:@"\n\n"];
    return emailText;
}

-(void)deleteOlderItems{
    NSMutableArray* history  = [[[NSUserDefaults standardUserDefaults] arrayForKey:CRASH_LOGS] mutableCopy];
    if(history && [history count]>CRASH_LOGS_LIMIT){
        int count = (int)[history count];
        [history removeObjectAtIndex:0]; //delete oldest one
        [NSUserDefaultsManager saveObjectToUserDefaults:history withKey:CRASH_LOGS];
    }
}

@end
