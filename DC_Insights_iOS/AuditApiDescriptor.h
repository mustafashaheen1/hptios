//
//  AuditApiDescriptor.h
//  DC_Insights_iOS
//
//  Created by Vineet Pareek on 4/17/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "JSONModel.h"

@interface AuditApiDescriptor : JSONModel

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *start;
@property (nonatomic, strong) NSString *end;
@property (nonatomic, strong) NSString *timezone;

-(NSString*)getTransactionId;
-(void)updateTransacationIdWithId:(NSString*)newTransactionId;

@end
