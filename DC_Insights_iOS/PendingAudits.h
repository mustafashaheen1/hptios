//
//  PendingAudits.h
//  Insights
//
//  Created by Shyam Ashok on 9/17/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PendingAudits : NSObject

@property (nonatomic, strong) NSString *auditMasterId;
@property (nonatomic, assign) int auditCount;
@property (nonatomic, assign) int imageCount;
@property (nonatomic, strong) NSString *dateCompleted;

@end
