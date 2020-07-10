//
//  ErrorReport.h
//  Insights
//
//  Created by Vineet Pareek on 2/11/2016.
//  Copyright © 2016 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ErrorReport : NSObject

@property NSString* time;
@property NSString* timeForTrace;
@property NSString* hmCode;
@property NSString* url;
@property NSDictionary* headers;
@property NSString* error;
@property NSString* statusCode;
@property NSString* username;
@property NSString* roles;
@property NSString* response;
@property NSString* osType;

-(NSString*)getEmailBody;
-(NSString*)getEmailSubject;


@end
