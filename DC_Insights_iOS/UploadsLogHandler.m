//
//  UploadsLogHandler
//  Insights
//
//  Created by Vineet Pareek on 12/5/17.
//  Copyright © 2017 Yottamark. All rights reserved.
//

#import "UploadsLogHandler.h"
#import "Constants.h"
#import "NSUserDefaultsManager.h"
#import "DeviceManager.h"

#define UPLOADS_LOGS_LIMIT 3

@implementation UploadsLogHandler

- (id)init
{
    self = [super init];
    if (self) {
        self.uploadsLogsArray = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)deleteLogs
{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:UPLOADS_LOGS];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)addLogs:(NSString*)logs
{
    [self deleteOlderItems];
    NSString* uploadLogs = [NSString stringWithFormat:@"---- Log Added at %@ ----\n\n%@", [DeviceManager getCurrentDateTimeWithTimeZone],logs];
    self.uploadsLogsArray = [[[NSUserDefaults standardUserDefaults] arrayForKey:UPLOADS_LOGS] mutableCopy];
    if(self.uploadsLogsArray){
        [self.uploadsLogsArray addObject:uploadLogs];
    }else{
        self.uploadsLogsArray = [[NSMutableArray alloc] init];
    }
    [[NSUserDefaults standardUserDefaults] setObject:self.uploadsLogsArray forKey:UPLOADS_LOGS];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSString*)getEmailText
{
    NSString* emailText = @"";
    self.uploadsLogsArray = [[[NSUserDefaults standardUserDefaults] arrayForKey:UPLOADS_LOGS] mutableCopy];
    if(!self.uploadsLogsArray || [self.uploadsLogsArray count]==0)
        return @"Uploads Logs Empty";
    emailText = [[self.uploadsLogsArray valueForKey:@"description"] componentsJoinedByString:@"\n\n"];
    return emailText;
}

-(void)deleteOlderItems{
    NSMutableArray* history  = [[[NSUserDefaults standardUserDefaults] arrayForKey:UPLOADS_LOGS] mutableCopy];
    if(history && [history count]>UPLOADS_LOGS_LIMIT){
        int count = (int)[history count];
        [history removeObjectAtIndex:0]; //delete oldest one
        [NSUserDefaultsManager saveObjectToUserDefaults:history withKey:UPLOADS_LOGS];
    }
}

@end
