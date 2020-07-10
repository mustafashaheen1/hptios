//
//  CrashLogHandler.h
//  Insights
//
//  Created by Vineet Pareek on 9/2/17.
//  Copyright © 2017 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CrashLogHandler : NSObject

@property (nonatomic,strong) NSMutableArray* crashLogsArray;

-(void)deleteCrashLogs;
-(void)addToCrashLogs:(NSString*)error;
-(NSString*)getEmailText;

@end
