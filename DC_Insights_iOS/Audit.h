//
//  Audit.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/23/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "DCBaseEntity.h"
#import "JSONMOdel.h"
#import "AuditApiData.h"

@interface Audit : JSONModel

@property (nonatomic, strong) AuditApiData* auditData;

@end
