//
//  AuditApiLocation.h
//  DC_Insights_iOS
//
//  Created by Vineet Pareek on 4/17/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "JSONModel.h"
#import "AuditApiStore.h"
#import "AuditApiRetailStore.h"

@interface AuditApiLocation : JSONModel

@property (nonatomic, strong) AuditApiStore *store;
@property (nonatomic, strong) NSString *latitude;
@property (nonatomic, strong) NSString *longitude;
@property (nonatomic, strong) NSString *gpsMessage;
@property (nonatomic, strong) AuditApiRetailStore<Optional> *retailStore;

@end

