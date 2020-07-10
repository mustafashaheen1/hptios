//
//  AuditApiRetailStore.h
//  Insights
//
//  Created by Shyam Ashok on 9/2/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "JSONModel.h"

@interface AuditApiRetailStore : JSONModel

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *zip;
@property (nonatomic, strong) NSString *latitude;
@property (nonatomic, strong) NSString *longitude;

@end
