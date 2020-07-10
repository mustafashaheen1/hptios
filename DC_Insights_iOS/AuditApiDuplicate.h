//
//  AuditApiDuplicate.h
//  Insights
//
//  Created by Shyam Ashok on 9/3/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "JSONModel.h"

@interface AuditApiDuplicate : JSONModel

@property (nonatomic, assign) BOOL value;
@property (nonatomic, assign) int count;

@end
