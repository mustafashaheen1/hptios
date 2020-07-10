//
//  AuditApiDevice.h
//  DC_Insights_iOS
//
//  Created by Vineet Pareek on 4/17/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "JSONModel.h"

@interface AuditApiDevice : JSONModel

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *version;
@property (nonatomic, strong) NSString *os_name;
@property (nonatomic, strong) NSString *os_version;

@end

