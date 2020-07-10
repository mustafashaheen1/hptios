//
//  ErrorReport.m
//  Insights
//
//  Created by Vineet Pareek on 2/11/2016.
//  Copyright © 2016 Yottamark. All rights reserved.
//

#import "ErrorReport.h"
#import "DeviceManager.h"

@implementation ErrorReport

- (id)init
{
    self = [super init];
    if (self) {
        self.time = @"";
        self.timeForTrace = @"";
        self.url = @"";
        self.hmCode = @"";
        self.headers = [[NSMutableDictionary alloc]init];;
        self.error = @"";
        self.statusCode = @"";
        self.username = @"";
        self.roles = @"";
        self.response = @"";
        self.osType = @"iOS";
    }
    return self;
}
-(NSString*)getEmailSubject{
    return @"Trace Error with Mobile CodeExplorer App";
}

/*
 There was an error tracing code from Mobile CodeExplorer App.
 
 Code:
 Time:
 URL:
 Headers:
 
 Response:
 Error:
 
 Username:
 Roles:
 */


-(NSString*)getEmailBody{
    NSMutableString* emailBody = [@"" mutableCopy];
    
    [emailBody appendString:@"There was an error tracing code from Mobile CodeExplorer App."];
    [emailBody appendString:@"\n\nCode: "];
    [emailBody appendString:self.hmCode];
    
    [emailBody appendString:@"\nTime: "];
    [emailBody appendString:self.time];
    
    [emailBody appendString:@"\nURL: "];
    [emailBody appendString:self.url];
    
    [emailBody appendString:@"\nHeaders: "];
    NSString* headers = [NSString stringWithFormat:@"%@", self.headers];
    [emailBody appendString:headers];
    
    [emailBody appendString:@"\nRoundtrip: "];
    [emailBody appendString:self.timeForTrace];
    
    [emailBody appendString:@"\n\nAPI Response:"];
    [emailBody appendString:self.response];
    
    [emailBody appendString:@"\nStatus Code: "];
    [emailBody appendString:self.statusCode];
    
    [emailBody appendString:@"\nError: "];
    [emailBody appendString:self.error];
    
    [emailBody appendString:@"\n\nUser-Details:"];
    [emailBody appendString:@"\nUsername: "];
    [emailBody appendString:self.username];
    
    [emailBody appendString:@"\nRoles: "];
    [emailBody appendString:self.roles];
    
    [emailBody appendString:@"\n\nDevice-Details:"];
    [emailBody appendString:@"\nID: "];
    [emailBody appendString:[DeviceManager getDeviceID]];
    
    [emailBody appendString:@"\nOS-Type: "];
    [emailBody appendString:@"iOS"];
    
    return [emailBody copy];
    
}


@end
