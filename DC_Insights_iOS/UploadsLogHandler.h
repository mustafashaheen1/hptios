//
//  UploadsLogHandler
//  Insights
//
//  Created by Vineet Pareek on 12/5/17.
//  Copyright © 2017 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>

//TODO abstract out the loghandler into a superclass
@interface UploadsLogHandler : NSObject

@property (nonatomic,strong) NSMutableArray* uploadsLogsArray;

-(void)deleteLogs;
-(void)addLogs:(NSString*)error;
-(NSString*)getEmailText;

@end
